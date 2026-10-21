#!/bin/bash
set -e

PLUGIN_TARGET_DIR="$HOME/Library/Application Support/SketchUp 2026/SketchUp/Plugins"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/sketchup-plugin"

mkdir -p "$PLUGIN_TARGET_DIR"

echo "Installing SketchUp Controller Plugin into:"
echo "$PLUGIN_TARGET_DIR"

# Remove existing links or directories
rm -rf "$PLUGIN_TARGET_DIR/sketchup_controller.rb"
rm -rf "$PLUGIN_TARGET_DIR/sketchup_controller"

# Create symlinks so edits in this repo are reflected instantly in SketchUp
ln -s "$SOURCE_DIR/sketchup_controller.rb" "$PLUGIN_TARGET_DIR/sketchup_controller.rb"
ln -s "$SOURCE_DIR/sketchup_controller" "$PLUGIN_TARGET_DIR/sketchup_controller"

echo "✓ Plugin installed successfully!"
echo "When you launch SketchUp 2026, the bridge server will automatically run on http://127.0.0.1:9876"
