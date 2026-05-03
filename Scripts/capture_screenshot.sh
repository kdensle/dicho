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
SCENARIO="${SCENARIO:-all}"
SCREENSHOT_DELAY="${SCREENSHOT_DELAY:-3}"
STATUS_BAR="${STATUS_BAR:-1}"

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

if [[ "$STATUS_BAR" == "1" ]]; then
  xcrun simctl status_bar "$SIMULATOR_ID" override \
    --time "9:41" \
    --wifiBars 3 \
    --cellularBars 4 \
    --batteryState charged \
    --batteryLevel 100 2>/dev/null || true
fi

capture() {
  local scenario="$1"
  local output="$OUT_DIR/dicho-$scenario.png"

  xcrun simctl terminate "$SIMULATOR_ID" com.kyledensley.dicho 2>/dev/null || true
  xcrun simctl launch "$SIMULATOR_ID" com.kyledensley.dicho --dicho-screenshot "$scenario"
  sleep "$SCREENSHOT_DELAY"
  xcrun simctl io "$SIMULATOR_ID" screenshot "$output"
  echo "Screenshot written to $output"
}

if [[ "$SCENARIO" == "all" ]]; then
  for scenario in home result paywall settings; do
    capture "$scenario"
  done
else
  capture "$SCENARIO"
fi
