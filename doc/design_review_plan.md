# Plough Design Review — Implementation Plan

Drafted: 2026-06-13
Base: `doc/design_review.md` (reviewed 2026-06-10, HEAD 4f579bc)
Branch: `feature/redesign`

This document breaks the findings from `doc/design_review.md` into verifiable,
actionable work units with explicit dependencies, acceptance criteria, and risk
ratings. A review-request section for an independent session appears at the end.

> **Updated 2026-06-13**: Incorporated feedback from the independent review
> (`doc/design_review_plan_feedback.md`). Major additions:
> - New tasks **A7** (delete dead file `enhanced_client.dart`) and **A8**
>   (`removeLink` missing notification), plus **F1/F2** (standalone performance
>   fixes).
> - **A4** refined from "clear everything" to "state/flag divergence in
>   deselectNode"; positioned as a stopgap that C1 will absorb.
> - **B1** extended to remove the `intersections.first` (unordered Set)
>   dependency.
> - **B2** dependency on **E1** made explicit (injection-point consolidation is
>   a prerequisite); placement strategy confirmed as (c) separate package.
> - **C2** explicitly marked as subordinate to D1; **E1** extended with a
>   side-effect check procedure for state-reading expressions.
> - Review confirmed: `http` used in 2 files, `removeLink` notification missing,
>   view-map leak verified in actual code.
>
> **Updated 2026-06-13 (second round)**: Incorporated the second-round review
> (proceed). **E1 implementation strategy confirmed as the overload compromise**:
> accept `Object message` (both `String` and `String Function()`) so the ~268
> existing call sites compile unchanged; only hot-path calls are migrated to
> `() =>`. Blanket lazy migration of all 268 sites is out of scope.
> `sendLog` enabled-guard moves to the call site. Runtime cost of option A is
> negligible; the bottleneck is migration cost (268 sites).

---

## 0. Principles

- Begin with behavior-preserving tasks (refactors/fixes); defer design changes
  to later phases.
- Every task's completion criteria includes: `flutter analyze` with no new
  warnings, `flutter test` green, `dart format --set-exit-if-changed .` exits 0
  (per CLAUDE.md Git Workflow).
- One task = one branch = one PR (branched from `main`; Conventional Commits).
- For behavior-preserving tasks, **add regression tests before changing any
  code** (safety-net-first rule).
- All major findings from `design_review.md` were verified against actual code
  before planning:
  - `removeNode` does not clean up the links map (`graph_base.dart:300–319`)
  - `_nodeDependencies` is a dead field that is never populated
    (`graph_base.dart:316, 370`)
  - `reverseLink` mutates without notifying (`graph_base.dart:377–384`)
  - `deselectNode` in single-selection mode clears everything
    (`graph_base.dart:457–469`)
  - `flame` dependency is used only in `shape.dart`; `dart:io` only in
    `debug_server.dart`
  - `KeyedSubtree(key: ValueKey(_graph.hashCode))` (`graph.dart:684`)
  - `_performLayout` / `_markSortDirty` called during build (inside
    `AnimatedBuilder` builder) (`graph.dart:559, 575`)

---

## Phase A: Bug Fixes (independent of design; implement immediately)

Goal: correct behavior. Each item is independent and can be worked in parallel.
**Write a failing regression test first, then fix.**

### A1. `removeNode` does not remove connected links from the links map
- Location: `lib/src/graph/graph_base.dart:300–319`
- Current: removes from the adjacency index but leaves links in
  `state.value.links`, so links referencing a deleted node remain as render
  targets. Contradicts the documentation's "automatically removes any links."
- Fix:
  1. Add a failing regression test (no connected link remains in `links` after
     node removal; `getIncomingLinks`/`getOutgoingLinks` consistency).
  2. Remove each affected link with `state.value.links.remove(link.id)` before
     `copyWith`; combine index removal and map removal in a single `setState`.
