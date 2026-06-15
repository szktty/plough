# RFC: RenderObject Migration for GraphView (D1)

Status: **Draft (not yet implemented)**
Created: 2026-06-14
Task: **D1** in `doc/design_review_plan.md` (highest risk)
Prerequisite: Phases A and B complete. This RFC is a design document to inform
the PoC decision; implementation follows only after this document is approved.

---

## 1. Background and Problem

The current `GraphView` uses standard Flutter widget composition together with
post-frame callbacks to drive the layout → geometry read-back → repaint cycle.
This causes several problems:

- **Post-frame bootstrap** (issue 1): After `performLayout`, geometry is read
  back in a post-frame callback using `GlobalKey` to obtain child sizes and
  positions, followed by a three-phase `_buildState` and
  `refreshAllNodeGeometry` to rebuild the spatial index for hit-testing. This
  multi-stage pipeline introduces one-frame delays and is a persistent source of
  timing-dependent bugs.
- **Performance ceiling** (issue 5): `AnimatedBuilder` wraps the entire tree and
  triggers a full rebuild every frame; `_markSortDirty` is called every frame,
  invalidating the sort cache; the spatial grid does not cover links.
- **Hand-written coordinate transforms**: The viewport `Transform` requires
  manual implementations of `screenToScene`, `globalToScene`, and
  `dragDeltaTransform`. Known gotchas related to zoom delta correction follow
  from this approach.

### Related Known Gotchas (from memory)
- **drag-end-spatial-index-refresh**: The post-frame `refreshAllNodeGeometry`
  call in `handleDragEnd` must not be removed — removing it breaks hit-testing
  after a drag.
- **node-geometry-no-scale-divide**: Even inside a `Transform`, `renderBox.size`
  is in logical coordinates. Rebuilding during a zoom shrinks bounds, breaking
  hit-testing and link endpoints.
- **viewport-drag-delta-and-handler-swap**: During a zoom, the drag delta must
  be divided by the scale factor, among other adjustments.
- **viewport-hittest-ownership**: Pointer reception is placed outside the
  `Transform` and a `screenToScene` conversion is applied.

All of these are consequences of implementing layout, geometry, coordinate
transforms, and hit-testing by hand across multiple stages. D1 investigates
whether migrating to `RenderObject` can principally eliminate these issues.

---

## 2. Proposed Structure

Migrate to `MultiChildRenderObjectWidget` with a custom `RenderBox`
(tentatively called `RenderGraph`).

### 2.1 Layout
- Call `child.layout(constraints, parentUsesSize: true)` for each child (node
  widget) inside `performLayout` to **obtain child sizes in the same frame**.
  → Eliminates post-frame geometry read-back, `GlobalKey`, three-phase
  `_buildState`, and `refreshAllNodeGeometry`.
- Store node positions (logical coordinates determined by
  `GraphLayoutStrategy.performLayout`) in `BoxParentData` or a dedicated
  `ParentData` subclass.

### 2.2 Painting
- Draw links directly inside `RenderGraph.paint()`, consolidating the current
  `CustomPainter` classes.
- Paint node children via `context.paintChild`.
- Express z-order through paint order.

### 2.3 Hit-testing
- Delegate node hit-testing to the RenderObject machinery via
  `hitTestChildren`.
  → Evaluate in the PoC whether this can replace part of the hand-written
  spatial index. (Link hit-testing requires separate consideration.)

### 2.4 Viewport / Transform
- Route viewport zoom/pan through the `applyPaintTransform` + `hitTest`
  Matrix4 mechanism, eliminating hand-written
  `screenToScene`/`globalToScene`/`dragDeltaTransform`.
  → Confirm in the PoC whether **node-geometry-no-scale-divide** and
  **viewport-drag-delta-and-handler-swap** resolve naturally through the
  RenderObject coordinate system.

---

## 3. PoC Scope and Acceptance Criteria

**PoC**: A minimal `RenderGraph` prototype with a few nodes and one link.

Acceptance criteria:
- Geometry is available without post-frame callbacks (child sizes confirmed in
  the same frame).
- Tap, drag, and zoom behave equivalently to the current implementation
  (reuse and extend `gesture_manager_characterization_test.dart`).
- **Link `hitTestSelf` hits via segment-distance testing**: Nodes are handled
  by `hitTestChildren`, but links are not children of the render tree and
  require separate `hitTestSelf` + segment-distance logic. This is the most
  uncertain part of the PoC, so "link hit-testing works" must be an explicit
  acceptance criterion.
- Confirm that the four known gotchas above do not reproduce (or are resolved)
  under the PoC structure.

**No-go condition**: If any of the above shows that the RenderObject mechanism
is more complex than the current hand-written approach, or if a gotcha
reappears in a different form, hold the staged migration and instead pursue
F3+ (rebuild-scope reduction and sort cache) as a standalone prior step.

Once the PoC validates the approach, proceed with **staged migration**:
node rendering → link rendering → hit-testing → viewport.

---

## 4. Risks and Verification Items

Risk: **Maximum**. The PoC must resolve the following:

1. **Post-drag hit-testing** (drag-end-spatial-index-refresh): Does
   `hitTestChildren` still hit the correct child positions after a drag?
2. **Zoom-time bounds / link endpoints** (node-geometry-no-scale-divide): Does
   the coordinate system remain consistent (logical vs. physical) through
   `applyPaintTransform`?
3. **Drag delta zoom correction** (viewport-drag-delta-and-handler-swap): Does
   the Matrix4 inverse transform in `hitTest` naturally produce delta in scene
   coordinates?
4. **Hit-test ownership** (viewport-hittest-ownership): Does the RenderObject
   mechanism cleanly separate the responsibility for pointer reception and scene
   transform?
5. **Link hit-testing**: Nodes are handled by `hitTestChildren`, but links
   (painted outside the child tree) require `hitTestSelf` + segment-distance
   detection.

---

## 5. Dependencies and Order

- Begin after Phases A and B are complete (both complete). **Design in parallel
  with Phase C**.
- **C2 (NodeViewState separation) is subordinate to D1**: D1 determines where
  geometry is stored (ParentData or a separate map). Starting C2 first risks
  rebuilding the storage structure in D1, duplicating work. See
  `doc/c2_node_view_state_design.md`.
- **F3+ (rebuild-scope reduction, sort cache) is merged into D1**: Eliminating
  the `AnimatedBuilder` full-tree wrap, sort caching, and spatial-grid link
  support are designed together with the RenderObject migration (covered in
  §2.2 and §2.3 of this RFC).

---

## 6. Conclusion (Current State)

D1 carries maximum risk. **A review of this RFC and agreement on the PoC plan
are required before any implementation begins.** The current session produces
only the RFC draft; implementation is deferred. The next step is: "Prototype
the PoC on a separate branch → measure whether the four gotchas reproduce or
resolve → decide whether to proceed with staged migration."
