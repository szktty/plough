# Architecture Details

This document provides a detailed overview of the key architectural components and design decisions for the Plough project. It is intended to be a reference for developers and AI agents who need a deeper understanding of the system's internals.

---

## Interaction System Implementation Details

This section provides detailed technical documentation for the interaction system in `lib/src/interactive/`.

### Architecture Overview

The interaction system implements a sophisticated event-driven architecture with:
- **GraphGestureManager**: Central coordinator orchestrating all gesture handling
- **Specialized State Managers**: Individual managers for tap, drag, hover, and tooltip
- **Event System**: Type-safe events for communicating gesture results
- **Debug System**: Comprehensive debugging and telemetry capabilities

### Low-Level Gesture API Usage

The interaction system deliberately uses low-level Flutter gesture APIs (`MouseRegion`, `Listener`, `RawGestureDetector`) instead of the high-level `GestureDetector` widget.

**Why Low-Level APIs?**
- **Performance**: `GestureDetector` introduces noticeable latency due to its gesture disambiguation logic
- **Direct Control**: Low-level APIs provide immediate access to pointer events without delays
- **Precise Timing**: Critical for responsive graph interactions where milliseconds matter
- **Custom Hit Testing**: Enables per-gesture hit test customization

**API Stack**:
```dart
MouseRegion      // Mouse hover events
    ↓
Listener         // Raw pointer events (down/up/move)
    ↓
RawGestureDetector  // Custom gesture recognizers
```

This architecture ensures the most responsive possible interaction experience.

### Gesture Detection Algorithms

#### Tap Detection (`tap_state.dart`)

**Algorithm and Thresholds**:
- **Touch Slop**: `kTouchSlop * 8` (64 pixels on most devices) for highly forgiving tap recognition
- **Double Tap**: 500ms timeout between taps, uses `kDoubleTapSlop` for position tolerance
- **State Tracking**: Tracks entityId, positions, timestamps, and completion status

**Detection Flow**:
1. Pointer down → Create/update tap state with position and time
2. Pointer up → Validate movement within slop, mark completed if valid
3. Timer (500ms) → Distinguish single vs double tap
4. Cancellation → Drag movement beyond drag threshold cancels tap

**Callback Timing**:
- `onTap(GraphTapEvent)` - Called immediately after pointer up when tap is valid
  - Parameters: entityIds, tapCount (1 or 2), pointer details

#### Drag Detection with Pan Ready State (`pan_ready_state.dart`, `drag_state.dart`)

**Pan Ready State Algorithm**:
- **Drag Threshold**: 8.0 pixels movement to trigger actual drag start
- **Max Ready Duration**: 200ms timeout to prevent stuck states
- **State Separation**: Distinguishes between "ready to drag" and "actively dragging"

**Improved Detection Flow**:
1. Pointer down → Create tap state
2. Pan start → Create Pan Ready state (not actual drag yet)
3. Pan update → Check movement distance against 8px threshold
4. Distance ≥ 8px → Cancel tap, start actual drag, trigger onDragStart
5. Distance < 8px → Maintain Ready state, keep tap possibility alive

**Features and Behavior**:
- Solves Flutter's limitation where `pan start` fires immediately on `pointer down`
- Prevents accidental drag detection from minor finger movements
- Enables proper double-tap functionality by delaying drag commitment
- Automatically stops node animations only when actual drag starts
- Link dragging explicitly disabled

**State Management**:
- **Pan Ready State**: Tracks entityId, start position, start time, drag readiness
- **Actual Drag State**: Tracks start position, initial logical position, current position
- Maintains state throughout gesture lifecycle with automatic cleanup

**Callback Timing**:
- `onDragStart(GraphDragStartEvent)` - Called only when movement exceeds 8px threshold
  - Parameters: entityIds, start position details
- `onDragUpdate(GraphDragUpdateEvent)` - Called for each pan update after drag starts
  - Parameters: entityIds, current position, delta from last update
- `onDragEnd(GraphDragEndEvent)` - Called when pan gesture ends
  - Parameters: entityIds, end position details

