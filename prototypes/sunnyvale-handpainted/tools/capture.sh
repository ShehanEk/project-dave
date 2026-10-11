#!/bin/sh
# Windowed Movie Maker capture for visual evidence (opens a game window briefly).
#   tools/capture.sh res://scenes/debug/foo.tscn OUT_DIR [FRAMES=90] [FPS=30]
# Writes OUT_DIR/frame00000000.png ...; view a few with an image reader.
set -e
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
SCENE="$1"; OUT="$2"; FRAMES="${3:-90}"; FPS="${4:-30}"
mkdir -p "$OUT"
"$GODOT" --path . --write-movie "$OUT/frame.png" --fixed-fps "$FPS" \
  --quit-after "$FRAMES" "$SCENE" 2>&1 | grep -iE "error|warn|script" || true
rm -f "$OUT/frame.wav"
ls "$OUT" | wc -l | xargs echo "frames written:"
