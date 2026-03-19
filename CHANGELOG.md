## develop

- [ADD] Smooth force-directed layout animation: nodes now visibly scatter from random positions and settle into place each time the graph is displayed, using a Ticker-driven incremental simulation instead of a single synchronous computation.
- [ADD] `GraphForceDirectedLayoutStrategy.stepsPerFrame` parameter to control animation speed vs. smoothness (default: 3 iterations per frame).
- [IMPROVE] Force-directed repulsion calculation upgraded from O(n²) to O(n log n) using a Barnes-Hut quadtree. New `barnesHutTheta` parameter (default: 0.5) controls approximation accuracy.
- [IMPROVE] `getIncomingLinks` / `getOutgoingLinks` now O(1) via adjacency index maintained on `addLink` / `removeLink` / `removeNode`.
- [IMPROVE] Stack-order sort result is cached and only recomputed when the order actually changes, eliminating a per-frame O(n log n) sort.
- [IMPROVE] `GraphNodeView` flattened from three nested `AnimatedBuilder` wrappers to one, reducing widget tree depth per node.
- [IMPROVE] Spatial grid index added to `GraphGestureManager` for fast node hit-testing; rebuilt after each layout change.
- [ADD] Large-graph sample scenes (200 / 300 / 500 nodes) in the example app for performance testing.

## 0.7.1

- [FIX] Fixed `nodeAnimationStartPosition` being ignored during initial layout, causing nodes to animate from top-left corner instead of the specified position.
- [CHANGE] Upgraded `freezed_annotation` to ^3.1.0 and `freezed` (dev) to ^3.2.5.

## 0.7.0

- [CHANGE] Removed `Listenable` from `GraphEntity` to prevent direct observation of individual entity state changes.
- [CHANGE] Removed `apps` directory as the `workbench` application has been migrated to an independent repository.
- [CHANGE] Increased `touchSlop` tolerance for more forgiving tap detection.
- [CHANGE] Standardized `touchSlop` values to `kTouchSlop * 4` in `GraphGestureManager`'s `_isWithinSlop` method and `_TapState` for improved gesture detection consistency.
- [ADD] Unified `GraphViewBehavior` interaction callbacks (e.g., `onTap`, `onDragStart`, `onSelectionChange`) using new `GraphEvent` objects (`GraphTapEvent`, `GraphDragStartEvent`, `GraphSelectionChangeEvent`, etc. from `lib/src/interactive/events.dart`). This replaces separate node/link specific callbacks (like `onNodeTap`, `onLinkTap`) and simplifies handling events involving multiple entities.
- [ADD] `Graph.clearSelection()` now deselects all selected entities.
- [ADD] Added `padding` parameter to `GraphDefaultNodeRendererStyle` to allow setting padding between a node's border and its content.
- [ADD] Added `onDoubleTap` callback to `GraphViewBehavior`.
- [FIX] Improved double-tap detection reliability by introducing a Pan Ready state to prevent tap timers from being cancelled prematurely during drag starts, leading to more accurate distinction between taps and drags.
- [FIX] Resolved a race condition with `Timer(Duration.zero)` during double-tap state cleanup, enhancing gesture detection stability.

## 0.6.0

First release.
