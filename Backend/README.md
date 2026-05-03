# dicho backend

This is the production API starter for the iOS app. It keeps the OpenAI API key out of the app bundle and exposes one endpoint the app can call.

It includes:

- Health and readiness checks.
- Request IDs and structured logs that do not include raw message text.
- Basic IP rate limiting.
- Persistent monthly free-usage tracking by installation ID.
- StoreKit transaction JWS entitlement checks for `dicho.pro.monthly`.
- Friendly error envelopes for the iOS app.

## Run locally

```bash
cp .env.example .env
export $(grep -v '^#' .env | xargs)
npm start
```

Then set the iOS build setting `DICHO_API_BASE_URL` to `http://localhost:8080` for local backend testing.

## Production checks

Before deploying, run:

```bash
npm run doctor:strict
```

The doctor checks required secrets and launch-critical settings without printing the OpenAI API key.

## Container deploy

The backend includes a production `Dockerfile` and `/health` healthcheck. It has no runtime npm dependencies today; the image copies only the Node scripts it needs.

Build locally:

```bash
docker build -t dicho-api .
docker run --env-file .env -p 8080:8080 -v dicho-data:/data dicho-api
```

Deployment templates are included for:

- Render: `../render.yaml`
- Railway: `deploy/railway.toml`
- Fly.io: `deploy/fly.toml.example`

## Endpoints

`GET /health`

Returns server status.

`GET /ready`

Returns dependency readiness. This is `503` until `OPENAI_API_KEY` is configured.

`POST /v1/translate`

Request:

```json
{
  "message": "Can you come over later?",
  "country": "mexico",
  "countryDisplayName": "Mexico",
  "clientID": "device-installation-id",
  "entitlementJWS": "optional-storekit-transaction-jws"
}
```

Response matches the iOS `TranslationResult` model:

```json
{
  "sourceLanguage": "English",
  "targetLanguage": "Spanish",
  "directionLabel": "English -> Mexican Spanish",
  "translation": "Puedes venir mas tarde?",
  "nuance": "Casual and natural.",
  "countryNotes": [],
  "confidence": "High"
}
```

## Before production

- Replace the local JSON usage store with a managed database before meaningful scale.
- Put the service behind HTTPS and a reverse proxy or managed app platform.
- Keep `ALLOW_UNSIGNED_STOREKIT_JWS=false` in production. Only use `true` for local StoreKit testing when you fully understand the tradeoff.
- Add monitoring and alerts for latency, OpenAI failures, 402 paywall rates, 429 rate limits, and 5xx errors.
- Deploy behind HTTPS, then update `DICHO_API_BASE_URL` in the Xcode project.

## Environment

- `OPENAI_API_KEY`: required for translation.
- `OPENAI_MODEL`: defaults to `gpt-5.4-mini`.
- `DATA_DIR`: defaults to `./data`.
- `FREE_MONTHLY_LIMIT`: defaults to `30`.
- `MAX_MESSAGE_CHARS`: defaults to `4000`.
- `MAX_REQUEST_BYTES`: defaults to `65536`.
- `RATE_LIMIT_WINDOW_MS`: defaults to `60000`.
- `RATE_LIMIT_MAX_REQUESTS`: defaults to `25`.
- `APPLE_BUNDLE_ID`: defaults to `com.kyledensley.dicho`.
- `SUBSCRIPTION_PRODUCT_ID`: defaults to `dicho.pro.monthly`.
- `ALLOW_UNSIGNED_STOREKIT_JWS`: defaults to `false`.
- `ALLOWED_ORIGINS`: optional comma-separated CORS allowlist.
