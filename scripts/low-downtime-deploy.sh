#!/usr/bin/env bash
# T17 - Low-Downtime Release Strategy
# Symlinked-release deploy script: deploys a candidate release into a
# separate directory, health-checks it, and only switches the "current"
# symlink after success. Preserves the previous known-good release on failure.

set -euo pipefail

# --- Configuration -----------------------------------------------------------
DEPLOY_BASE="${DEPLOY_BASE:-/tmp/releases-sim}"      # Base path for releases
RELEASE_SHA="${RELEASE_SHA:-${GITHUB_SHA:-$(date +%s)}}"
HEALTH_URL="${HEALTH_URL:-}"
HEALTH_RETRIES="${HEALTH_RETRIES:-3}"
HEALTH_RETRY_DELAY="${HEALTH_RETRY_DELAY:-5}"
SWITCH_ONLY_AFTER_HEALTH="${SWITCH_ONLY_AFTER_HEALTH:-true}"
KEEP_PREVIOUS_RELEASE_ON_FAILURE="${KEEP_PREVIOUS_RELEASE_ON_FAILURE:-true}"
CANDIDATE_DIR="${DEPLOY_BASE}/releases/${RELEASE_SHA}"
CURRENT_LINK="${DEPLOY_BASE}/current"
MAX_KEPT_RELEASES="${MAX_KEPT_RELEASES:-5}"

# --- Functions ----------------------------------------------------------------
log() { echo "[T17 $(date -u +'%H:%M:%SZ')] $*"; }

prepare_candidate() {
  log "=== Phase 1: Prepare candidate release ==="
  log "Candidate SHA : ${RELEASE_SHA}"
  log "Candidate dir : ${CANDIDATE_DIR}"

  mkdir -p "${CANDIDATE_DIR}"

  # Copy build artifacts into the candidate release directory
  if [ -d "${ARTIFACT_SOURCE:-}" ]; then
    log "Copying artifacts from ${ARTIFACT_SOURCE} -> ${CANDIDATE_DIR}"
    cp -r "${ARTIFACT_SOURCE}/." "${CANDIDATE_DIR}/"
  else
    log "(dry-run) No ARTIFACT_SOURCE set; creating placeholder files"
    echo '{"status":"ok","release":"'"${RELEASE_SHA}"'"}' > "${CANDIDATE_DIR}/health"
    echo '{"release":"'"${RELEASE_SHA}"'","time":"'"$(date -u +'%Y-%m-%dT%H:%M:%SZ')"'"}' > "${CANDIDATE_DIR}/status"
  fi

  log "Candidate release prepared at ${CANDIDATE_DIR}"
}

health_check() {
  log "=== Phase 2: Health-check candidate release ==="

  # If a HEALTH_URL is provided, check it with curl
  if [ -n "${HEALTH_URL}" ]; then
    log "Checking HEALTH_URL: ${HEALTH_URL}"
    local attempt=0
    while [ "$attempt" -lt "$HEALTH_RETRIES" ]; do
      attempt=$((attempt + 1))
      log "Health check attempt ${attempt}/${HEALTH_RETRIES}..."
      if curl -sf --max-time 10 "${HEALTH_URL}" > /dev/null 2>&1; then
        log "Health check PASSED (remote URL)"
        return 0
      fi
      [ "$attempt" -lt "$HEALTH_RETRIES" ] && sleep "${HEALTH_RETRY_DELAY}"
    done
    log "Health check FAILED after ${HEALTH_RETRIES} attempts"
    return 1
  fi

  # Fallback: check the candidate directory for a health file
  log "No HEALTH_URL set; verifying local candidate health file"
  if [ -f "${CANDIDATE_DIR}/health" ]; then
    log "Candidate health file exists at ${CANDIDATE_DIR}/health"
    log "Contents: $(cat "${CANDIDATE_DIR}/health")"
    log "Health check PASSED (local file)"
    return 0
  else
    log "Health check FAILED: no health file in candidate directory"
    return 1
  fi
}

switch_traffic() {
  log "=== Phase 3: Switch traffic to candidate release ==="

  # Record the previous release for rollback reference
  if [ -L "${CURRENT_LINK}" ]; then
    PREVIOUS_RELEASE=$(readlink -f "${CURRENT_LINK}")
    log "Previous release: ${PREVIOUS_RELEASE}"
  else
    PREVIOUS_RELEASE=""
    log "No previous release found (first deploy)"
  fi

  # Update symlink atomically
  ln -sfn "${CANDIDATE_DIR}" "${CURRENT_LINK}"
  log "Symlink updated: ${CURRENT_LINK} -> ${CANDIDATE_DIR}"

  # Verify the switch
  ACTUAL_TARGET=$(readlink -f "${CURRENT_LINK}")
  if [ "${ACTUAL_TARGET}" = "$(readlink -f "${CANDIDATE_DIR}")" ]; then
    log "Traffic switch VERIFIED — current now points to ${RELEASE_SHA}"
  else
    log "WARNING: Symlink verification mismatch!"
  fi

  # Write release manifest
  cat > "${DEPLOY_BASE}/release-manifest.json" <<MANIFEST
{
  "task": "T17",
  "strategy": "symlinked-release",
  "currentRelease": "${RELEASE_SHA}",
  "previousRelease": "${PREVIOUS_RELEASE:-none}",
  "candidateDir": "${CANDIDATE_DIR}",
  "switchTime": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "healthCheckPassed": true,
  "switchOnlyAfterHealth": ${SWITCH_ONLY_AFTER_HEALTH},
  "keepPreviousOnFailure": ${KEEP_PREVIOUS_RELEASE_ON_FAILURE}
}
MANIFEST
  log "Release manifest written to ${DEPLOY_BASE}/release-manifest.json"
}

