# Large Graph Optimization Plan

**Branch:** `feature/large-graph-optimization`
**Target:** Smooth rendering and interaction for graphs with 500+ nodes and 1000+ links
**Date:** 2026-03-20

---

## Goals

| Metric | Current (estimated) | Target |
|--------|---------------------|--------|
| Frame rate at 500 nodes | ~15–30 fps | 60 fps |
| Frame rate at 1000 nodes | < 10 fps | 30+ fps |
| ForceDirected layout time (500 nodes) | ~5–10 s | < 2 s |
| Hit-test latency during drag | O(n+m) per frame | O(log n) |
| Link incoming/outgoing lookup | O(m) | O(1) |

---

## Identified Bottlenecks

### P0 — Critical

| ID | Location | Problem | Complexity |
|----|----------|---------|-----------|
| B1 | `layout_strategy/force_directed.dart` | Coulomb repulsion uses nested loops over all node pairs | O(n²) per iteration × 500 iterations |
| B2 | `graph_view/widget/graph.dart:399` | `elements.sort()` called every frame to sort by stackOrder | O(n log n) per frame |
| B3 | `graph_view/widget/link.dart` | Each link subscribes to 4 Listenables; any node move rebuilds all connected links | O(links) per node position change |
| B4 | `graph/graph_base.dart` | `getIncomingLinks` / `getOutgoingLinks` scan all links | O(m) per call |

### P1 — High

| ID | Location | Problem | Complexity |
|----|----------|---------|-----------|
| B5 | `interactive/gesture_manager.dart` | Hit-test uses linear scan over all entities | O(n+m) per pointer event |
| B6 | `graph_view/widget/node.dart` | 3 nested `AnimatedBuilder` wrappers per node | Unnecessary widget tree depth |
| B7 | `graph/graph_base.dart` | `selectedNodeIds` / `selectedLinkIds` stored as `IList` | O(n) contains check |

### P2 — Medium

| ID | Location | Problem |
|----|----------|---------|
| B8 | `graph_view/widget/node.dart` | `_updateNodeGeometryDuringAnimation` calls `addPostFrameCallback` every frame |
| B9 | `renderer/widget/link.dart` | Connection point recalculated every rebuild without caching |
| B10 | General | No viewport culling — off-screen nodes/links still render |

---

## Implementation Plan

### Phase 1: Data Layer Fixes (no API changes)

#### 1.1 — Adjacency Index (`B4`)

**File:** `lib/src/graph/graph_base.dart`

Add two private maps maintained alongside the link list:

```dart
final Map<GraphId, List<GraphLink>> _incomingIndex = {};
final Map<GraphId, List<GraphLink>> _outgoingIndex = {};
```

Update `_incomingIndex` / `_outgoingIndex` in `addLink()` and `removeLink()`.
Replace `getIncomingLinks` / `getOutgoingLinks` body to return `_incomingIndex[id] ?? []`.

**Result:** O(m) at build-time, O(1) at query-time.

#### 1.2 — Selection as Set (`B7`)

**File:** `lib/src/graph/graph_data.dart`

Change `selectedNodeIds` / `selectedLinkIds` from `IList<GraphId>` to `ISet<GraphId>`.
Update all callers (`selectNode`, `deselectNode`, `isSelected`, etc.).

**Result:** `isSelected` check becomes O(1).

---

### Phase 2: Rendering Layer Fixes

#### 2.1 — Cache stackOrder Sort (`B2`)

**File:** `lib/src/graph_view/widget/graph.dart`

Introduce a dirty flag + sorted cache in the graph widget state:

```dart
List<GraphEntity>? _sortedElements;
bool _sortDirty = true;
```

Set `_sortDirty = true` only when a node's `stackOrder` changes (subscribe to a new `stackOrderListenable` on `GraphNode`).
In `build`, use cache when clean; re-sort and clear flag when dirty.

**Result:** Sort runs only when stack order changes, not every frame.

#### 2.2 — Flatten AnimatedBuilder Nesting (`B6`)

**File:** `lib/src/graph_view/widget/node.dart`

Replace 3-level nested `AnimatedBuilder` with a single `AnimatedBuilder` using `Listenable.merge()`:

```dart
AnimatedBuilder(
  animation: Listenable.merge([
    _buildState,
    _node.positionListenable,
    _node.renderStateListenable,
  ]),
  builder: (context, child) { ... },
)
```

**Result:** Fewer widget rebuild layers per node.

#### 2.3 — Reduce Link Rebuild Scope (`B3`)

**File:** `lib/src/graph_view/widget/link.dart`

Current: link subscribes to `sourceNode.positionListenable`, `targetNode.positionListenable`, `sourceNode.geometryState`, `targetNode.geometryState` separately.

Change: Merge into a single `Listenable.merge()` and add an equality check inside `builder` to skip repaints when connection points haven't actually changed:

```dart
Offset? _lastSourcePoint;
Offset? _lastTargetPoint;

// Inside builder: if points unchanged, return cached child
```

Also consider using `RepaintBoundary` per link group when link count exceeds a threshold.

---

