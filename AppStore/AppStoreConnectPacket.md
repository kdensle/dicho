# App Store Connect Packet

This is the copy/paste packet for App Store Connect. Replace bracketed placeholders before submission.

## App Information

Name: `dicho spanish translator`

In-app brand: `dicho`

Subtitle: `Spanish that sounds natural`

Bundle ID: `com.kyledensley.dicho`

SKU: `dicho-ios-001`

Primary category: `Utilities`

Secondary category: `Productivity`

Content rights: `No third-party content is displayed in the app.`

Age rating notes: The app translates user-entered text. It does not include social networking, unrestricted web access, gambling, contests, ads, or user-generated public content.

## Pricing

App price: Free

In-app purchase: Auto-renewable monthly subscription

Product ID: `dicho.pro.monthly`

Display name: `dicho pro`

Reference name: `dicho pro monthly`

Duration: 1 month

Launch price: `$2.99/month`

Description: `Unlimited AI translations`

Subscription group reference name: `dicho pro`

## App Store Version Copy

Version: `1.0`

Promotional text:

```text
Translate English and Spanish messages with country-aware phrasing that sounds natural.
```

Description:

```text
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
```

Keywords:

```text
spanish,english,translation,translator,messages,reply,language,mexico,spain,ai
```

What's New:

```text
Initial release.
```

## URLs

Marketing URL: `https://stupendous-dasik-bfe500.netlify.app`

Support URL: `https://stupendous-dasik-bfe500.netlify.app/support`

Privacy Policy URL: `https://stupendous-dasik-bfe500.netlify.app/privacy`

Terms of Use URL: `https://stupendous-dasik-bfe500.netlify.app/terms`

## App Review Notes

```text
dicho is an AI-assisted Spanish-English message translation app.

No account is required. The app asks users to acknowledge Terms of Use and Privacy Policy on first launch, then opens directly to the translator.

The app provides 30 free translations per calendar month. After that, users can subscribe to dicho pro using the auto-renewable monthly subscription product dicho.pro.monthly. The paywall includes Terms, Privacy, Restore Purchases, and Manage Subscription controls.

Release builds call the developer-operated backend configured at DICHO_API_BASE_URL. The backend owns the OpenAI API key, enforces free usage server-side, checks StoreKit entitlement payloads for the subscription, and does not intentionally log raw message text.

Suggested review flow:
1. Launch the app and accept the Terms/Privacy acknowledgment.
2. Enter "Can you come over later?", choose Mexico, and tap Translate.
3. Confirm the translation output appears and is copied automatically.
4. Enter a Spanish message and confirm it translates into English.
5. Open Settings to verify Terms, Privacy, Restore Purchases, Manage Subscription, and appearance settings.
6. Open the paywall from the Upgrade button to review subscription presentation.

Backend health checks:
Health: https://dicho-api.onrender.com/health
Readiness: https://dicho-api.onrender.com/ready
```

## Export Compliance Draft

The app uses standard HTTPS/TLS networking to communicate with the dicho backend and Apple/OpenAI services. It does not implement custom cryptography.

Answer Apple's export compliance questions according to the final build and your legal/compliance position.
