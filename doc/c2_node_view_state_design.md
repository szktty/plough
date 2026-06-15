# Design Note: Separating NodeViewState from GraphNode (C2)

Status: **Draft (not yet implemented — mandatory re-review before starting)**
Created: 2026-06-14
Task: **C2** in `doc/design_review_plan.md` (highest risk)
Dependency: **Subordinate to D1** (see `doc/rfc_render_graph_view.md`).
C1 is complete.

---

## 1. Background and Problem (Issues 2–4)

`GraphNode` (the model) currently co-locates **View state**:
- `ValueNotifier` fields around `node.dart:63–75`: `_geometry`,
  `_animatedPosition`, `_isAnimating`, `_isAnimationCompleted`,
  `_animationStartPosition`, `_logicalPosition`, `_stackOrder`.
- Derived properties: `isArranged`, `animatedPosition`, `stackOrder`, etc.

These fields represent **View-specific state** — "how a given Graph is rendered
in a given GraphView" — and are distinct from pure graph data (id, properties,
weight, canSelect, …). Co-locating them causes two concrete problems:

- **A single `Graph` cannot be displayed in two `GraphView` instances
  simultaneously**: each piece of geometry (bounds, animated position, etc.)
  belongs to exactly one node, so two views would fight over the same fields.
- Model and rendering state are tightly coupled, making testing and reuse
  harder.

> Note: In C1, selection state (`isSelected`) was already separated into a
> derived getter backed by `GraphData.selectedNodeIds` (single source of truth).
> Selection belongs to the **graph**, so keeping it on the model side is
> correct. C2 targets **View state** (geometry/animation/stackOrder) and moves
> in the opposite direction: out of the model and into the View layer.

---

## 2. Proposed Separation

1. Reduce `GraphNode` to **pure data**: id, properties, weight, canSelect,
   canDrag, visible, isEnabled, and other model attributes only.
2. Hold `Map<GraphId, NodeViewState>` on the `GraphView` side. `NodeViewState`
   encompasses: geometry, animatedPosition, isAnimating, animationStartPosition,
   logicalPosition, stackOrder, isArranged.
3. **Redirect all geometry references** in layout, rendering, and gesture code
   to the View-side state.
4. Maintain consistency with the reverseLink invariants already handled in A3
   (notify/index swap).

---

## 3. Acceptance Criteria

- Add a **widget test that mounts the same `Graph` in two `GraphView` instances
  side-by-side** and verify that an operation on one view (e.g. dragging a
  node) does not corrupt the other view's geometry.
- Existing layout, gesture, and golden tests remain green.

---

## 4. Why C2 is Subordinate to D1 (Order of Operations)

The **location, coordinate system, and hit-test path for geometry** are
determined by D1 (RenderObject migration):
- D1 may store node positions in `ParentData`. If that happens, a
  `NodeViewState.geometry` field would duplicate the `ParentData` storage.
- The correct order is: **D1 decides who owns geometry, then C2 fills that
  container with `NodeViewState`**. Starting C2 first means rebuilding the
  storage structure when D1 arrives, doubling the work.

Therefore: begin C2 only after **C1 is complete (done) and D1 direction is
confirmed**.

---

## 5. Risks and Known Gotchas

Risk: **Very high**. Moving geometry ownership to the View side directly
intersects the following known gotchas:
- **node-geometry-no-scale-divide**: Confusing logical vs. physical coordinate
  systems in geometry breaks hit-testing and link endpoints.
- **viewport-hittest-ownership**: The responsibility for pointer reception and
  scene transformation.
- **drag-end-spatial-index-refresh**: Timing of geometry reconstruction after a
  drag ends.

When `Map<GraphId, NodeViewState>` takes ownership of geometry, every one of
these paths must be rewired. The regression surface is wide.

---

## 6. Conclusion (Current State)

C2 carries maximum risk and is **subordinate to D1 with a mandatory re-review
before starting**. This session produces only the design note; no implementation
is performed. Once the D1 PoC establishes where geometry will be stored, update
this note and re-review before deciding whether to proceed.
