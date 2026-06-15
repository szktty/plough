# Drag Latency Investigation Plan

Created: 2026-06-14
Branch: `feature/redesign`
Motivation: Dragging a node feels like it lags slightly behind the cursor.
Goal: Isolate the cause and identify options to eliminate the perceived delay.

This document separates **facts confirmed by code analysis** from **hypotheses
requiring real-device measurement**, and organises measurement procedures,
mitigation candidates, and acceptance criteria. Implementation is a separate
task.

---

## 0. Summary of Findings (Current State)

- The drag-position update path **is synchronous**: `onPanUpdate` →
  `logicalPosition` update → `positionListenable` fires →
  `Positioned(left/top)` rebuilds. No post-frame wait.
- The known "post-frame callback" only updates **geometry** (hit-test bounds) —
  it does **not** affect the rendered position. The perceived lag is therefore
  unlikely to be caused by a post-frame delay.
- **Confirmed structural load source: nodes have no `RepaintBoundary`** (C2
  below).
- **Physical lower bound: input → display is at minimum 1 frame behind** (true
  for all GUI frameworks; cannot be eliminated).

### Additional findings from code-analysis session (2026-06-14, HEAD `9d744e0`)

- **C1 ruled out (code analysis)**: `node.logicalPosition = position`
  (`state_manager.dart:193`) only sets `_logicalPosition.value` — it does **not**
  call `_notifyLayoutChange()` (`node.dart:136–144`). `layoutChangeListenable`
  fires only from structural changes in `graph_base.dart` (add/remove/connect
  etc.) and from `notifyLayoutStep` (streaming layout). Therefore the
  `AnimatedBuilder` in `graph.dart:557` (which listens to
  `layoutChangeListenable` + `_buildState` and calls `_markSortDirty()` /
  full sort / outer Stack rebuild) **does not fire during a drag**. During a
  drag, rebuilds are confined to the single dragged node's `GraphNodeView`
  (via `positionListenable`, `node.dart:221–241`). **Mitigation B (C1) is not
  needed for this issue.**
- **C2 confirmed (code analysis)**: Links have `RepaintBoundary(child:
  CustomPaint)` (`link.dart:102`), but **nodes do not** (grep: zero hits).
  Each `GraphNodeView` returns a `Positioned` that is a direct child of the
  outer `Stack` (`graph.dart:617`, key `_layoutKey`). Moving one node causes
  the entire Stack (all nodes) to repaint. This is the **only remaining
  structural load source during a drag**. Whether the paint time actually
  scales with node count and exceeds 16.6 ms can only be confirmed by
  real-device measurement (M1/M4).
- **B largely ruled out**: The interpolation branch in
  `_buildArrangedPosition` (`node.dart:259–280`) requires
  `isAnimating && _positionController.isAnimating`. During a drag,
  `isAnimating` is set to `false` by `drag_state.dart:115` before
  `setPosition`, so normal frames skip interpolation. Residual risk: the
  very first frame of a drag start (M3).
- **GraphPositionPlotter is normally disabled**: `enabled = false`
  (`position_plotter.dart:26`); `wrapOr` passes the child through unchanged,
  so it contributes nothing to normal drag paint cost.
- **Conclusion**: Code analysis is exhausted. **Root-cause candidates are C2
  (node repaint cost without `RepaintBoundary`) and A (physical 1-frame
  delay)**. Real-device measurement (M1/M2) is required to determine which
  dominates.

---

## 1. Drag Update Code Path (Confirmed by Code Analysis)

```
Listener.onPointerMove / PanGestureRecognizer.onUpdate
  └→ GraphGestureManager.handlePanUpdate(details)          gesture_manager.dart
       └→ GraphNodeDragStateManager.handlePanUpdate(details)  drag_state.dart:93–127
            - rawDelta = details.delta
            - logicalDelta = dragDeltaTransform?(rawDelta) ?? rawDelta
            - newLogicalPosition = initial + accumulatedDelta
            - (entity as GraphNodeImpl).isAnimating = false   ← drag_state.dart:115
            └→ setPosition(id, newLogicalPosition)            state_manager.dart:187–217
                 - node.logicalPosition = position            (synchronous, immediate)
                 - addPostFrameCallback → node.geometry update (hit-test bounds only)
```

Rendering path:

```
GraphNodeView.build                                         node.dart:218–241
  AnimatedBuilder(animation: merge[buildState, positionListenable, renderStateListenable])
    └→ _buildArrangedPosition                                node.dart:259–279
         - if (animationEnabled && isAnimating && controller.isAnimating)
              return _buildAnimatedPosition(...)              ← skipped during drag (B)
         - addPostFrameCallback → _updateGeometry()           (hit-test bounds only)
         - return Positioned(left: logicalPosition.dx, top: ...) (synchronous render)
```