- Acceptance: connected links disappear from `getAllLinks()` and rendering after
  node removal. Existing tests remain green.
- Risk: Low. Avoid duplicating `removeLink` logic; consider sharing.

### A2. Delete dead field `_nodeDependencies`
- Location: `graph_base.dart:~220` (declaration), `316`, `370–372`
- Current: only written (on deletion), never read; the `removeWhere` condition
  in `removeLink` (`state.value.links.containsKey(key)`) is therefore
  meaningless.
- Fix: delete the field and all references; remove the `removeWhere` block from
  `removeLink`.
- Acceptance: all tests green and `analyze` clean after deletion.
- Risk: Low (confirmed unused). Same file as A1; **do sequentially**.

### A3. `reverseLink` mutates without notifying
- Location: `graph_base.dart:377–384`
- Current: directly mutates `GraphLinkImpl.source/target` with no `state`
  notification and no layout notification → UI does not update. Also mutates a
  mutable object inside a Freezed-immutable map (design smell).
- Fix (two stages):
  1. **Minimal fix (behavior correction)**: call `_notifyLayoutChange()` after
     mutation; re-index `_incomingIndex`/`_outgoingIndex` to reflect the
     swapped source/target. Add regression test.
  2. **Design correction (Phase C)**: consider replacing `reverseLink` with an
     immutable swap (remove old link, add new one). Defer to C2.
- Acceptance: after `reverseLink`, the direction is reversed and
  UI/index are updated. **Mandatory test: index points to new source/target.**
- Note: stop at the minimal fix here. Immutable replacement interacts broadly
  with the mutable-link assumptions elsewhere; batch that work into C2.
- Related: **same kind of issue as A8 (`removeLink` missing notification);
  fix in the same PR**.
- Risk: Medium (risk of missing index update). Tests required.

### A4. `deselectNode` state/flag divergence (stopgap absorbed by C1)
- Location: `graph_base.dart:457–469` (`deselectLink` has the same pattern:
  `518–531`)
- Current: in single-selection mode, calling `deselectNode(otherId)` creates a
  three-way inconsistency:
  - The targeted node's `isSelected` is set to false (a node that should not
    have been touched)
  - The actually-selected node's `isSelected` remains true
  - `selectedNodeIds` is replaced with an empty list
  This is a typical symptom of the dual-management problem (issue 2–3); A4 and
  C1 share the same root cause.
- Fix: only remove the id when it is currently selected (use
  `selectedNodeIds.remove(id)` as the base; set `node.isSelected = false` only
  when the target is actually selected). Fix both node and link paths. Add
  regression test.
- Acceptance: `deselectNode` on an unselected id leaves the current selection
  unchanged. `state` list and node flag do not diverge.
- Position: **stopgap that C1 (single source of truth) will supersede.**
  "Fix the bleeding now with A4; make it permanent with C1." Maintain A4 → C1
  order.
- Risk: Low–medium. Verify consistency with other selection APIs
  (`toggleSelectNode`, etc.).

### A5. Change `KeyedSubtree` key from `graph.hashCode` to `graph.id`
- Location: `lib/src/graph_view/widget/graph.dart:684`
- Current: `ValueKey(_graph.hashCode)` can collide and is unstable.
- Fix: change to `ValueKey(_graph.id)` (`GraphId` is unique).
- Acceptance: widget test for graph-swap scenario passes as before.
- Risk: Low, but this touches the "stale overlay pointerHandlers after graph
  swap" gotcha (viewport-drag-delta-and-handler-swap); the graph-swap widget
  test is mandatory.

### A6. Minor TODOs and contract oddities in `behavior.dart`
- Location: `lib/src/graph_view/behavior.dart:139` (hardcoded thickness=30 TODO),
  `195/276` (`abstract interface class` with a concrete `isEquivalentTo`
  implementation)
