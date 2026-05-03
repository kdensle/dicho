# App Store Submission Checklist

## App Store Connect

- Confirm the bundle identifier `com.kyledensley.dicho`, or replace it with your final Apple Developer bundle ID.
- Use `AppStore/AppStoreConnectPacket.md` for copy/paste metadata.
- Use `AppStore/AppPrivacyAnswers.md` for the first privacy-label draft.
- Add the app Privacy Policy URL. Apple requires this for all apps.
- Add Terms of Use URL and Privacy Policy URL in app metadata because the app offers subscriptions.
- Complete App Privacy details. This app sends user-entered message text and selected country to OpenAI for translation and uses Apple for subscriptions.
- Add a support URL with working contact information.
- Make sure all metadata and URLs are final and reachable before review.

## Subscription

- Create one subscription group.
- Add one auto-renewable subscription:
  - Product ID: `dicho.pro.monthly`
  - Display name: `dicho pro`
  - Duration: 1 month
  - Recommended launch price: `$2.99/month`
- Add review notes explaining that users get 30 free translations per calendar month, then a subscription unlocks unlimited translations.
- Use `AppStore/SubscriptionSetup.md` while creating the subscription product.
- Add a screenshot for the subscription review item.
- Test purchase and restore in StoreKit testing or App Store sandbox before submitting.
- Use `StoreKit/Dicho.storekit` for local purchase, cancellation, expiration, and restore testing.

## Legal Copy

- Review the in-app Privacy Policy and Terms of Use in `Dicho/Models/LegalCopy.swift`.
- Review the publishable drafts in `Legal/PrivacyPolicy.md` and `Legal/TermsOfUse.md`.
- Confirm the first-launch legal acknowledgment appears before the translator on a fresh install.
- Increment `LegalDocument.currentVersion` when Terms or Privacy materially change.
- Replace `support@dicho.app` with a real monitored support address if needed.
- Host matching Privacy Policy and Terms of Use pages publicly.
- Have counsel review the final legal text before launch.

## Accounts

- Do not add account creation for v1 unless a new feature truly needs it.
- If accounts are added later, add in-app account deletion before App Store submission.

## Production API

- Run `npm --prefix Backend run doctor:strict` before deploying.
- Release builds now call `DICHO_API_BASE_URL` instead of asking users for an OpenAI API key.
- Deploy the starter backend in `Backend/` behind HTTPS.
- Set `OPENAI_API_KEY` and `OPENAI_MODEL` on the backend host.
- Backend now enforces monthly usage counts server-side by installation ID.
- Backend now checks StoreKit transaction JWS for active `dicho.pro.monthly` entitlement.
- Xcode `DICHO_API_BASE_URL` is currently `https://dicho-api.onrender.com`.
- Replace the JSON usage store with a managed database before meaningful scale.

## Quality

- Run `Scripts/release_check.sh`.
- Run `QA/run_backend_eval.mjs` against the deployed backend.
- Review `QA/ReleaseQA.md` before every TestFlight build.
- Add real user misses to `QA/translation_eval_cases.json`.

## Pricing Rationale

The current app uses `gpt-5.4-mini`. At current OpenAI list pricing, short message translation is typically well under one cent per request. A $2.99 monthly subscription leaves room for Apple proceeds, normal API usage, and support costs for an average user who translates several messages per day. Revisit this after you have real usage data from TestFlight or production analytics.
