# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Plough is a Flutter package for creating interactive network graph visualizations with multiple layout algorithms and customizable appearance. Written in Dart 3.5.3+, it uses Flutter's standard state management (ValueNotifier, InheritedWidget) with no external state management dependencies.

## Common Commands

The project uses FVM (Flutter Version Management). The Makefile wraps `fvm flutter` / `fvm dart`:

```bash
make fix          # dart fix --apply + format on lib, test, example
make format       # dart format on lib, test
make test         # flutter test (all tests)
make test-web     # dart test -p chrome
make generate     # build_runner for Freezed code generation
make doc          # generate API docs
make pubpoints    # run pana quality analyzer
```

Manual equivalents (without FVM):

```bash
flutter pub get                                              # install dependencies
flutter test                                                 # run all tests
flutter test test/some_test.dart                             # run single test
flutter analyze                                              # lint check
dart run build_runner build --delete-conflicting-outputs     # code generation
```

Example app (from `example/` directory):

```bash
cd example && flutter run -d macos    # or -d ios, -d chrome
```

## Architecture

### Layer Structure

1. **Data Model** (`lib/src/graph/`) — `Graph` (ValueNotifier-based reactive container), `GraphNode`, `GraphLink`, `GraphEntity` base interface, `GraphId` (Freezed). Public APIs use factory constructors; internal implementations are private `*Impl` classes.

2. **Layout System** (`lib/src/layout_strategy/`) — Strategy pattern. Base class `GraphLayoutStrategy` with concrete implementations: `ForceDirected`, `Tree`, `Manual`, `Random`, `Custom`. Each calculates node positions via `performLayout(Graph, Size)`.

3. **Rendering** (`lib/src/graph_view/` + `lib/src/renderer/`) — `GraphView` is the main widget. `GraphViewBehavior` is the composition-based customization point for appearance and interaction callbacks. Node/link styles use Freezed data classes in `renderer/style/`.

4. **Interaction** (`lib/src/interactive/`) — `GraphGestureManager` is the central gesture coordinator with specialized state managers for tap, drag, hover, pan-ready, and tooltip. Events are type-safe (`GraphTapEvent`, `GraphDragStartEvent`, etc.). Gesture modes: exclusive, nodeEdgeOnly, transparent, custom.

5. **Tooltip** (`lib/src/tooltip/`) — Tooltip behavior config and widgets.

6. **Debug** (`lib/src/debug/`) — `Plough` singleton for global config. The core only holds the web-safe abstractions `DebugSink`/`DebugBackend` (default to no-ops). The heavyweight `dart:io`/`http` debug stack (HTTP server, external log client, structured logger, performance monitor, diagnostics) lives in the separate `plough_devtools` package under `devtools/`; call `attachPloughDevtools()` to wire it in. This keeps the core free of `dart:io`/`http` (web-safe).

### State Management Flow

Graph data changes → ValueNotifier notifications → GraphView rebuilds via InheritedWidget (`GraphInheritedData`) → Layout strategy calculates positions → Widgets render with animations → User interactions emit events → State updates → UI updates.

### Key Design Patterns

- **Factory pattern**: All public entity creation (nodes, links) via factory constructors hiding `*Impl` classes
- **Strategy pattern**: Pluggable layout algorithms
- **Composition**: `GraphViewBehavior` subclassing for custom rendering/interaction
- **Freezed immutability**: Data classes for IDs, geometry, styles

## Code Generation (Freezed)

After modifying any Freezed-annotated file, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Files with code generation:
- `lib/src/graph/graph_data.dart`, `id.dart`
- `lib/src/graph_view/data.dart`, `geometry.dart`
- `lib/src/renderer/style/link.dart`, `node.dart`

Generated files (`*.freezed.dart`, `*.g.dart`) are version-controlled.

## Linting

Uses `very_good_analysis` with customizations in `analysis_options.yaml`:
- `lines_longer_than_80_chars: false` — no line length limit
- `public_member_api_docs: false` — docs not enforced
- `avoid_print: false` — print allowed (logging)
- `unawaited_futures: true` — unawaited futures are errors
- Test files are excluded from analysis

## Testing

Tests are in `test/` (~40+ files). Layers:
- **Unit**: Graph model operations, selection, link directionality
- **Gesture**: Direct `GraphGestureManager` testing with simulated pointer events
- **Widget**: `GraphView` rendering and behavior
- **Golden**: Pixel-perfect visual tests using `golden_toolkit` (800x600 @ 2.0 DPI)

See `doc/testing_guide.md` for the comprehensive 4-layer testing strategy.

## Git Workflow

- Branch from `main` for features
- Conventional commit style: `feat:`, `fix:`, `chore:`, etc.
- Before committing, **always** run `dart format .` (or `make format`) and verify
  `dart format --set-exit-if-changed .` exits 0 — CI fails on any unformatted file
- Run `flutter analyze` and `flutter test` before committing