- Fix (minimal):
  - Extract the magic number to a named constant; clarify the TODO intent.
  - Do **not** split the interface now (breaking change). Add a comment
    documenting the current state; defer interface separation to Phase C.
- Acceptance: constant extraction only. Behavior unchanged.
- Risk: Low.

### A7. Delete dead file `enhanced_client.dart` (added by review)
- Location: `lib/src/debug/enhanced_client.dart`
- Current: imports `package:http` but is **not imported anywhere in `lib/`**
  (zero references). Same category as A2.
- Fix: delete file. Reduces `http` usage to `external_debug_client.dart` only;
  prepares for B2.
- Acceptance: all tests green and `analyze` clean after deletion.
- Risk: Negligible (confirmed unused).

### A8. `removeLink` missing `_notifyLayoutChange()` (added by review)
- Location: `graph_base.dart:362–374`
- Current: `addLink` (line 328) calls `_notifyLayoutChange()`, but
  **`removeLink` does not** (asymmetric). Removing a link is not reflected in
  the UI or layout. Same class of issue as A3.
- Fix: add `_notifyLayoutChange()` after `copyWith`. **Fix in the same PR as
  A3.** A2 also removes the `_nodeDependencies.removeWhere` block from this
  function.
- Acceptance: widget test showing link removal disappears from rendering.
- Risk: Low–medium.

---

## Phase B: Dependency Reduction (pub quality, web safety)

Remove heavy and platform-specific dependencies from the public import graph.

### B1. Replace `flame` dependency with self-contained geometry code
- Location: `lib/src/graph_view/shape.dart` (only file using flame)
  - Uses `LineSegment` (flame), `CircleComponent.lineSegmentIntersections`,
    `Rectangle.fromRect(...).intersections(...)` (lines 2–4, 31, 78–103)
- Fix:
  1. Add a ~50-line utility (`lib/src/utils/geometry_intersect.dart` or similar)
     implementing segment × circle and segment × axis-aligned rectangle
     intersection.
  2. **Write a numeric unit test first** that runs both the flame version and the
     new version in parallel and asserts equal results.
  3. Remove `flame` from `pubspec.yaml` after the test passes.
- Acceptance: intersection unit tests green after flame removal. Link endpoint
  rendering unchanged visually / in goldens.
- **Important (review note)**: flame's `intersections` returns a `Set`
  (unordered). The current `behavior.dart:379` uses `.first`, which may return
  a different point with a custom implementation. Add to acceptance criteria:
  **"remove the `.first` dependency; choose the nearest point (or equivalent)
  explicitly."** (Related to the link-endpoint-gap-followup gotcha.)
- Risk: Medium (floating-point edge cases, tangent cases, order dependency).
  Covered by goldens and numeric tests.

### B2. Separate debug server stack (`dart:io`/`http`) from the core package
- Locations: `lib/src/debug/debug_server.dart` (`dart:io`),
  `external_debug_client.dart` (`http`), `debug_manager.dart`/
  `structured_logger.dart` importing `debug_server.dart`.
  `gesture_manager.dart:7` imports `external_debug_client.dart`.
- Public import graph (verified): `plough.dart → manager.dart →
  debug_manager.dart → debug_server.dart (dart:io)`. **`dart:io` is in the
  public import graph.** The concern is valid.
- Problem: `dart:io`, `http`, and `logger` appear in the core package's import
  graph, harming web safety and package weight.
- Strategy (recommended by review): **(c) Separate package, staged.**
  Create `plough_devtools` (provisional name) as a separate package. The core
  holds only a **no-op `DebugSink` interface**; debug implementations are
  injected at runtime via `Plough().attachDebugSink(...)`.
- Fix (stages):
  1. A7: `enhanced_client.dart` deleted (prerequisite).
  2. Consolidate injection points into one interface (`DebugSink`)
     (**E1 is a prerequisite**).
  3. Move `debug_server`/`external_debug_client`/workbench integration to the
     separate package; set the core default to no-op.
  4. Remove `http` from the core `pubspec.yaml`.
