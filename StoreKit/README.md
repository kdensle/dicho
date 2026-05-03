# StoreKit Testing

Use `Dicho.storekit` for local subscription testing before the App Store Connect product is live.

1. Open `Dicho.xcodeproj` in Xcode.
2. Select the shared `Dicho` scheme.
3. Edit the `Dicho` scheme.
4. Select `Run > Options`.
5. Set `StoreKit Configuration` to `Dicho.storekit`.
6. Run on a simulator.
7. Open the paywall and purchase `dicho pro`.

Test these scenarios:

- Purchase succeeds.
- Purchase cancelled.
- Restore purchases succeeds.
- Subscription expires in StoreKit Transaction Manager.
- Refund/revocation removes access.

Apple notes StoreKit configuration files are local test data and do not upload to App Store Connect. You still need to create the matching product ID `dicho.pro.monthly` in App Store Connect before TestFlight/App Review.
