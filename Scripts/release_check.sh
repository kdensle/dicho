#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Checking backend environment..."
npm --prefix Backend run doctor

echo "Checking backend syntax..."
npm --prefix Backend run check

echo "Checking QA scripts and JSON assets..."
node --check QA/run_backend_eval.mjs
node -e "JSON.parse(require('fs').readFileSync('StoreKit/Dicho.storekit','utf8')); JSON.parse(require('fs').readFileSync('QA/translation_eval_cases.json','utf8')); console.log('JSON OK')"

echo "Checking Xcode project and plist..."
plutil -lint Dicho.xcodeproj/project.pbxproj Dicho/Info.plist

if [[ "${1:-}" == "--build-simulator" ]]; then
  echo "Building Release for simulator..."
  xcodebuild \
    -project Dicho.xcodeproj \
    -scheme Dicho \
    -configuration Release \
    -destination "${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro Max}" \
    -derivedDataPath "${DERIVED_DATA:-/tmp/DichoReleaseCheckDerivedData}" \
    build
fi

echo "Release checks finished."
