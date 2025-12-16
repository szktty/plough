## develop

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
