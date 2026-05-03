# Deployment Plan

## Backend

Deploy `Backend/` to a Node 20+ host behind HTTPS.

Recommended launch options:

- Render, Fly.io, Railway, Heroku, or a small container on AWS/GCP/Azure.
- Set `OPENAI_API_KEY` as a secret.
- Set `OPENAI_MODEL=gpt-5.4-mini`.
- Set `HOST=0.0.0.0`.
- Set `DATA_DIR` to a persistent volume if using the built-in JSON usage store.

Ready-to-use deployment files:

- Render blueprint: `render.yaml`
- Docker image: `Backend/Dockerfile`
- Railway config: `Backend/deploy/railway.toml`
- Fly.io template: `Backend/deploy/fly.toml.example`

Run the production environment doctor before deployment:

```bash
npm --prefix Backend run doctor:strict
```

Before meaningful scale, move usage tracking from the JSON file to a managed database such as Postgres, SQLite on a persistent volume, or DynamoDB.

## DNS

- Point `api.dicho.app` to the backend host later if you want a branded API domain. The current live backend is `https://dicho-api.onrender.com`.
- Enable HTTPS.
- Confirm `GET https://dicho-api.onrender.com/health` returns `200`.
- Confirm `GET https://dicho-api.onrender.com/ready` returns `200` only after `OPENAI_API_KEY` is configured.

## iOS

- Confirm `DICHO_API_BASE_URL` in Xcode is `https://dicho-api.onrender.com`.
- Confirm bundle ID is final: `com.kyledensley.dicho` or your Apple Developer account’s preferred identifier.
- Set your Apple Developer Team in Signing & Capabilities.
- Archive using Release.
- Upload to App Store Connect.

## App Store Connect

- Create the app record.
- Create the auto-renewable subscription product `dicho.pro.monthly`.
- Use `AppStore/AppStoreConnectPacket.md` for metadata and review notes.
- Use `AppStore/AppPrivacyAnswers.md` for the privacy-label draft.
- Add Privacy Policy URL, Terms URL, and Support URL.
- Complete App Privacy answers.
- Upload screenshots.
- Add review notes from `AppStoreMetadata.md`.

## Public Website

- Host `PublicSite/` at `https://stupendous-dasik-bfe500.netlify.app`.
- Confirm `/support`, `/privacy`, and `/terms` resolve publicly before App Review.
- Replace the placeholder support email if needed.
- Have counsel review the legal copy before launch.

## TestFlight

- Test backend health and subscription restore before inviting external testers.
- Use the eval set in `QA/translation_eval_cases.json` before every TestFlight build.
- Watch crashes, subscription purchase failures, backend errors, and translation quality feedback.
