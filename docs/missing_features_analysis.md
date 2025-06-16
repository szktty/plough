# Plough Library Missing Features Analysis

## Overview

This document outlines the missing features and improvements needed for the Plough graph visualization library, based on current implementation analysis and the requirements specified in `PLOUGH_REQUIREMENTS.md`.

## High Priority: Gesture System Improvements

### 1. Background Gesture Pass-through

**Current Issue**: GraphView consumes all gestures, preventing parent widgets (like InteractiveViewer) from handling background interactions.

**Primary Goal**: Enable applications to implement their own viewport management (InteractiveViewer, custom pan/zoom, etc.) by allowing gestures to pass through empty areas.

**Required Features**:
- Conditional gesture pass-through for empty areas
- Hit test result details for accurate gesture targeting
- Background-only gesture callbacks

**Proposed API**:
```dart
GraphView(
  // Allow gestures to pass through on empty areas
  allowBackgroundGestures: true,
  
  // Custom gesture handling logic
  shouldConsumeGesture: (Offset localPosition, GraphHitTestResult hitResult) {
    return hitResult.hasNode || hitResult.hasEdge;
  },
  
  // Background-specific callbacks (optional)
  onBackgroundTapped: (localPosition) { /* Handle background tap */ },
  onBackgroundPan: (details) { /* Handle background pan */ },
)
```

**Benefits**:
- Applications can wrap GraphView with InteractiveViewer or custom viewport widgets
- Maintains library focus on graph-specific functionality
- Provides flexibility for different viewport management approaches
- Avoids complex widget coordination within the library

### 2. Enhanced Hit Test Results

**Required Implementation**:
```dart
class GraphHitTestResult {
  final bool hasNode;
  final bool hasEdge;
  final GraphNode? node;
  final GraphLink? edge;
  final Offset localPosition;
  final bool isBackground; // Empty area detection
}
```

### 3. Gesture Mode Options

**Proposed Enum**:
```dart
enum GraphGestureMode {
  exclusive,    // Current behavior: consume all gestures
  nodeEdgeOnly, // Only consume gestures on nodes/edges
  transparent,  // Pass all gestures to parent
  custom,       // Use custom gesture handler
}
```

### 4. InteractiveViewer Integration (Under Review)

**Note**: InteractiveViewer integration was initially attempted but proved complex to implement and generalize. It's unclear whether this should be a core library responsibility or left to application-level implementation.

**Challenges**:
- Complex gesture coordination between widgets
- Difficult to generalize across different use cases
- May conflict with graph-specific interactions
- Implementation complexity vs. benefit trade-off

