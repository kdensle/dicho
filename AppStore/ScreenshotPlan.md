# Screenshot Plan

App Store Connect requires screenshots that show the app in use. Capture real production UI after the backend and StoreKit product are configured.

## Required iPhone Screens

Capture at least the largest iPhone size App Store Connect requests for your Xcode/App Store Connect account. Use portrait screenshots.

Recommended set:

1. Main translator with English input and Mexico selected.
2. Translation result screen showing natural Spanish output and country notes.
3. Country picker showing supported regions.
4. Paywall showing dicho pro monthly price.
5. Settings showing appearance, restore, terms, privacy, and manage subscription.

## Screenshot Copy Overlays

Use overlays only if they still show the app clearly.

Suggested copy:

- `Natural Spanish for real messages`
- `Auto-detect English or Spanish`
- `Tune phrasing by country`
- `Copied instantly`
- `30 free translations monthly`

## Local Capture

Use `Scripts/capture_screenshot.sh` after selecting a booted simulator.

Example:

```bash
SIMULATOR_ID=booted Scripts/capture_screenshot.sh
```

Screenshots will be written to `AppStoreAssets/Screenshots/`.
