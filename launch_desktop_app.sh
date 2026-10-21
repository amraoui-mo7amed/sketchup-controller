#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QT_QUICK_CONTROLS_STYLE="Basic"
"$SCRIPT_DIR/venv/bin/python3" "$SCRIPT_DIR/desktop-app/main.py"
