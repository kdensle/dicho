# Dicho

Dicho is a SwiftUI iOS prototype for Spanish message translation and country-aware reply drafting.

The first version focuses on:

- Automatic English/Spanish direction detection.
- Natural Spanish output tuned by country when English is entered.
- Natural English output when Spanish is entered.
- Automatic copying of the translated output.
- 30 free translations per calendar month, then a StoreKit subscription gate.
- In-app Privacy Policy and Terms of Use screens.
- Release builds call a backend URL from `DICHO_API_BASE_URL` instead of asking users for an OpenAI API key.
- First launch requires users to accept the current Terms of Use and acknowledge the Privacy Policy.
- A replaceable AI service layer using the OpenAI Responses API.

## Run

1. Open `Dicho.xcodeproj` in Xcode.
2. Select the `Dicho` scheme.
3. Add a development team in Signing & Capabilities if Xcode asks for one.
4. Run on an iOS 17+ simulator or device.
5. For Debug builds, open Settings in the app and add your OpenAI API key, or point `DICHO_API_BASE_URL` at a running backend.

## AI Notes

The app uses `gpt-5.4-mini` by default because OpenAI's current model docs describe it as a lower-latency, lower-cost frontier model with multilingual text support. The API call uses the Responses API and Structured Outputs so the UI receives predictable JSON.

For production, do not ship a raw API key inside the app. The Release app now calls the backend configured by `DICHO_API_BASE_URL`, currently `https://api.dicho.app`. The starter backend lives in `Backend/`.

## Subscription Setup

The app expects one auto-renewable subscription product:

- Product ID: `dicho.pro.monthly`
- Display name: `dicho pro`
- Recommended launch price: `$2.99/month`
- Free tier: `30` successful translations per calendar month

Create this in App Store Connect under a single subscription group. The paywall uses StoreKit to load the localized price, purchase, restore purchases, and unlock unlimited translations when the active entitlement is present.

Before App Store submission, host the Privacy Policy and Terms of Use at public URLs and add them to App Store Connect metadata. The in-app legal copy is in `Dicho/Models/LegalCopy.swift`.

## Release Prep Files

- `Backend/`: Node backend starter that owns the OpenAI API key.
- `PublicSite/`: static Support, Privacy, and Terms pages ready to host.
- `AppStore/`: App Store Connect metadata, privacy answers, subscription setup, and TestFlight notes.
- `Legal/PrivacyPolicy.md`: publishable privacy policy draft.
- `Legal/TermsOfUse.md`: publishable terms draft.
- `StoreKit/Dicho.storekit`: local StoreKit subscription test data.
- `QA/`: release QA checklist and translation eval runner.
- `Scripts/`: release checks, backend smoke test, and screenshot capture helpers.
- `render.yaml`: Render deployment blueprint for the backend.
- `Deployment.md`: backend and App Store deployment sequence.
- `LaunchHandoff.md`: exact list of steps that require your accounts or final decisions.
- `AppStoreMetadata.md`: App Store Connect copy draft.
- `AppStoreSubmissionChecklist.md`: release checklist.

The bundle identifier has been changed from `com.example.dicho` to `com.kyledensley.dicho`. Change it in Xcode if your Apple Developer account needs a different identifier.

The current legal acceptance version is `2026-05-03` in `Dicho/Models/LegalCopy.swift`. Increment it when Terms or Privacy materially change so users see the acknowledgment again.

Sources:

- OpenAI Responses API: https://platform.openai.com/docs/api-reference/responses
- OpenAI Structured Outputs: https://platform.openai.com/docs/guides/structured-outputs
- OpenAI Models: https://developers.openai.com/api/docs/models
- Apple auto-renewable subscriptions: https://developer.apple.com/app-store/subscriptions/
- Apple App Review Guidelines: https://developer.apple.com/appstore/resources/approval/guidelines.html