- Acceptance: `flutter test -p chrome` (web) produces no import errors.
  `http` (and ideally `logger`) removed from core `pubspec.yaml`.
- Risk: High (requires a placement decision).
- Dependency: **after E1 (injection-point consolidation) is complete**.

### B3. Value-equality style survey (investigation task)
- Concern: `equatable`, `freezed`, and `fast_immutable_collections` coexist
  in `pubspec.yaml:17–19`.
- Fix: grep for `equatable` usage; evaluate whether those cases can migrate to
  Freezed. **Survey only — no code changes yet.**
- Acceptance: a list of usage sites and a migration-feasibility note left in
  `doc/`.
- Risk: Low (survey only).

---

## Phase C: State Management Cleanup (medium-term; design changes)

### C1. Single source of truth for selection state
- Issue: issues 2–3 (`node._isSelected` vs `GraphData.selectedNodeIds` dual
  management; `force: true` hack)
- Fix:
  1. Make `GraphData.selectedNodeIds` / `selectedLinkIds` the **sole truth**.
  2. Change `node.isSelected` / `link.isSelected` to derived getters backed by
     `selectedIds` (eliminate individual `ValueNotifier<bool> _isSelected`).
  3. Remove dual-sync code and `force: true` from `selectNode`, `deselectNode`,
     `clearSelection`.
  4. Guarantee that rendering updates on selection change (widget/golden tests).
  5. **Make `set canSelect(false)` clear selection through the single source**
     (see [R1] below).
- Acceptance: all selection tests green. Manual sync code for `_isSelected`
  deleted. **Verify that `isSelected` and `selectedNodeIds` do not diverge after
  `canSelect = false`.**
- **Carry-over (phase-A review [R1])**: `node.dart:172–179`
  `set canSelect(bool)` on a selected node sets `_isSelected.value = false` but
  does not update `GraphData.selectedNodeIds` — the opposite divergence from
  what A4 fixed. A4 only fixes the `deselectNode` path; this `canSelect` path
  divergence remains. Deriving `isSelected` eliminates this in principle; C1
  absorbs it.
- Risk: High (changes rendering subscription path). Begin after A4 is complete.
- Dependency: A4 complete.

### C2. Separate View state (`NodeViewState`) from `GraphNode`
- Issue: issues 2–4 (`geometry`/`animatedPosition`/`isArranged`/
  `animationStartPosition`/`stackOrder` live in the model → one `Graph` cannot
  be shown in two `GraphView` instances simultaneously).
  `node.dart:63–75` holds the relevant `ValueNotifier` fields.
- Fix:
  1. Reduce `GraphNode` to pure data (id, properties, weight, canSelect, …).
  2. Hold `Map<GraphId, NodeViewState>` (geometry, animation, stackOrder) on the
     `GraphView` side.
  3. Redirect all geometry references in layout/rendering/gesture to the
     View-side state.
  4. Ensure consistency with the reverseLink invariants from A3.
- Acceptance: add a widget test that mounts one `Graph` in two `GraphView`
  instances side-by-side; verify that an operation on one view does not corrupt
  the other's geometry.
- Risk: Very high (geometry sync / node-geometry-no-scale-divide /
  viewport-hittest-ownership and other known gotchas).
- Dependency / rationale (from review): **subordinate to D1.** D1 determines
  where geometry is stored and what coordinate system it uses. Starting C2 first
  risks rebuilding the storage structure when D1 arrives. **D1 RFC/PoC must
  establish "who owns geometry" before C2 fills that container.** Mandatory
  re-review before starting. See `doc/c2_node_view_state_design.md`.

---

## Phase D: Gesture / Rendering Architecture (long-term; v2)

