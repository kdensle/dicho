# Launch Handoff

Everything below this line requires your accounts, credentials, domain, or final business decisions.

## 1. Apple Developer

- Enroll or confirm access to the Apple Developer Program.
- Confirm your Team ID.
- Set the Xcode project Development Team for the `Dicho` target.
- Confirm the final bundle ID is `com.kyledensley.dicho`.

## 2. App Store Connect

- Create the iOS app record for `dicho`.
- Create the auto-renewable subscription product `dicho.pro.monthly`.
- Add the App Store metadata from `AppStore/AppStoreConnectPacket.md`.
- Add the App Privacy answers from `AppStore/AppPrivacyAnswers.md`.
- Add Support, Privacy, and Terms URLs after the public site is hosted.

## 3. Backend Host

- Choose Render, Railway, Fly.io, or another Node/container host.
- Deploy the backend from `Backend/`.
- Add `OPENAI_API_KEY` as a secret.
- Confirm `/health` returns 200.
- Confirm `/ready` returns 200.
- Point `api.dicho.app` or your final API domain to the backend.

## 4. Public Website

- Host `PublicSite/` at `https://dicho.app`.
- Confirm these URLs work:
  - `https://dicho.app/support`
  - `https://dicho.app/privacy`
  - `https://dicho.app/terms`
- Replace `support@dicho.app` if you use a different monitored support address.
- Have counsel review final legal copy.

## 5. TestFlight

- Archive a Release build from Xcode.
- Upload the build to App Store Connect.
- Add internal testers.
- Confirm StoreKit product loading, purchase, restore, expiration, and revoked transaction behavior.
- Run `QA/run_backend_eval.mjs` against the production backend.

## 6. App Review

- Select the uploaded build for version 1.0.
- Select the subscription product so it is reviewed with the app.
- Upload screenshots and subscription review screenshot.
- Add Review Notes from `AppStore/AppStoreConnectPacket.md`.
- Submit for review.

## Recommended Pre-Submission Command Set

Run these from the `Dicho/` directory before every TestFlight or App Review build:

```bash
npm --prefix Backend run doctor:strict
npm --prefix Backend run check
node --check QA/run_backend_eval.mjs
plutil -lint Dicho.xcodeproj/project.pbxproj Dicho/Info.plist
xcodebuild -project Dicho.xcodeproj -scheme Dicho -configuration Release -destination 'generic/platform=iOS' archive -archivePath /tmp/Dicho.xcarchive
```
