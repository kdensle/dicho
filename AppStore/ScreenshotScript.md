# Screenshot Script

Use these lines as optional overlay copy or manual checklist labels when preparing App Store screenshots.

## 1. Home

State: `SCENARIO=home`

Input:

```text
Can you come over later?
```

Suggested overlay:

```text
Natural Spanish for real messages
```

## 2. Result

State: `SCENARIO=result`

Input:

```text
I didn't mean it that way.
```

Output shown: a polished Spanish apology translation with natural tone notes.

Suggested overlay:

```text
Tone-aware translations you can paste instantly
```

## 3. Paywall

State: `SCENARIO=paywall`

Suggested overlay:

```text
30 free translations monthly
```

## 4. Settings

State: `SCENARIO=settings`

Suggested overlay:

```text
Light, dark, and system mode
```

## Capture Command

```bash
SIMULATOR_ID=booted Scripts/capture_screenshot.sh
```

The generated files appear in `AppStoreAssets/Screenshots/`.
