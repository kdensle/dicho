# Screenshot Plan

App Store Connect requires screenshots that show the app in use. Capture real production UI after the backend and StoreKit product are configured.

## Required iPhone Screens

Capture at least the largest iPhone size App Store Connect requests for your Xcode/App Store Connect account. Use portrait screenshots.

Recommended set:

1. Main translator with English input and Mexico selected.
2. Translation result screen showing natural Spanish output and country notes.
3. Paywall showing dicho pro monthly price.
4. Settings showing appearance, restore, terms, privacy, and manage subscription.
5. Optional country picker showing supported regions, captured manually if Apple asks for more screenshots.

## Screenshot Copy Overlays

Use overlays only if they still show the app clearly.

Suggested copy:

- `Natural Spanish for real messages`
- `Auto-detect English or Spanish`
- `Tune phrasing by country`
- `Copied instantly`
- `30 free translations monthly`

## Local Capture

Use `Scripts/capture_screenshot.sh` after selecting a booted simulator. The app supports a hidden screenshot mode through launch arguments, so screenshots can be recreated without typing demo content by hand.

Example:

```bash
SIMULATOR_ID=booted Scripts/capture_screenshot.sh
```

This captures:

- `dicho-home.png`
- `dicho-result.png`
- `dicho-paywall.png`
- `dicho-settings.png`

Screenshots will be written to `AppStoreAssets/Screenshots/`.

Capture a single scenario:

```bash
SCENARIO=result SIMULATOR_ID=booted Scripts/capture_screenshot.sh
```

Available scenarios:

- `home`
- `result`
- `paywall`
- `settings`

The script sets the simulator status bar to a clean 9:41, full battery, and full signal when supported.