handle_failure() {
  log "=== FAILURE PATH: Health check did not pass ==="
  log "KEEP_PREVIOUS_RELEASE_ON_FAILURE=${KEEP_PREVIOUS_RELEASE_ON_FAILURE}"

  if [ "${KEEP_PREVIOUS_RELEASE_ON_FAILURE}" = "true" ]; then
    if [ -L "${CURRENT_LINK}" ]; then
      CURRENT_TARGET=$(readlink -f "${CURRENT_LINK}")
      log "Current symlink still points to: ${CURRENT_TARGET}"
      log "Previous known-good release PRESERVED — no traffic switch performed"
    else
      log "No current symlink exists — nothing to preserve"
    fi
  fi

  # T28: Partial cleanup of failed candidate directory
  if [ -d "${CANDIDATE_DIR}" ]; then
    log "Cleaning up failed candidate directory: ${CANDIDATE_DIR}"
    rm -rf "${CANDIDATE_DIR}"
  fi

  # Write failure manifest
  cat > "${DEPLOY_BASE}/release-manifest.json" <<MANIFEST
{
  "task": "T17",
  "strategy": "symlinked-release",
  "currentRelease": "$([ -L "${CURRENT_LINK}" ] && basename "$(readlink -f "${CURRENT_LINK}")" || echo "none")",
  "failedCandidate": "${RELEASE_SHA}",
  "candidateDir": "${CANDIDATE_DIR}",
  "failureTime": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "healthCheckPassed": false,
  "trafficSwitched": false,
  "previousReleasePreserved": true,
  "switchOnlyAfterHealth": ${SWITCH_ONLY_AFTER_HEALTH},
  "keepPreviousOnFailure": ${KEEP_PREVIOUS_RELEASE_ON_FAILURE}
}
MANIFEST
  log "Failure manifest written to ${DEPLOY_BASE}/release-manifest.json"
}

cleanup_old_releases() {
  log "=== Phase 4: Cleanup old releases (keep last ${MAX_KEPT_RELEASES}) ==="
  local releases_dir="${DEPLOY_BASE}/releases"
  if [ -d "${releases_dir}" ]; then
    local count
    count=$(ls -1d "${releases_dir}"/*/ 2>/dev/null | wc -l || echo 0)
    if [ "$count" -gt "$MAX_KEPT_RELEASES" ]; then
      local to_remove=$((count - MAX_KEPT_RELEASES))
      log "Found ${count} releases, removing ${to_remove} oldest"
      ls -1td "${releases_dir}"/*/ | tail -n "${to_remove}" | while read -r old_dir; do
        # Never remove the current release
        if [ -L "${CURRENT_LINK}" ] && [ "$(readlink -f "${old_dir}")" = "$(readlink -f "${CURRENT_LINK}")" ]; then
          log "Skipping current release: ${old_dir}"
          continue
        fi
        log "Removing old release: ${old_dir}"
        rm -rf "${old_dir}"
      done
    else
      log "Only ${count} releases present, no cleanup needed"
    fi
  fi
}

# --- Main Execution -----------------------------------------------------------
main() {
  # Ensure base directory exists for lockfile
  mkdir -p "${DEPLOY_BASE}"

  # T28: Race-Safe Locking
  exec 9> "${DEPLOY_BASE}/deploy.lock"
  if ! flock -n 9; then
    log "ERROR: Another deployment is currently in progress. Exiting."
    exit 1
  fi

  # T28: Idempotency Check
  if [ -L "${CURRENT_LINK}" ]; then
    CURRENT_TARGET=$(basename "$(readlink -f "${CURRENT_LINK}")")
    if [ "${CURRENT_TARGET}" = "${RELEASE_SHA}" ]; then
      log "Idempotency check: Release ${RELEASE_SHA} is already active. Exiting successfully."
      exit 0
    fi
  fi

  log "=============================================="
  log "T17 Low-Downtime Release Strategy"
  log "=============================================="
  log "Deploy base     : ${DEPLOY_BASE}"
  log "Release SHA     : ${RELEASE_SHA}"
  log "Health URL      : ${HEALTH_URL:-<local file check>}"
  log "Switch after OK : ${SWITCH_ONLY_AFTER_HEALTH}"
  log "Keep prev on fail: ${KEEP_PREVIOUS_RELEASE_ON_FAILURE}"
  log "=============================================="

  # Step 1: Prepare candidate
  prepare_candidate

  # Step 2: Health check candidate
  if health_check; then
    # Step 3: Switch traffic
    switch_traffic
    # Step 4: Cleanup old releases
    cleanup_old_releases
    log "=============================================="
    log "DEPLOY SUCCESS: Release ${RELEASE_SHA} is now live"
    log "=============================================="
  else
    # Failure path — keep the old release
    handle_failure
    log "=============================================="
    log "DEPLOY ABORTED: Candidate ${RELEASE_SHA} failed health check"
    log "Previous known-good release is still active"
    log "=============================================="
    exit 1
  fi
}

main "$@"
