# QA

This folder holds repeatable checks for translation quality, subscriptions, backend behavior, and release readiness.

## Backend Eval

Start the deployed or local backend, then run:

```bash
DICHO_API_BASE_URL=http://127.0.0.1:8080 node QA/run_backend_eval.mjs
```

The script prints one JSON block per eval case. Review each output against the listed checks.

## Manual QA

Use `ReleaseQA.md` for the full pre-TestFlight and pre-App-Review pass.

## Release Checks

From the project root, run:

```bash
Scripts/release_check.sh
```

To include a Release simulator build:

```bash
Scripts/release_check.sh --build-simulator
```
