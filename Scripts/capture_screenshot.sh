#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SIMULATOR_ID="${SIMULATOR_ID:-booted}"
OUT_DIR="${OUT_DIR:-$ROOT/AppStoreAssets/Screenshots}"
DERIVED_DATA="${DERIVED_DATA:-/tmp/DichoScreenshotDerivedData}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro Max}"
APP_PATH="${APP_PATH:-$DERIVED_DATA/Build/Products/Release-iphonesimulator/Dicho.app}"
BUILD="${BUILD:-1}"

mkdir -p "$OUT_DIR"

if [[ "$BUILD" == "1" ]]; then
  xcodebuild \
    -project Dicho.xcodeproj \
    -scheme Dicho \
    -configuration Release \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA" \
    build
fi

if [[ "$SIMULATOR_ID" != "booted" ]]; then
  xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
  xcrun simctl bootstatus "$SIMULATOR_ID" -b
fi

xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
xcrun simctl launch "$SIMULATOR_ID" com.kyledensley.dicho
sleep "${SCREENSHOT_DELAY:-2}"

STAMP="$(date +%Y%m%d-%H%M%S)"
xcrun simctl io "$SIMULATOR_ID" screenshot "$OUT_DIR/dicho-$STAMP.png"

echo "Screenshot written to $OUT_DIR/dicho-$STAMP.png"