### D1. Migrate to `MultiChildRenderObjectWidget` + custom `RenderBox`
- Issues: issue 1 (post-frame bootstrap), issue 5 (performance ceiling)
- Summary: call `child.layout(constraints, parentUsesSize: true)` inside
  `performLayout` to obtain child sizes in the same frame → eliminate post-frame
  geometry read-back, `GlobalKey`, three-phase `_buildState`,
  `refreshAllNodeGeometry`. Draw links in `paint()`; delegate node hit-testing
  to `hitTestChildren`; route viewport Transform through
  `applyPaintTransform`/`hitTest`; eliminate hand-written
  `screenToScene`/`globalToScene`/`dragDeltaTransform`.
- Approach: **too large for a single PR — file a design RFC**
  (`doc/rfc_render_graph_view.md`). Validate the approach with a small PoC
  (a few nodes + 1 link as a RenderObject prototype), then migrate in stages.
- Acceptance (PoC): geometry available without post-frame callbacks; tap/drag/
  zoom behave equivalently to current implementation.
- Risk: Maximum. Verify in the PoC whether the four known gotchas
  (drag-end-spatial-index-refresh, node-geometry-no-scale-divide,
  viewport-drag-delta-and-handler-swap, viewport-hittest-ownership) are
  principally resolved.
- Dependency: begin after Phases A and B are complete. Design in parallel with C.

### D2. Consolidate GestureManager into a per-pointer FSM
- Issue: issue 4 (10 state managers; node/link code duplication; enum
  branching scattered throughout; redundant double `findNodeAt` calls;
  `GraphGestureMode` branching spread everywhere)
