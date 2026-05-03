# App Store Metadata Draft

## Name

dicho

## Subtitle

Natural Spanish-English translation

## Promotional Text

Translate English and Spanish messages with country-aware phrasing that sounds natural.

## Description

dicho helps you translate messages between English and Spanish with wording that fits real conversation.

Choose a Spanish-speaking country, enter a message, and dicho automatically detects whether the message is English or Spanish. English messages are translated into natural Spanish for the country you selected. Spanish messages are translated into clear, natural English.

dicho is built for private messages, quick replies, and tone-sensitive everyday communication. Output is copied automatically so you can paste it wherever you need it.

Features:
- Automatic English/Spanish detection
- Country-aware Spanish for Mexico, Spain, Colombia, Argentina, Chile, Peru, Puerto Rico, and U.S. Spanish
- Natural English translation from Spanish
- Auto-copy output
- Light, dark, and system appearance modes
- 30 free translations per month
- Optional dicho pro subscription for continued access

Translations are AI-generated and may be imperfect. Always review important messages before sending.

## Keywords

spanish,english,translation,translator,messages,reply,language,mexico,spain,ai

## Category

Utilities

## Review Notes

dicho is an AI-assisted Spanish-English message translation app.

No account is required. The app asks users to acknowledge Terms of Use and Privacy Policy on first launch, then opens directly to the translator.

The app provides 30 free translations per calendar month. After that, users can subscribe to dicho pro using the auto-renewable monthly subscription product `dicho.pro.monthly`.

The app includes in-app links to Terms of Use and Privacy Policy from Settings and the subscription paywall. The app does not require users to bring their own OpenAI API key in Release builds. Release builds call the developer-operated backend, which owns the OpenAI API key, enforces free usage server-side, checks StoreKit entitlement payloads for subscription access, and does not intentionally log raw message text.

Please test with:
- Enter an English message, choose Mexico, tap Translate.
- Enter a Spanish message, tap Translate.
- Open the Upgrade paywall to verify subscription presentation.
- Open Settings to verify Terms, Privacy, Restore Purchases, Manage Subscription, and appearance controls.

Backend health checks:
- Health: `https://api.dicho.app/health`
- Readiness: `https://api.dicho.app/ready`

## Support URL

https://dicho.app/support

## Privacy Policy URL

https://dicho.app/privacy

## Terms of Use URL

https://dicho.app/terms