#### Hover Detection (`hover_state.dart`)

**Implementation**:
- Single entity hover at a time
- Simple state with just entityId
- Automatic cancellation on pointer down
- Clean transitions between hover states

**Callback Timing**:
- `onHoverEnter(GraphHoverEvent)` - Called when mouse enters entity bounds
  - Parameters: entityId, mouse position details
- `onHoverMove(GraphHoverEvent)` - Called when mouse moves within entity
  - Parameters: entityId, current mouse position
- `onHoverEnd(GraphHoverEndEvent)` - Called when mouse exits entity
  - Parameters: entityId, exit position details

#### Tooltip Management (`tooltip_state.dart`)

**Sophisticated Timing Logic**:
- **Trigger Modes**: hover, hoverStay, tap, longPress, doubleTap
- **Default Delays**: 500ms show, 200ms hide
- **Smart Behavior**: Different timing for different triggers
- **State Machine**: Tracks visibility, timers, and transitions

**Callback Timing**:
- `onTooltipShow(GraphTooltipShowEvent)` - Called after show delay expires
  - Parameters: entityId, trigger position, trigger mode
- `onTooltipHide(GraphTooltipHideEvent)` - Called after hide delay expires
  - Parameters: entityId, optional hide position

### Coordinate Systems and Hit Testing

**Hit Test Flow**:
```
Global Position → findNodeAt/findLinkAt → Order-aware search → Frontmost entity
```

**Gesture Priority Rules**:
1. Nodes have priority over links at same position
2. Frontmost entity (highest z-order) selected
3. Background gestures only when no entity hit

### Event Flow Architecture

```
Pointer Event
    ↓
GraphGestureManager (coordinates)
    ↓
State Managers (update states)
    ↓
Event Dispatch (notify listeners)
    ↓
Behavior Callbacks (UI updates)
```

### Gesture Detection Flow Diagrams

#### Single Tap Flow

```mermaid
sequenceDiagram
    participant User
    participant InteractiveOverlay
    participant GestureManager
    participant TapState
    participant GraphBehavior

    User->>InteractiveOverlay: Pointer Down
    InteractiveOverlay->>GestureManager: handlePointerDown()
    GestureManager->>GestureManager: Hit test entity
    GestureManager->>TapState: Create tap state
    Note over TapState: Store position, time, entityId

    User->>InteractiveOverlay: Pointer Up (within slop)
    InteractiveOverlay->>GestureManager: handlePointerUp()
    GestureManager->>TapState: Validate tap (slop check)
    TapState->>TapState: Mark completed
    GestureManager->>GestureManager: Start 200ms timer
    
    Note over GestureManager: Wait for potential double tap
    GestureManager->>GraphBehavior: onTap(GraphTapEvent)
    GestureManager->>GraphBehavior: onSelectionChange()
```

#### Double Tap Flow

```mermaid
sequenceDiagram
    participant User
    participant InteractiveOverlay
    participant GestureManager
    participant TapState
    participant GraphBehavior

    User->>InteractiveOverlay: First Pointer Down
    InteractiveOverlay->>GestureManager: handlePointerDown()
    GestureManager->>TapState: Create tap state (count: 1)

    User->>InteractiveOverlay: First Pointer Up
    InteractiveOverlay->>GestureManager: handlePointerUp()
    GestureManager->>GestureManager: Start 200ms timer

    User->>InteractiveOverlay: Second Pointer Down (within 200ms)
    InteractiveOverlay->>GestureManager: handlePointerDown()
    GestureManager->>TapState: Update tap state (count: 2)

    User->>InteractiveOverlay: Second Pointer Up
    InteractiveOverlay->>GestureManager: handlePointerUp()
    GestureManager->>TapState: Validate double tap
    GestureManager->>GraphBehavior: onTap(GraphTapEvent, tapCount: 2)
```

#### Drag Flow

