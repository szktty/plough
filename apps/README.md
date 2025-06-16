# Plough Apps

This directory contains development and debugging tools for the Plough package.

## Applications

### workbench/
A workbench application for testing and developing Plough features interactively.

**Features:**
- Event monitoring (callbacks, gestures, selections)
- Widget rebuild tracking
- Graph notification flow visualization
- Real-time event logging with timestamps
- Performance statistics

**Usage:**
```bash
cd workbench
flutter pub get
flutter run -d macos
```

### debug_server/
A Dart-based debug server for real-time debugging support.

**Features:**
- Real-time debugging capabilities
- Server-based debugging infrastructure
- Integration with Flutter debugging tools

**Usage:**
```bash
cd debug_server
dart pub get
dart run bin/debug_server.dart
```

## Development Workflow

1. Use `workbench` for interactive testing and feature development
2. Use `debug_server` for programmatic debugging and logging
3. Both tools can be used together for comprehensive debugging

## Integration

Both applications are designed to work with the main Plough package located in the parent directory (`../../`). They automatically reference the local development version of Plough.