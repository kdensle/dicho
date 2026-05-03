# App Privacy Answers Draft

Use this as the working draft for App Store Connect's App Privacy section. Final answers should match the deployed backend, hosting provider logs, OpenAI data handling settings, and any analytics you add later.

## Tracking

Does the app use data to track users across apps and websites owned by other companies?

Recommended answer: `No`

The current app does not include ads, IDFA access, third-party ad SDKs, or cross-app tracking.

## Data Linked To The User

The app does not require accounts, names, email addresses, phone numbers, contacts, location, or social profiles.

Conservative recommendation: disclose the data below as `Not linked to the user's identity` unless you later add accounts, analytics profiles, or support tooling that ties usage to an email address or other identity.

## Data Types To Disclose

### User Content

Data type: `Emails or Text Messages` or `Other User Content`

Use: `App Functionality`

Reason: Users submit message text for translation. Message text is sent to the dicho backend and OpenAI to complete the translation request.

Notes:

- The app does not store message history locally.
- The backend does not intentionally log raw message text.
- Do not claim no collection if your OpenAI or hosting configuration retains request content for longer than real-time processing.

### Identifiers

Data type: `User ID`

Use: `App Functionality`, `Fraud Prevention`, `Security`

Reason: The app creates a random installation ID to manage monthly free usage, rate limiting, abuse prevention, and subscription access checks.

Notes:

- This is not IDFA.
- This is not a user account.
- If your hosting provider logs IP addresses, review whether additional disclosure is needed.

### Purchases

Data type: `Purchase History`

Use: `App Functionality`

Reason: StoreKit purchase and subscription status are used to unlock dicho pro. The backend may receive StoreKit entitlement payloads to verify active subscription access.

### Usage Data

Data type: `Product Interaction` or `Other Usage Data`

Use: `App Functionality`, `Fraud Prevention`

Reason: The app and backend track successful translation counts for the free monthly limit and may use request counts for rate limiting.

### Diagnostics

Data type: `Performance Data` and/or `Other Diagnostic Data`

Use: `App Functionality`, `Analytics`

Reason: Backend and platform logs may include request status, request IDs, errors, and availability checks. If you add crash reporting or analytics later, update this section.

## Data Not Currently Collected By The App

- Contact Info
- Location
- Contacts
- Photos or Videos
- Audio Data
- Search History
- Browsing History
- Sensitive Info
- Advertising Data
- Health & Fitness
- Financial Info, other than Apple-managed subscription payment handling

## Privacy Policy URL

Use:

```text
https://dicho.app/privacy
```

## Privacy Choices URL

Optional. If you host a support/data request page later, use:

```text
https://dicho.app/support
```