**Key point**: `logicalPosition` changes propagate through `positionListenable`
and reach `Positioned` within the same frame. The post-frame geometry update is
unrelated to the rendered position.

---

## 2. Hypotheses and Status

### A. 1-Frame Input-to-Display Latency (Physical Lower Bound) — Cannot Be Eliminated

`onPanUpdate` updates the position, but the change appears on screen only in
the next frame. At 60 fps: up to 16.6 ms. This is a universal property of all
GUI frameworks. **It cannot be reduced to zero.** If this is the sole cause of
the perceived lag, the only mitigation is predictive interpolation (§3-D).

### B. Interpolation on Drag Start — Largely Ruled Out (Residual Risk: First Frame Only)

- The interpolation branch requires `isAnimating && controller.isAnimating`.
- During a drag `isAnimating` is `false` (set in `drag_state.dart:115`), so
  normal frames use synchronous rendering. **B does not occur in steady state.**
- Residual risk: the very **first frame of a drag start**, if a layout
  animation was running immediately before, could render an interpolated
  (lagged) position. Confirm with real-device measurement (M3).

### C. Node Repaint Cost (Structural — Confirmed) — Needs Mitigation

- **C1**: The outer `AnimatedBuilder` in `graph.dart:557` calls
  `_markSortDirty()` every build, potentially causing a full-tree rebuild and
  full sort on every drag frame. → **Ruled out by code analysis** (this builder
  only fires when `layoutChangeListenable` changes; `setPosition` does not
  trigger it). Mitigation B (C1) is not needed.
- **C2 (confirmed)**: **Nodes have no `RepaintBoundary`** (grep: zero hits in
  `lib/src`). Links have one (`link.dart:102`). Moving a node causes the
  entire node-hosting `Stack` to repaint. As node count grows, per-frame paint
  cost grows linearly, leading to frame drops and perceived lag. **This is the
  only confirmed structural load source during a drag.** Whether it actually
  exceeds 16.6 ms must be measured (M1/M4).

### D. `dragDeltaTransform` Round-Trip (Viewport Only) — Low Priority

Inside `GraphViewport`, `dragDeltaTransform = delta / scale`
(`interactive_overlay.dart`). This is a single division — lightweight. It is
unlikely to be the primary cause. Check in M2 whether the viewport `Transform`
reconstruction fires every frame.

---

## 3. Mitigation Candidates (Choose Based on Measurement Results)

### Mitigation A: Add `RepaintBoundary` to Nodes (C2 — Low Risk, Top Priority)

- Wrap the `Positioned` child in `GraphNodeView` (or the node renderer widget)
  with `RepaintBoundary`.
- Effect: only the moving node's layer is repainted per frame; other nodes'
  paint layers are reused. Significantly reduces per-frame paint cost at higher
  node counts.
- Risk: low. Possible trade-off with layer creation overhead (may be
  counter-productive if many tiny nodes). Confirm goldens are unchanged.
- Verification: DevTools "Highlight repaints" should show only the dragged node
  flashing, not all other nodes.

### Mitigation B: Limit Rebuild Scope to the Dragged Node (C1 — Medium Risk)

- If measurement shows that `logicalPosition` changes are propagating a
  full-tree rebuild, prevent the `layoutChangeListenable` from triggering and
  revisit the per-frame `_markSortDirty` call.
- Note: this is closely related to `design_review.md` issue 5 / F3+ / D1
  (RenderObject migration). Touching this in isolation carries regression risk.
  **Only proceed after measurement confirms C1 is a factor.**
- Dependency: align design with F3+ / D1.

### Mitigation C: Suppress Interpolation on Drag Start (B Residual — Low Risk)

- At the pan-ready → drag transition, immediately stop `_positionController` so
  the very first drag frame uses synchronous rendering.
- Effect is limited to the start frame. Apply only if M3 shows B is observed.

### Mitigation D: Predictive Interpolation (A Mitigation — High Risk, Last Resort)

- Extrapolate 1 frame ahead from recent pointer velocity to visually compensate
  for the physical 1-frame delay.
- Risk: overshoot on fast reversal or sudden stop → unnatural feel. Requires
  threshold and damping tuning. **Use only if A/B mitigations are insufficient.**

---

## 4. Measurement Procedures (Real Device — No Guessing)

