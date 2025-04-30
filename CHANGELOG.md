## develop

- [CHANGE] Removed `Listenable` from `GraphEntity` to prevent direct observation of individual entity state changes.
- [ADD] Unified `GraphViewBehavior` interaction callbacks (e.g., `onTap`, `onDragStart`, `onSelectionChange`) using new `GraphEvent` objects (`GraphTapEvent`, `GraphDragStartEvent`, `GraphSelectionChangeEvent`, etc. from `lib/src/interactive/events.dart`). This replaces separate node/link specific callbacks (like `onNodeTap`, `onLinkTap`) and simplifies handling events involving multiple entities.

## 0.6.0

First release.
