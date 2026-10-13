#!/bin/sh
# Import (refresh class_name cache) then run headless tests.
#   tools/test.sh              all cases
#   tools/test.sh hero         only cases whose filename contains "hero"
#   NOIMPORT=1 tools/test.sh   skip the import step (read-only reviewers)
#   FPS=30 tools/test.sh       run at a 30 fps fixed frame step instead of 60
# Tests always use --fixed-fps so simulated time runs faster than real time
# (a real-time run of the full suite takes ~20 min; fixed-step takes seconds).
set -e
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [ -z "$NOIMPORT" ]; then
  "$GODOT" --headless --path . --import >/dev/null 2>&1 || true
fi
EXTRA="--fixed-fps ${FPS:-60}"
FILTER=""
[ -n "$1" ] && FILTER="--filter=$1"
"$GODOT" --headless --path . $EXTRA -s res://tests/run_tests.gd -- $FILTER 2>&1 \
  | grep -v "^Godot Engine v" | grep -v "^$"