- Fix:
  1. Consolidate into an explicit per-pointer FSM
     (idle → pressed → panReady → dragging / tapped) in one object.
  2. Unify node and link handling: `GraphId` is unique across entity types, so
     separate classes are unnecessary.
  3. Deduplicate the `handlePointerUp` node (~230 lines) and link (~60 lines)
     implementations.
  4. Eliminate the redundant double `findNodeAt` ("Double-check to prevent race
     conditions" at `gesture_manager.dart:634, 1178`, etc.) — synchronous code
     has no races.
  5. Consolidate `GraphGestureMode` into per-mode Strategy objects.
- Acceptance: gesture tests (simulated pointer) remain fully green; significant
  line-count reduction.
- **Known bug**: after selecting a link, a background tap does not deselect it
  (asymmetric vs. node behavior; also corrupts the node-side background deselect
  in subsequent interactions). Add "background tap clears link selection" as a
  D2 acceptance criterion.
- Risk: High (regression-prone). Expand gesture test coverage before starting.
- Dependency: after Phase A (logging lazy-init = E1). Can start independently
  of D1.

### E1. Closure-overload addition to log API + lazy-init for hot paths
- Issue: issue 3 (`logDebug(cat, '...substring...')` evaluates string
  interpolation and builds Maps even when logging is disabled; runs on every
  pointer event / frame)
- Context (confirmed in second-round review): `logDebug`/`logInfo`/`logWarning`/
  `logError`/`logGestureDebug` currently take a fixed `String` signature
  (`utils/logger.dart:100–110`) and are called from **~268 sites** across the
  library.
- "Cost" has two dimensions: **at runtime, option A (full lazy migration) is not
  expensive** (capture-free closures are statically allocated; the
  `substring`/`map`/`join`/`DateTime.now().toIso8601String()` costs that can be
  avoided are orders of magnitude larger). The expensive part is **migration cost
  (268 sites)**, which is at odds with "quick/low-risk."
- **Adopted strategy (compromise)**: stage the migration with an overload.
  ```dart
  // Accept both String and String Function() via Object
  void logDebug(LogCategory category, Object message) => _logger.d(
        category,
        message is String Function() ? (enabled ? message() : '') : message,
      );
  ```
  - **All 268 existing String call sites compile and run unchanged.**
  - **Only hot paths** (`handlePointerDown`, drag, etc. in `gesture_manager`)
    are migrated to `() => '...'`, eliminating string construction on those
    paths when logging is off.
  - Incrementally captures the runtime benefit of option A with the small change
    surface of option B. Remaining sites are migrated in later tasks.
  - Note: even after switching to `Object message`, **existing call-site
    interpolations are already evaluated at the call site**, so the benefit only
    applies to `() =>`-migrated hot paths (this justifies the narrow scope).
- Scope: "add closure-overload to log API + migrate only hot paths to `() =>`."
  **Blanket migration of all 268 sites is out of scope.**
- Additionally: move the `if (enabled)` guard for
  `externalDebugClient.sendLog(metadata: {...})` to the **call site** (currently
  the `_enabled` check is inside the function, so the argument Map is built even
  when logging is off). Include in E1.
- **Caution (review note)**: some debug interpolation arguments in
  `gesture_manager.dart` contain **state-reading calls** such as
  `_nodeTapManager.states` traversal and `getTapStateDebugInfo()`. Before
  converting to closures or moving guards, **verify in review that the argument
  expressions are read-only (no side effects)**.
- Acceptance:
  - Closure overload added; **existing String calls compile and run unchanged**.
  - `() =>`-migrated targets are confirmed to be in per-pointer/per-frame paths.
  - Moved argument expressions are **read-only (no side effects)**.
  - **Log output content is identical to before** when logging is enabled.
  - Hot paths do not build strings/Maps when logging is off (code review or
    benchmark). Behavior unchanged.
- Risk: Low–medium. **Can start alongside Phase A** (immediately effective).
- Position: short-term. Despite the "E" prefix, **implement early.** Also a
  **prerequisite for B2** (consolidating injection points into one interface).
- **Implemented** (2026-06-14, commit `2d6c4c0`; assert in separate commit).
  Review approved. E1 covers: closure-overload API (foundation) + one hottest
  path (`TAP_DEBUG_STATE` block in `handlePointerMove`) with
  `isGestureDebugEnabled` pre-guard + `_sendToExternalDebug` enabled guard.
  **Zero actual `() =>` call sites** at this stage; that is intentional — the
  foundation enables the next phase ([S1]).
- **Next-phase carry-overs (review [S3]/[S4])**:
  - **[S3] Level-aware `enabled` refinement**: currently `enabled(category)`
    returns true for anything other than `Level.off`. Comparing against the
    required level (e.g., `Level.debug` for `logDebug`) would prevent wasted
    closure evaluation for categories that are enabled but at a lower level than
    the call. Evaluate before adding more `() =>` sites. → Filed as **E2**.
  - **[S4] Lazy-init `handlePointerDown`/`handlePointerUp` map construction**:
    per-pointer `externalDebugClient.sendLog(metadata: {...})` /
    `logGestureDebug(data: {...})` map construction remains
    (`gesture_manager.dart:462–656, 658–1063`). Not every frame, but runs on
    each drag start/end and tap. → Filed as **E3**.

### E2. Level-aware `enabled` refinement for log API (review [S3]; next phase)
- Target: `PloughLogger.enabled(category)` returns true for anything other than
  `Level.off`.
- Fix: extend to `enabled(category, level)` that compares the required level
  (debug/info/…) and suppresses wasted closure evaluation.
- Prerequisite: effective mainly when combined with E3 (more `() =>` sites).
  No urgent practical impact on its own.
- Risk: Low. Acceptance: output content unchanged; closures not evaluated at
  disabled levels.

### E3. Lazy Map construction in `handlePointerDown`/`Up` (review [S4]; next phase)
- Target: per-pointer `sendLog`/`logGestureDebug` calls in
  `gesture_manager.dart:462–656` and `658–1063`.
- Fix: guard `metadata: {...}` / `data: {...}` construction behind
  `isGestureDebugEnabled` / `externalDebugClient.enabled` (same pattern as
  `handlePointerMove`), or migrate to closure passing.
- Dependency: E2 level refinement further reduces wasted evaluation.
- Risk: Medium (many sites; per-pointer path). Covered by gesture tests.

---

## Phase F: Performance (can be done without D1)

Extract performance items from issue 5 that can be fixed standalone, without
waiting for D1 (RenderObject migration).

### F1. Clean up `_nodeViews`/`_nodeKeys`/`_linkKeys` on node/link removal
- Location: `lib/src/graph_view/widget/graph.dart` (`_nodeKeys:226`,
  `_nodeViews:227`, `_linkKeys:230`)
- Current: `clear()` on these maps is done in bulk (around line 344); individual
  `remove` on node/link deletion is missing → maps grow without bound (leak).
- Fix: remove the corresponding key when a node or link is deleted. Same
  "cleanup on deletion" category as A1; **implement at the same time**.
- Acceptance: test showing that the maps do not grow monotonically when nodes
  are added and removed repeatedly.
- Risk: Low.
- Dependency: best done alongside A1.

### F2. Replace `_BaseLinkRendererPainter.shouldRepaint => true`
- Location: `lib/src/renderer/widget/link.dart:194`
- Current: always returns true, forcing a repaint every frame.
- Fix: implement geometry/style comparison in `shouldRepaint`.
- Acceptance: goldens unchanged. Reduced unnecessary repaints verified by code
  review.
- Risk: Medium (a missed comparison causes insufficient repaints). Covered by
  goldens.

### F3+. Rebuild-scope reduction and sort cache
- Target: full-tree rebuild from `AnimatedBuilder` wrapping everything; sort
  cache invalidated every frame by `_markSortDirty` (`graph.dart:559`); spatial
  grid does not cover links.
- Strategy: poor cost-benefit and high regression risk in isolation. **Merge
  into D1** and design them together.
- Dependency: D1.
- **Carry-over (removal review [R1])**: `_pruneRemovedEntityCaches()` (F1)
  works correctly only because `_markSortDirty()` every build causes `elements`
  to be reconstructed every time. When fixing sort-cache invalidation, **align
  the data source for prune (`_graph.nodes/links`) with the data source for
  `elements`**, ideally driving both from deletion events. A mismatch causes
  prune to see the latest graph while `elements` holds a stale cache.

---

## Recommended Implementation Order

Reflecting the corrections from the review (`design_review_plan_feedback.md`):

```
1.  E1 (log lazy-init)                          ← done (2d6c4c0/b20fee2)
2.  Deletion-path cleanup: A1 + A2 + A8 (+ F1)  ← done (e63c302)
3.  A7 (delete dead enhanced_client.dart)        ← done (2fad4b2)
4.  A3, A4, A5, A6                              ← done (bcce23d, e56b4e3)
5.  B1 (remove flame / fix .first dependency)   ← done (31d8d07)
    B3 (value-equality survey)                  ← done (equatable deleted)
6.  B2 (debug separate package)
    - B2-a (DebugSink injection point; behavior unchanged) ← done (493f209)
    - B2-b (move to plough_devtools; remove http; web safe) ← done (8a56176)
7.  F2 (shouldRepaint)                          ← done (47615aa)
8.  C1 (selection single source → absorbs A4)   ← done (8adc717 + 013f872)
9.  D1 RFC + PoC / D2 (FSM)                     ← after A/B; after design review
10. C2 (NodeViewState; subordinate to D1)        ← after D1 PoC
```

Key changes from the review:
- A7/A8/F1 added. A1 area grouped as "deletion-path cleanup" (one PR; separate
  test items).
- B2 prerequisite on E1 made explicit. Strategy confirmed as (c) separate
  package.
- A4 positioned as a stopgap absorbed by C1.
- B1 extended to remove `intersections.first` dependency.
- F2 (shouldRepaint) added as a standalone performance task. F3+ merged into D1.

Short-term (behavior-preserving): E1, A1–A8 (including A7/A8), B1, B3, F1
Medium-term: B2, C1, F2
Long-term (v2): D1, D2, C2, F3+

---

## Tracking Table

| ID  | Category    | Summary                                                  | Risk   | Depends | Status |
|-----|-------------|----------------------------------------------------------|--------|---------|--------|
| E1  | Short-term  | Add closure overload to log API + lazy-init hot paths    | Low–Med | —      | **Done** (2d6c4c0/b20fee2) |
| A1  | Bug         | `removeNode` clean up connected links                    | Low    | —       | **Done** (e63c302) |
| A2  | Bug         | Delete dead field `_nodeDependencies`                    | Low    | A1      | **Done** (e63c302) |
| A3  | Bug         | `reverseLink` notify + re-index                          | Med    | —       | **Done** (bcce23d) |
| A4  | Bug         | `deselectNode` state/flag divergence (stopgap)           | Low–Med | —      | **Done** (bcce23d) |
| A5  | Bug         | `KeyedSubtree` key: hashCode → graph.id                  | Low    | —       | **Done** (bcce23d) |
| A6  | Minor       | Name default link thickness constant                     | Low    | —       | **Done** (e56b4e3) |
| A7  | Dead code   | Delete `enhanced_client.dart` (unreferenced, http)       | Low    | —       | **Done** (2fad4b2) |
| A8  | Bug         | `removeLink` missing `_notifyLayoutChange()`             | Low–Med | A1     | **Done** (e63c302) |
| B1  | Dependency  | Remove flame / fix `.first` dependency                   | Med    | —       | **Done** (31d8d07) |
| B2  | Dependency  | Separate debug stack into `plough_devtools`              | High   | E1      | **Done**: B2-a (493f209) / B2-b stage1 (b9c6ead) / B2-b stage2 — move + remove http + web safe (8a56176) |
| B3  | Survey      | Value-equality survey (+ delete unused equatable)        | Low    | —       | **Done** (equatable deleted; survey in `doc/value_equality_survey_B3.md`) |
| F1  | Performance | Clean up view/key maps on node/link removal              | Low    | A1      | **Done** (e63c302) |
| F2  | Performance | Compare-based `shouldRepaint` for link painter           | Med    | —       | **Done** (47615aa) |
| C1  | Medium-term | Single source of truth for selection (absorbs A4)        | High   | A4      | **Done** (8adc717 + 013f872): `isSelected` derived; [R1] divergence closed; `force:true` removed; `removeNode`/`removeLink` clean up stale selected ids |
| C2  | Long-term   | Separate `NodeViewState` from `GraphNode`                | V.High | C1, D1  | Design note created (`doc/c2_node_view_state_design.md`). Implementation deferred until after D1 PoC; mandatory re-review before starting. |
| D1  | Long-term   | RenderObject migration RFC + PoC                         | Max    | A, B    | RFC draft created (`doc/rfc_render_graph_view.md`). Implementation deferred until PoC is agreed. |
| D2  | Long-term   | Consolidate GestureManager into per-pointer FSM          | High   | E1      | Characterization tests complete (D2-pre: e5d277b + d8f5449). FSM body not started. **Known bug**: background tap does not deselect a selected link (asymmetric; also corrupts node background-deselect in subsequent interactions). Fix is a D2 acceptance criterion. |
| E2  | Short-term  | Level-aware `enabled` refinement ([S3])                  | Low    | —       | **Done** (40eb44c) |
| E3  | Short-term  | Lazy Map construction in `handlePointerDown`/`Up` ([S4]) | Med    | E2      | **Done** (40eb44c): `handlePanStart` sites out of scope |
| F3+ | Performance | Reduce rebuild scope; sort cache                         | High   | D1      | Merged into D1 RFC (`doc/rfc_render_graph_view.md` §2.2/§2.3). Implement alongside D1. |