```mermaid
sequenceDiagram
    participant User
    participant InteractiveOverlay
    participant GestureManager
    participant DragState
    participant TapState
    participant GraphBehavior
    participant GraphNode

    User->>InteractiveOverlay: Pointer Down
    InteractiveOverlay->>GestureManager: handlePointerDown()
    GestureManager->>TapState: Create tap state

    User->>InteractiveOverlay: Pan Start (exceeds drag threshold)
    InteractiveOverlay->>GestureManager: handlePanStart()
    GestureManager->>TapState: Cancel tap state
    GestureManager->>DragState: Create drag state
    GestureManager->>GraphNode: Stop animations
    GestureManager->>GraphBehavior: onDragStart(GraphDragStartEvent)

    loop Pan Updates
        User->>InteractiveOverlay: Pan Update
        InteractiveOverlay->>GestureManager: handlePanUpdate()
        GestureManager->>DragState: Update positions
        GestureManager->>GraphNode: Update node position
        GestureManager->>GraphBehavior: onDragUpdate(GraphDragUpdateEvent)
    end

    User->>InteractiveOverlay: Pan End
    InteractiveOverlay->>GestureManager: handlePanEnd()
    GestureManager->>DragState: Clean up state
    GestureManager->>GraphBehavior: onDragEnd(GraphDragEndEvent)
```

#### Hover and Tooltip Flow

```mermaid
sequenceDiagram
    participant User
    participant InteractiveOverlay
    participant GestureManager
    participant HoverState
    participant TooltipState
    participant GraphBehavior

    User->>InteractiveOverlay: Mouse Enter Entity
    InteractiveOverlay->>GestureManager: handleMouseHover()
    GestureManager->>GestureManager: Hit test entity
    GestureManager->>HoverState: Set hover state
    GestureManager->>GraphBehavior: onHoverEnter(GraphHoverEvent)
    GestureManager->>TooltipState: Start show timer (500ms)

    loop Mouse Move within Entity
        User->>InteractiveOverlay: Mouse Move
        InteractiveOverlay->>GestureManager: handleMouseHover()
        GestureManager->>GraphBehavior: onHoverMove(GraphHoverEvent)
    end

    Note over TooltipState: 500ms delay expires
    TooltipState->>GraphBehavior: onTooltipShow(GraphTooltipShowEvent)

    User->>InteractiveOverlay: Mouse Exit Entity
    InteractiveOverlay->>GestureManager: handleMouseHover()
    GestureManager->>HoverState: Clear hover state
    GestureManager->>GraphBehavior: onHoverEnd(GraphHoverEndEvent)
    GestureManager->>TooltipState: Start hide timer (200ms)
    
    Note over TooltipState: 200ms delay expires
    TooltipState->>GraphBehavior: onTooltipHide(GraphTooltipHideEvent)
```

#### Background Tap Flow

```mermaid
sequenceDiagram
    participant User
    participant InteractiveOverlay
    participant GestureManager
    participant GraphBehavior

    User->>InteractiveOverlay: Pointer Down (no entity hit)
    InteractiveOverlay->>GestureManager: handlePointerDown()
    GestureManager->>GestureManager: Hit test (no entity found)
    Note over GestureManager: No tap state created

    User->>InteractiveOverlay: Pointer Up
    InteractiveOverlay->>GestureManager: handlePointerUp()
    GestureManager->>GestureManager: Background tap detected
    GestureManager->>GraphBehavior: onBackgroundTapped()
    GestureManager->>GestureManager: Deselect all entities
    GestureManager->>GraphBehavior: onSelectionChange(deselectedIds: all)
```

<h3>Key Algorithms</h3>

<h4>Touch Slop Validation (Tap Detection)</h4>
```dart
bool _isWithinTapSlop(Offset p1, Offset p2) {
  final distanceSquared = (p1 - p2).distanceSquared;
  return distanceSquared < touchSlop * touchSlop; // touchSlop = kTouchSlop * 8
}
```

