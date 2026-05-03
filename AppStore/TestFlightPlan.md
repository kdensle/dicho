# TestFlight Plan

## Internal Test Build

Goals:

- Confirm the production backend is reachable.
- Confirm StoreKit subscription products load from App Store Connect.
- Confirm purchase, restore, expiration, and revoked subscription states.
- Confirm the app does not ask for an OpenAI API key in Release.

Internal tester notes:

```text
Please test message translation in both directions.

1. Launch dicho and accept Terms/Privacy.
2. Choose Mexico and translate: "Can you come over later?"
3. Translate a Spanish message into English.
4. Try Paste, Copy, Clear, and keyboard Submit.
5. Open Settings and test appearance options.
6. Open Upgrade and verify price, Terms, Privacy, Restore Purchases, and Manage Subscription.

Please report crashes, confusing text, awkward translations, subscription issues, and messages that sound unnatural for the selected country.
```

## External Test Build

Run external testing only after:

- Backend `/health` returns 200.
- Backend `/ready` returns 200.
- QA eval set passes manual review.
- Subscription appears correctly in sandbox.
- Public Support, Privacy, and Terms URLs are live.

External beta description:

```text
dicho translates English and Spanish messages with country-aware phrasing. This beta focuses on translation quality, paywall clarity, and reliability before App Store launch.
```

Feedback email:

```text
support@dicho.app
```