### Phase 3: Algorithm Improvements

#### 3.1 — Barnes-Hut for ForceDirected (`B1`)

**File:** `lib/src/layout_strategy/force_directed.dart`

Replace the O(n²) Coulomb double-loop with a Barnes-Hut approximation using a quadtree:

**New files:**
- `lib/src/layout_strategy/quadtree.dart` — Quadtree data structure
- Updated `force_directed.dart` — Use quadtree for repulsion

**Algorithm:**
1. Build quadtree from current node positions: O(n log n)
2. For each node, traverse quadtree: if a region's center-of-mass is far enough (s/d < θ, θ = 0.5), treat the region as a single body: O(n log n) total
3. Spring attraction (link-based) remains O(m)

**Result:** Per-iteration complexity: O(n log n + m) instead of O(n² + m).
At n=1000: ~10,000 ops vs 1,000,000 ops (100× speedup).

**Tuning parameters added to `GraphForceDirectedLayoutStrategy`:**
```dart
final double theta;       // Barnes-Hut threshold, default 0.5
final int maxIterations;  // keep existing, default 500
final double tolerance;   // keep existing, default 0.5
```

#### 3.2 — Hit-Test Spatial Index (`B5`)

**File:** `lib/src/interactive/gesture_manager.dart`

After layout completes, build a spatial grid index over node bounding boxes:

```dart
class _SpatialGrid {
  final Map<(int, int), List<GraphNode>> _cells = {};
  final double cellSize;

  void rebuild(Iterable<GraphNode> nodes) { ... }
  List<GraphNode> candidatesAt(Offset position) { ... }
}
```

Invalidate and rebuild the grid when any node moves (debounced on drag end).
`findNodeAt` queries only candidates from the grid cell containing `position`.

**Result:** Average hit-test: O(1) to O(k) where k = nodes per cell (typically < 5).

---

### Phase 4: Viewport Culling (`B10`)

**File:** `lib/src/graph_view/widget/graph.dart`

Track the visible viewport rectangle (derived from pan offset + zoom scale + widget size).
Before building node/link widgets, filter:

```dart
final visibleNodes = _sortedElements
    .whereType<GraphNode>()
    .where((n) => _viewport.overlaps(n.boundingRect))
    .toList();
```

For links, include any link where at least one endpoint is visible.

**Result:** Widget count proportional to visible area, not total graph size.

---

### Phase 5: Large-Graph Rendering Mode (optional, additive)

For graphs exceeding a configurable threshold (e.g., 300 nodes), offer a `GraphRenderingMode.canvas` mode:

- Renders all nodes and links in a single `CustomPaint` widget
- Bypasses Flutter widget tree overhead entirely
- Trades per-node customizability for raw throughput
- Opt-in via `GraphViewBehavior.renderingMode`

This phase is lower priority and depends on the results of Phases 1–4.

---

## File Change Summary

| File | Change Type | Priority |
|------|-------------|----------|
| `lib/src/graph/graph_base.dart` | Add adjacency index | P0 |
| `lib/src/graph/graph_data.dart` | IList → ISet for selection | P0 |
| `lib/src/graph_view/widget/graph.dart` | Cache sort + viewport culling | P0, P2 |
| `lib/src/graph_view/widget/node.dart` | Flatten AnimatedBuilder | P1 |
| `lib/src/graph_view/widget/link.dart` | Reduce rebuild scope | P0 |
| `lib/src/layout_strategy/force_directed.dart` | Barnes-Hut algorithm | P0 |
| `lib/src/layout_strategy/quadtree.dart` | New file: Quadtree | P0 |
| `lib/src/interactive/gesture_manager.dart` | Spatial grid hit-test | P1 |
| `example/lib/sample_data/large_graph.dart` | New large-graph sample | — |
| `example/lib/sample_data/sample_data.dart` | Register large-graph sample | — |

---

## Testing Strategy

### Performance Benchmarks
- Add `test/performance/` directory with benchmark tests
- Measure frame times at 100 / 500 / 1000 / 2000 node counts
- Measure ForceDirected layout time at each scale

### Correctness Tests
- Quadtree: verify same force results as naive O(n²) at θ=0 (no approximation)
- Adjacency index: verify `getIncomingLinks` / `getOutgoingLinks` match brute-force scan
- Spatial grid: verify `findNodeAt` returns same result as linear scan for all tested positions
- Viewport culling: verify no visible node/link is ever skipped

### Regression
- All existing tests (`make test`) must continue to pass after each phase
- Golden tests must not change (rendering appearance unchanged)

---

## Rollout Order

```
Phase 1 (Data) → Phase 2 (Rendering) → Phase 3 (Algorithms) → Phase 4 (Culling)
     ↑ safest, no visual change            ↑ most impactful for large graphs
```

Each phase is independently mergeable and testable.

---

## Non-Goals

- Changing the public API surface of `Graph`, `GraphNode`, `GraphLink`
- Changing existing layout strategy parameter defaults (backward-compatible changes only)
- WebGL / CanvasKit specific optimizations (handled by Flutter engine)
- Network data streaming / virtualization (out of scope)
