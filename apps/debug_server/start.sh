#!/bin/bash

echo "🚀 Starting Plough Debug Server (Dart)"
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in debug_server directory"
    echo "Run this script from the debug_server directory"
    echo "  cd debug_server"
    echo "  ./start.sh"
    exit 1
fi

# Install dependencies if needed
if [ ! -d ".dart_tool" ]; then
    echo "📦 Installing dependencies..."
    dart pub get
fi

# Get port from command line argument, default to 8081
PORT=${1:-8081}

echo "🔧 Configuration:"
echo "  Port: $PORT"
echo "  Web Console: http://localhost:$PORT"
echo "  API Status: http://localhost:$PORT/api/status"
echo ""

# Start the server
echo "▶️  Starting server..."
dart run bin/debug_server.dart --port $PORT