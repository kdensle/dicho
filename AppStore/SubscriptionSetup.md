# Subscription Setup

Create one auto-renewable subscription in App Store Connect before submitting version 1.0.

## Subscription Group

Reference name: `dicho pro`

App Store localization:

- Display name: `dicho pro`

## Subscription Product

Product ID: `dicho.pro.monthly`

Reference name: `dicho pro monthly`

Duration: `1 month`

Price: `$2.99/month`

Display name: `dicho pro`

Description:

```text
Unlimited AI translations
```

Review notes:

```text
dicho pro unlocks continued translation after the monthly free allowance. Users receive 30 free translations per calendar month. When the free allowance is used, the app presents the dicho pro paywall with price, restore purchases, Terms of Use, and Privacy Policy.
```

## Required Screenshot

Upload a screenshot of the in-app paywall showing:

- Subscription title
- Monthly price loaded from StoreKit
- Subscribe button
- Restore Purchases
- Terms and Privacy links

Use local StoreKit testing first with `StoreKit/Dicho.storekit`, then App Store sandbox/TestFlight after the product is created.

## App Review Timing

For the first subscription, submit the subscription together with app version 1.0. Do not submit the app version without selecting the subscription product in the In-App Purchases and Subscriptions section.