<h4>Drag Threshold Validation (Pan Ready State)</h4>
```dart
void handlePanUpdate(GraphId entityId, DragUpdateDetails details) {
  final distance = (details.localPosition - state.startPosition).distance;
  
  if (distance >= dragStartThreshold) { // dragStartThreshold = 8.0px
    // Threshold exceeded → actual drag started
    _startActualDrag(entityId, state, details);
  }
}
```

<h4>Gesture Consumption Logic</h4>
```dart
switch (gestureMode) {
  case GraphGestureMode.exclusive:
    return true; // Always consume
  case GraphGestureMode.nodeEdgeOnly:
    return hitTestResult.hasEntity; // Only if entity hit
  case GraphGestureMode.transparent:
    return false; // Never consume
  case GraphGestureMode.custom:
    return shouldConsumeGesture?.call(position, hitTestResult) ?? true;
}
```

<h3>State Management Details</h3>

**Base State Manager (`state_manager.dart`)**:
- Generic `GraphStateManager<T>` for type-safe state storage
- Entity type awareness (nodes vs links)
- Silent state removal to prevent unnecessary rebuilds
- Bulk operations for performance

**Selection Management**:
- Toggle selection on tap completion
- Batch selection changes for efficiency
- Dispatch consolidated selection events

**Callback Timing**:
- `onSelectionChange(GraphSelectionChangeEvent)` - Called after selection state changes
  - Parameters: selectedIds, deselectedIds, currentSelectionIds, optional pointer details
  - Triggered by: tap completion, background tap (deselect all), programmatic selection

<h3>Performance Optimizations</h3>

1. **Touch Target Forgiveness**: 8x standard slop (64px) for highly forgiving tap recognition
2. **Pan Ready State**: Delayed drag commitment prevents false positives and enables double-tap
3. **Drag Threshold**: 8px movement threshold prevents accidental drag detection
4. **State Isolation**: Separate managers prevent conflicts between gestures
5. **Event Batching**: Reduces rebuild frequency for selection changes
6. **Silent Operations**: Avoid triggering rebuilds when cleaning up states
7. **Animation Control**: Auto-stop only when actual drag starts (not on pan ready)
8. **Automatic Cleanup**: 200ms timeout for pan ready states prevents memory leaks

<h3>Debug and Telemetry</h3>

**Debug Event Types**:
- 🕐 Timer events (tap timeouts, tooltip delays)
- 🔧 State transitions (tap down/up/cancel)
- ✅ Condition checks (slop validation)
- 🎯 Hit test results
- 📊 Performance metrics

**Debug Output Example**:
```
🔧 [14:23:45.123] TapStateManager: TAP_DEBUG_STATE_UP | Data: {
  entityId: 'node_123',
  state_completed: true,
  tap_count: 1,
  distance: 3.5,
  touch_slop: 32.0
}
```

<h3>Common Interaction Patterns</h3>

1. **Single Tap Selection**: Toggle node/link selection state
   - Flow: PointerDown → PointerUp → onTap → onSelectionChange
2. **Double Tap Action**: Improved reliability with pan ready state
   - Flow: First tap → 500ms wait → Second tap → onTap(tapCount: 2)
3. **Drag to Move**: Enhanced with pan ready state for precision
   - Flow: PanStart → PanReady → Movement ≥8px → onDragStart → PanUpdate(s) → onDragUpdate(s) → PanEnd → onDragEnd
4. **Hover Preview**: Tooltip display after delay
   - Flow: MouseEnter → onHoverEnter → 500ms delay → onTooltipShow
5. **Background Tap**: Deselect all when tapping empty space
   - Flow: Tap on background → onBackgroundTapped → onSelectionChange(deselectedIds: all)
6. **Pan Ready State**: Prevents false drag detection
   - Flow: PointerDown → PanStart → PanReady (waiting) → Movement <8px → PointerUp → Tap successful

<h3>Extension Points</h3>

- Custom gesture modes via `GraphGestureMode.custom`
- Override `shouldConsumeGesture` for custom hit testing
- Add new state managers by extending `GraphStateManager`
- Custom debug events via `GraphGestureDebug.addEvent()`