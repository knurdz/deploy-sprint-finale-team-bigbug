#!/usr/bin/env bash
# AI-REVIEW-MARKER: participant must manually remove this marker
# T19 - Post-Deploy Smoke Tests
set -euo pipefail

base_url="${PUBLIC_URL:?PUBLIC_URL required}"
expected_sha="${EXPECTED_SHA:-$GITHUB_SHA}"
max_attempts="${RETRIES:-12}"
retry_delay="${RETRY_DELAY:-5}"

echo "=== T19 Post-Deploy Smoke Tests ==="
echo "Target Base URL: ${base_url}"
echo "Expected SHA:    ${expected_sha}"

# 1. Check homepage "/"
echo "-> Checking homepage: ${base_url}/"
curl --fail --show-error --location --silent --output /dev/null "${base_url}/"
echo "✅ Homepage (/) check passed."

# 2. Check "/health"
echo "-> Checking health endpoint: ${base_url}/health"
curl --fail --show-error --silent "${base_url}/health" > /dev/null
echo "✅ Health check (/health) passed."

# 3. Check task-specific marker ("/api/weather.json")
echo "-> Checking task-specific route: ${base_url}/api/weather.json"
curl --fail --show-error --silent "${base_url}/api/weather.json" > /dev/null
echo "✅ Task-specific route (/api/weather.json) check passed."

# 4. Check "/status" and verify expected commit SHA with retry logic
echo "-> Checking status endpoint and commit SHA: ${base_url}/status"
attempt=1
success=false

while [ "${attempt}" -le "${max_attempts}" ]; do
  echo "Attempt ${attempt}/${max_attempts}: Fetching /status..."
  status_body=$(curl --fail --show-error --silent "${base_url}/status")
  echo "Received /status response: ${status_body}"
  
  if echo "${status_body}" | grep -q "${expected_sha}"; then
    echo "✅ Status verified! Expected commit SHA (${expected_sha}) found in /status."
    success=true
    break
  else
    echo "⚠️ Commit SHA (${expected_sha}) not found in /status yet. Retrying in ${retry_delay}s..."
    sleep "${retry_delay}"
    attempt=$((attempt + 1))
  fi
done

if [ "${success}" != "true" ]; then
  echo "❌ ERROR: Smoke tests failed after ${max_attempts} attempts. Expected commit SHA (${expected_sha}) was not found in /status."
  exit 1
fi

echo "✅ T19 smoke tests passed successfully for all target routes: /, /health, /status"