**Alternative Approach**:
Focus on gesture pass-through (#1) which enables applications to implement InteractiveViewer integration at the app level without library-specific coupling.

**Rationale for Exclusion**:
- Viewport management is outside the scope of a graph visualization library
- Complex gesture coordination between widgets is difficult to generalize
- Application-level implementation provides more flexibility
- Keeps library focused on core graph functionality
- Avoids dependencies on specific Flutter widgets

## Medium Priority: Layout System Extensions

### 1. Customizable Layout Parameters

**Tree Layout Missing**:
- Configurable `levelSpacing` and `minNodeSpacing` (currently hardcoded at 100.0 and 60.0)
- Direction-specific spacing options
- Custom root positioning

**Force Directed Missing**:
- Advanced physics parameters
- Incremental layout updates
- Layout convergence callbacks

**New Layout Strategies Needed**:
- Grid layout for regular arrangements
- Circular layout for radial graphs
- Hierarchical layout with multiple roots

### 2. Layout Animations

**Missing Features**:
- Incremental node placement animations
- Smooth transitions between layout strategies
- Custom animation curves for different layout types
- Layout change event callbacks

**Proposed API**:
```dart
GraphLayoutStrategy(
  animationDuration: Duration(milliseconds: 800),
  animationCurve: Curves.elasticOut,
  incrementalPlacement: true,
)
```

### 3. Dynamic Layout Adjustments

**Required Features**:
- Real-time layout on node/edge changes
- Partial layout updates for performance
- Layout constraints for fixed positions
- Collision detection and avoidance

## Medium Priority: Interaction Enhancements

### 1. Multi-touch Support

**Missing Features**:
- Native pinch-to-zoom gestures
- Multi-finger pan operations
- Rotation gesture support
- Touch pressure sensitivity

### 2. Keyboard Navigation

**Required Features**:
- Shortcut key support (select, delete, copy, etc.)
- Arrow key node movement
- Tab-based focus navigation
- Accessibility keyboard shortcuts

**Proposed API**:
```dart
GraphView(
  keyboardShortcuts: {
    LogicalKeySet(LogicalKeyboardKey.delete): DeleteSelectedAction(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.a): SelectAllAction(),
  },
)
```

### 3. Advanced Selection Features

**Missing Features**:
- Rectangle selection with drag
- Range selection with Shift+click
- Selection state persistence
- Selection groups and layers

## Low Priority: Rendering and Display

### 1. Performance Optimizations

**Missing Features**:
- Viewport culling for large graphs
- Level-of-detail rendering based on zoom
- Rendering cache for static elements
- Background rendering threads

### 2. Visual Effects

**Missing Features**:
- Edge bundling for multiple connections
- Hover and selection animations
- Theme system (dark/light mode)
- Custom visual effects pipeline

**Proposed API**:
```dart
GraphViewBehavior(
  theme: GraphTheme.dark(),
  hoverEffects: GraphHoverEffects.glow(),
  selectionEffects: GraphSelectionEffects.highlight(),
)
```

### 3. Accessibility

**Missing Features**:
- Screen reader support
- High contrast mode
- Color blind accessibility
- Keyboard-only navigation

## Low Priority: Data Operations

### 1. Import/Export

**Missing Features**:
- GraphML format support
- GEXF format support
- JSON/CSV data exchange
- Image export (PNG, SVG)

### 2. Search and Filtering

**Missing Features**:
- Node search functionality
- Attribute-based filtering
- Path highlighting
- Graph traversal utilities

**Proposed API**:
```dart
GraphView(
  searchProvider: GraphSearchProvider(
    searchableFields: ['label', 'type'],
    highlightResults: true,
  ),
  filterProvider: GraphFilterProvider(
    filters: [
      NodeTypeFilter(['important']),
      AttributeFilter('weight', min: 0.5),
    ],
  ),
)
```

### 3. Editing Features

**Missing Features**:
- Dynamic node/edge addition/removal
- Attribute editing UI
- Undo/redo functionality
- Graph history management

## Implementation Roadmap

### Phase 1: Critical Gesture Issues
1. Background gesture pass-through
2. GraphHitTestResult implementation
3. GraphGestureMode enum
4. ~~InteractiveViewer integration~~ (Deferred - application-level responsibility)

### Phase 2: Layout Improvements
1. Configurable layout parameters
2. Grid and circular layout strategies
3. Layout animation system
4. Dynamic layout adjustments

### Phase 3: Interaction Enhancements
1. Multi-touch support
2. Keyboard navigation
3. Advanced selection features
4. Accessibility improvements

### Phase 4: Polish and Performance
1. Performance optimizations
2. Visual effects system
3. Import/export functionality
4. Search and filtering

## Testing Requirements

Each new feature should include:
- Unit tests for core functionality
- Widget tests for UI components
- Integration tests for gesture interactions
- Performance benchmarks for large graphs
- Accessibility compliance tests

## Design Principles

### Library Scope
- **Core Focus**: Graph data visualization, layout algorithms, and node/edge interactions
- **Out of Scope**: Viewport management, canvas transformation, application-level gesture coordination
- **Boundary**: Provide hooks and pass-through mechanisms for application-level integration

### API Stability

New features should maintain backward compatibility:
- All new parameters should be optional with sensible defaults
- Existing behavior should remain unchanged when new features are disabled
- Deprecation warnings for any breaking changes
- Migration guides for major API changes

### Integration Philosophy
- Enable rather than encapsulate external widget integration
- Provide sufficient hooks for applications to implement custom behaviors
- Maintain clear separation between graph logic and viewport logic

## References

- [PLOUGH_REQUIREMENTS.md](../PLOUGH_REQUIREMENTS.md) - Detailed gesture improvement requirements
- [Current Implementation Analysis](../lib/src/) - Source code review findings
- [Flutter Gesture System](https://docs.flutter.dev/development/ui/advanced/gestures) - Flutter documentation
- [InteractiveViewer Widget](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html) - Parent widget integration target