> The example app (`example/`) has debug logging and gesture debug disabled
> (confirmed). Add measurement code temporarily; remove it after measurement.

### M1: Measure Input-to-Display Latency

- Use Flutter DevTools Performance / Timeline.
- Record build / layout / paint / raster time for one frame during a drag.
- Expected: if build+layout+paint total exceeds 16.6 ms → frame drop → C series
  is primary. If within 16.6 ms → A (physical lower bound) is primary.

### M2: Visualise Rebuild / Repaint Scope

- Use DevTools "Track widget builds" (`debugProfileBuildsEnabled`) to see which
  widgets rebuild during a drag (C1 check).
- Use DevTools "Highlight repaints" to see repaint regions (C2 check).
  If nodes other than the dragged one flash → C2 is active.

### M3: Detect Interpolation on Drag Start Frame

- Add a temporary counter to the interpolation branch of
  `_buildArrangedPosition` and check whether it fires during a drag operation
  (including the start frame). Confirms or rules out B.

### M4: Measure Effect of Mitigation A (Post-Fix)

- Compare M1 (paint time) before and after adding `RepaintBoundary`.
- Vary node count (10 / 50 / 200) to assess scaling behaviour.

---

## 5. Acceptance Criteria (When a Mitigation Is Applied — Separate Task)

- Mitigation A: goldens unchanged. DevTools shows only the dragged node
  repainting. Paint time approaches constant as node count grows.
- All mitigations: `flutter analyze` no warnings, `flutter test` green,
  `dart format --set-exit-if-changed .` exits 0.
- Drag tracking feels improved subjectively, backed by DevTools frame-time data.

---

## 6. Recommended Sequence

### First Action in the Next Session (Start Here)

> Code analysis (steps 1–2 and C1/C2/B analysis) was completed in the
> 2026-06-14 session (see §0 above). **B1 is committed (HEAD `9d744e0`);
> working tree is clean.** Only real-device measurement remains. Start from
> step 3.

1. ~~Confirm repository state~~ → done (B1 committed, clean).
2. ~~Re-verify code paths at current HEAD~~ → done (line numbers confirmed).
3. **Measurement first** (user preference): perform M1/M2 on a real device.
   Root-cause candidates are already narrowed to **C2 (node paint cost) and
   A (physical 1-frame delay)**. M1 shows whether paint dominates a drag frame.
   M2 "Highlight repaints" shows whether non-dragged nodes flash (C2 check).
   - C1 is ruled out, so M2 "Track widget builds" serves only as a sanity check
     (confirm rebuilds are confined to the dragged node).
4. Record actual measurements under each hypothesis in §2 ("Measured: …") and
   mark as confirmed / ruled out.
5. Based on confirmed cause, select mitigation from §3:
   - C2 primary → Mitigation A (RepaintBoundary)
   - A only → "Not addressable; acceptable" — close investigation
   - B observed in M3 → Mitigation C

### Order of Mitigations

```
1. M1/M2 (measure): determine whether lag is C (paint/rebuild) or A (physical)
2. C2 confirmed → Mitigation A (RepaintBoundary)        ← low risk, top priority
3. C1 confirmed → Mitigation B (align with F3+/D1 design)
4. B observed in M3 → Mitigation C (suppress start-frame interpolation)
5. Lag still perceived → Mitigation D (predictive interpolation) ← last resort
```

Short-term / low-risk: Mitigation A.
Medium-term (design-coupled): Mitigation B (F3+/D1).
High-care: Mitigation D.

### Definition of Done

- The primary cause has been identified by measurement and recorded in §2 with
  actual values.
- At least one mitigation has been applied and subjective improvement is backed
  by DevTools frame-time data.
- If measurement shows the only cause is A (physical lower bound) and no
  mitigation is warranted, record that conclusion here and close the
  investigation ("not addressable; acceptable" is a valid completion state).

---

## 7. Related

- `doc/design_review_plan.md` F2 (`shouldRepaint`), F3+ (rebuild-scope
  reduction), D1 (RenderObject migration). Mitigation B is coupled to F3+/D1.
- Known gotchas: `node-geometry-no-scale-divide` (do not divide geometry by
  scale), `drag-end-spatial-index-refresh` (post-frame `refreshAllNodeGeometry`
  in `handleDragEnd` must not be removed). Any mitigation that touches the
  geometry path must not violate these invariants.
- If D1 (RenderObject migration) lands, the structural costs (C1/C2) and
  post-frame sync are expected to resolve principally through the Flutter layout
  protocol. Mitigations A/B from this investigation are therefore **interim
  improvements pending D1**.
