# Release QA

## Translation Quality

- Run the eval set in `translation_eval_cases.json` against the deployed backend.
- Review country-specific outputs with native or fluent speakers before launch.
- Add failed real-world examples back into the eval set.
- Re-run evals before changing prompts, model, max tokens, or country guidance.

## StoreKit

- Product loads with localized price.
- Purchase succeeds.
- Restore succeeds.
- Cancelled purchase leaves user on free tier.
- Expired subscription returns user to free usage.
- Refund/revoked transaction removes pro access.
- Paywall links open Terms and Privacy.

## Backend

- `/health` returns `200`.
- `/ready` returns `200` only when `OPENAI_API_KEY` is configured.
- Free users stop at the monthly limit.
- Pro users are not charged against the free counter.
- Rate limiting returns `429` with a friendly app message.
- Raw message text does not appear in backend logs.

## iOS UX

- First launch shows Terms/Privacy acknowledgment.
- Legal acceptance persists after relaunch.
- Dynamic Type does not clip controls.
- VoiceOver names settings, paste, clear, copy, country, and translate controls.
- Light, dark, and system appearance all render cleanly.
- Offline/server-down errors are understandable.
- Successful translation auto-copies and gives feedback.

## App Store

- Bundle ID matches App Store Connect.
- Privacy Policy URL is public.
- Terms URL is public.
- Support URL is public.
- App Privacy answers match backend behavior.
- Screenshots match actual production UI.
