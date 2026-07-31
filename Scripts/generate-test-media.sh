#!/usr/bin/env bash
# Generate the small blue/orange test movies used by FeaturePair recipes and
# `fcpxml-dsl` smoke imports. Requires ffmpeg on PATH.
#
# Default output matches docs/manual/easy-export-recipes.md:
#   /Users/Shared/FCPKitMedia/Left.mov   (10s, 1080p24, stereo, blue)
#   /Users/Shared/FCPKitMedia/Right.mov  (9s, 720p24, mono, orange)
#
# Usage:
#   ./Scripts/generate-test-media.sh
#   MEDIA_DIR=/tmp/FCPKitMedia ./Scripts/generate-test-media.sh

set -euo pipefail

MEDIA_DIR="${MEDIA_DIR:-/Users/Shared/FCPKitMedia}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "error: ffmpeg not found on PATH (brew install ffmpeg)" >&2
  exit 1
fi

mkdir -p "${MEDIA_DIR}"

# Left: 10s 1920x1080@24 stereo — matches FeaturePair asset duration / format.
ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "color=c=0x1E6BFF:s=1920x1080:r=24:d=10" \
  -f lavfi -i "sine=frequency=440:sample_rate=48000:duration=10" \
  -c:v libx264 -pix_fmt yuv420p -profile:v high -bf 0 \
  -c:a pcm_s16le -ac 2 -ar 48000 \
  -shortest \
  "${MEDIA_DIR}/Left.mov"

# Right: 9s 1280x720@24 mono — matches FeaturePair Right asset.
ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "color=c=0xFF7A1A:s=1280x720:r=24:d=9" \
  -f lavfi -i "sine=frequency=550:sample_rate=48000:duration=9" \
  -c:v libx264 -pix_fmt yuv420p -profile:v high -bf 0 \
  -c:a pcm_s16le -ac 1 -ar 48000 \
  -shortest \
  "${MEDIA_DIR}/Right.mov"

echo "Wrote:"
echo "  ${MEDIA_DIR}/Left.mov"
echo "  ${MEDIA_DIR}/Right.mov"
echo
echo "Example DSL export:"
echo "  swift run fcpxml-dsl export transitions \\"
echo "    \"${MEDIA_DIR}/Left.mov\" \"${MEDIA_DIR}/Right.mov\" transitions.fcpxml"
