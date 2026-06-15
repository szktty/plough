## develop

### Design review — bug fixes, architecture, and performance

**Bug Fixes**
- [FIX] `removeNode` now removes connected links from the `links` map; previously orphaned link entries remained and could be used as render targets.
- [FIX] `removeLink` now calls `_notifyLayoutChange()`; previously removing a link was not reflected in the UI or layout.
- [FIX] `reverseLink` now notifies listeners and re-indexes the adjacency maps (`_incomingIndex`/`_outgoingIndex`); previously the direction swap was invisible to the UI.
- [FIX] `deselectNode`/`deselectLink` no longer diverges `isSelected` flag and `selectedNodeIds` when called on an already-unselected entity.
- [FIX] `KeyedSubtree` key changed from `graph.hashCode` to `graph.id` to prevent collisions on graph swap.
- [FIX] `removeNode`/`removeLink` now clean stale ids from `selectedNodeIds`/`selectedLinkIds`; previously stale ids caused `ArgumentError` in `selectedNodes`/`selectedLinks`.

**Performance**
- [IMPROVE] Link painter `shouldRepaint` now compares geometry and style fields instead of unconditionally returning `true`, reducing unnecessary repaints.
- [IMPROVE] View/key maps (`_nodeViews`, `_nodeKeys`, `_linkKeys`) are now cleaned up when a node or link is removed, eliminating an unbounded memory leak.
- [IMPROVE] Log API extended to accept `Object message` (both `String` and `String Function()`); gesture-manager hot paths now pass closures so string construction is skipped when logging is off. Level-aware `enabled(category, level)` guard added.

**Architecture / Internal**
- [REFACTOR] Selection state unified: `node.isSelected`/`link.isSelected` are now derived getters backed by `GraphData.selectedNodeIds`/`selectedLinkIds`; manual dual-sync code and `force: true` removed.
- [REFACTOR] Debug stack abstracted behind `DebugSink`/`DebugBackend` no-op defaults; the heavyweight `dart:io`/`http` implementation moved to a separate `plough_devtools` package. The core package is now web-safe and no longer depends on `http`.
- [REFACTOR] `flame` dependency removed; segment × circle and segment × rectangle intersection logic is now implemented internally.
- [CLEANUP] Dead file `enhanced_client.dart` (unreferenced) and dead field `_nodeDependencies` (never read) removed.
- [CLEANUP] Default link thickness extracted to a named constant (was a magic number `30` with a TODO comment).

**Testing**
- [TEST] Gesture manager characterization tests expanded to cover link tap/drag, drag lifecycle (pan produces drag-update events, not tap), drag-end does not toggle selection, and concurrent pointer reentrancy.
- [TEST] Selection single-source tests added covering stale-id removal on node/link deletion, `canSelect` divergence, and derived `isSelected` consistency.

---

- [FIX] `GraphCircle.getLineIntersections`: fixed incorrect `CircleComponent` position that caused link arrow endpoints to land outside the circle boundary when the specified `radius` differs from half the node's bounding-box width.
- [ADD] `GraphViewport` widget: pan and pinch-to-zoom support built into plough, eliminating the need to wrap `GraphView` in Flutter's `InteractiveViewer`.
- [ADD] `GraphViewportController`: `ValueNotifier<Matrix4>`-based controller with `pan()`, `zoomAt()`, `reset()`, and `animateTo()` for programmatic viewport control.
- [ADD] `minScale` / `maxScale` parameters on both `GraphViewport` and `GraphViewportController` to clamp the zoom range.
- [ADD] `enablePan` / `enableZoom` flags on `GraphViewport` to selectively disable gesture types.
- [ADD] `GraphViewportCanvasMode` (`bounded` / `infinite`) on `GraphViewport` and `GraphView`. In `bounded` the canvas stays the initial viewport size and pan is clamped; in `infinite` nodes can be placed and dragged anywhere and the scene pans freely.
- [ADD] `GraphViewportController.setScale()` to change zoom while preserving the current pan offset.
- [FIX] Hit-testing now works correctly at any pan/zoom level: pointer reception was moved outside the viewport's `Transform`, so nodes panned outside the initial viewport rectangle (in `infinite` mode) remain tappable and draggable.
- [FIX] Dragging a node through a `GraphViewport` now moves the node instead of doing nothing, and no longer overshoots the pointer on the frame the drag starts.
- [FIX] Panning the viewport with a background drag no longer clears the current selection; only a background tap deselects.
- [FIX] Resolved a `setState() called during build` exception that could be thrown when another widget (e.g. a `GraphViewport` or an overlay) listened to the same graph while a layout ran; the layout-finished notification is now dispatched after the frame.
- [IMPROVE] Example app updated to use `GraphViewport` with `GraphGestureMode.nodeEdgeOnly`, plus a "Reset View" toolbar button.

## 0.8.0

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
