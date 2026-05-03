#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${1:-${DICHO_API_BASE_URL:-http://127.0.0.1:8080}}"

echo "Checking ${API_BASE_URL}/health"
curl -fsS "${API_BASE_URL}/health"
echo

echo "Checking ${API_BASE_URL}/ready"
curl -fsS "${API_BASE_URL}/ready"
echo

if [[ "${TRANSLATE:-0}" == "1" ]]; then
  echo "Checking ${API_BASE_URL}/v1/translate"
  curl -fsS "${API_BASE_URL}/v1/translate" \
    -H "Content-Type: application/json" \
    -d '{
      "message": "Can you come over later?",
      "country": "mexico",
      "countryDisplayName": "Mexico",
      "clientID": "smoke-test-client-0001"
    }'
  echo
fi
