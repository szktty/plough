# AGENTS.md

This document provides guidance for any AI agent working with code in this repository.
Agents are expected to contribute to the project effectively and safely, based on the information provided below.

## Agent Roles and Responsibilities
- Understand and analyze the codebase.
- Implement bug fixes, new features, and propose/execute refactoring.
- Strictly adhere to existing coding conventions, styles, and architectural patterns.
- Maintain and improve test coverage.
- Clearly communicate changes and provide feedback to human developers as needed.

## Project Overview

Plough is a Flutter package for creating interactive network graph visualizations with multiple layout algorithms and customizable appearance. The package uses Flutter's standard state management (ValueNotifier, InheritedWidget) and follows clean architecture principles.

## Guidelines for Collaboration with Agents
- **Clarification**: If a task is unclear, please attempt to clarify it through specific questions.
- **Plan Sharing**: Before embarking on complex tasks, please share an outline of your plan.
- **Progress Reporting**: Regularly report on your work progress, especially regarding key milestones and challenges.
- **Feedback Reception**: Be open to feedback provided by human developers and adjust your changes as necessary.
- **Autonomy and Confirmation**: Small changes that align with existing patterns can be performed autonomously, but for large-scale changes or the introduction of new patterns, please seek prior confirmation.

## Development Workflow and Tool Usage

### Development Commands

### Package Development
```bash
# Get dependencies
flutter pub get

# Run code generation for Freezed models
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test

# Run specific test file
flutter test test/plough_test.dart
```

### Example App Development (in example/ directory)
```bash
cd example

# Run on macOS
flutter run -d macos

# Run on iOS Simulator
flutter run -d ios

# Run on web
flutter run -d chrome

# Build for release
flutter build macos
flutter build ios
flutter build web
```

### Git Workflow
- **Branch Strategy**: Typically, create new feature branches from `main` to isolate changes.
- **Commit Messages**: Commit messages should be concise and clear, describing **why** the change was made and **what** was changed. Example: `feat: Add new layout strategy for tree graphs`
- **Review Changes**: When proposing changes, request human review through a pull request.

### Recommendations for Agent Tool Usage
- `read_file` and `search_file_content`: Actively use these tools for codebase investigation to accurately understand file contents.
- `replace` and `write_file`: Use these tools carefully for modifying files, maintaining consistency with existing code style. For `replace` specifically, precision in `old_string` and `new_string` is crucial.
- `run_shell_command`: This is a powerful tool; especially when executing commands that may affect the file system, clearly understand its purpose and potential impact, and explain it to the user if necessary.

## Architecture Overview

### Core Components Structure

1. **Data Model Layer** (`lib/src/graph/`)
   - `Graph`: Central data structure using ValueNotifier for reactive state
   - `GraphNode` & `GraphLink`: Core entities with factory pattern
   - `GraphEntity`: Base interface for nodes and links
   - `GraphId`: Type-safe identifiers using Freezed
   - All implementations use internal classes (suffixed with `Impl`) for encapsulation

2. **Layout System** (`lib/src/layout_strategy/`)
   - `GraphLayoutStrategy`: Base class using Strategy pattern
   - Concrete strategies: ForceDirected, Tree, Manual, Random, Custom
   - Each strategy calculates node positions based on graph structure
   - Support for fixed node positions and padding

3. **Rendering Layer** (`lib/src/graph_view/` & `lib/src/renderer/`)
   - `GraphView`: Main widget orchestrating the visualization
   - `GraphNodeView` & `GraphLinkView`: Individual entity widgets
   - Behavior system for customizing appearance and interaction
   - Default renderers with support for custom shapes

4. **Interaction System** (`lib/src/interactive/`)
   - `GraphGestureManager`: Central coordinator for all gestures
   - Specialized state managers for tap, drag, hover, and tooltips
   - Event-driven architecture with type-safe events
   - Support for selection, dragging, and custom behaviors

### Key Design Patterns

- **Reactive State**: Uses Flutter standard ValueNotifier and InheritedWidget for efficient reactivity
- **Factory Pattern**: For creating nodes and links
- **Strategy Pattern**: For layout algorithms
- **Composition**: Behavior system allows mixing features
- **Immutability**: Freezed for data classes

### State Management Flow

1. Graph data changes → ValueNotifier notifications
2. GraphView listens via InheritedWidget → Triggers rebuild
3. Layout strategy calculates positions
4. Widgets render with animations
5. User interactions → Event emission → State updates → UI updates

### State Management Implementation Details

The package uses Flutter's standard state management without external dependencies:

- **GraphInheritedData**: Core InheritedWidget that distributes graph data, build state, and behaviors throughout the widget tree
- **ValueNotifier**: Used for reactive properties like node positions, selection state, and animation states
- **AnimatedBuilder**: Efficiently rebuilds only when relevant data changes
- **Batch Updates**: Layout changes are batched to maintain 60FPS performance during animations
- **Separation of Concerns**: Layout changes and selection changes use separate listeners to minimize rebuilds

Key files:
- `lib/src/graph_view/inherited_data.dart`: InheritedWidget implementation
- `lib/src/graph/graph_base.dart`: Core graph state with ValueNotifier
- `lib/src/graph/node.dart` & `lib/src/graph/link.dart`: Entity-level state management

## Code Generation

The project uses Freezed for immutable data classes. Files requiring code generation:
- `graph_data.dart` → `graph_data.freezed.dart`
- `id.dart` → `id.freezed.dart`, `id.g.dart`
- `data.dart` (graph_view) → `data.freezed.dart`
- `geometry.dart` → `geometry.freezed.dart`
- `link.dart` (renderer/style) → `link.freezed.dart`
- `node.dart` (renderer/style) → `node.freezed.dart`

Run code generation after modifying these files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing Approach

Tests are located in `test/`. The package uses standard Flutter testing:
- Unit tests for data models and layout algorithms
- Widget tests for UI components
- Integration tests for graph interactions

## Development Guidelines

1. **Linting**: Project uses `very_good_analysis` package
   - Some rules are disabled in `analysis_options.yaml`
   - Run `flutter analyze` before commits

2. **API Design**:
   - Public APIs use factory constructors
   - Internal implementations are private
   - Extensive use of named parameters for clarity

3. **Performance**:
   - ValueNotifier and InheritedWidget provide efficient updates
   - Layout calculations are optimized for 60FPS with batch updates
   - Animations use Flutter's animation system
   - Designed to handle hundreds to thousands of entities efficiently

4. **Extension Points**:
   - Custom layout strategies via `GraphCustomLayoutStrategy`
   - Custom behaviors via `GraphViewBehavior`
   - Custom shapes and renderers

## Working with the Example App

The `example/` directory contains a full demonstration app showcasing:
- Different layout strategies
- Custom node/link rendering
- Interactive features
- Sample data generation

When testing changes, use the example app to verify functionality across different scenarios.

## Architecture Details

A detailed description of the interaction system and other specific architectural components can be found in [ARCHITECTURE.md](ARCHITECTURE.md).

For deep implementation specifics, agents should analyze the source code directly, particularly within the `lib/src/` subdirectories corresponding to each component.

## Ethics and Safety
- **Protection of Sensitive Information**: Do not hardcode credentials or sensitive data into the code, nor output them to logs.
- **System Impact**: Avoid making unnecessary changes to system settings or files outside the project directory.
- **Prevention of Unintended Behavior**: When making changes, ensure thorough testing to confirm there are no unintended side effects on existing functionalities.