# Plough Debug App

A Flutter application specifically designed for debugging and monitoring the Plough package during development.

## Features

- **Real-time Event Monitoring**: Track all user interactions (tap, drag, hover, etc.) and their timing
- **Widget Rebuild Tracking**: Monitor GraphView build() method execution count
- **Notification Flow Visualization**: Observe Graph internal state change notifications
- **Detailed Event Logging**: View timestamped event logs with detailed information
- **Statistics Display**: Show total counts for callbacks, rebuilds, and notifications

## Running the App

From the project root directory:

```bash
cd apps/debug_app
flutter pub get
flutter run -d macos  # or your preferred device
```

## UI Layout

- **Left Panel**: GraphView area with rebuild count display
- **Right Panel**: 
  - Monitoring options (toggles for callbacks, rebuilds, notifications)
  - Statistics (total counts)
  - Real-time event log viewer
- **Floating Action Buttons**: Add/remove nodes, trigger animations

## Event Types

The app monitors these event types:

- **Callbacks**: User interaction events (tap, selection changes, etc.)
- **Rebuilds**: Widget build() method executions
- **Notifications**: Graph state change notifications
- **Gestures**: Drag operations, hover events
- **Layout**: Layout strategy changes

## Usage Tips

1. Toggle monitoring options to focus on specific aspects
2. Use the Clear button to reset the event log
3. Add/remove nodes to observe graph changes
4. Watch the statistics panel for performance insights
5. Monitor the event log for detailed interaction flow

This tool is essential for understanding the internal behavior of the Plough package and debugging complex interaction scenarios.