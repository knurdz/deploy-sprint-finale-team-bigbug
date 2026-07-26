# Seeded Secret Leak Drill

Seeded test token: DEPLOY_SPRINT_TEST_TOKEN_T23_DO_NOT_USE

This is not a real credential, but teams must treat it like a leaked secret: remove it, scan for it, and document cleanup/rotation decisions.

## T27 Incident Remediation & Rotation Protocol

- **Remediation**: Removed the hardcoded test token (`DEPLOY_SPRINT_TEST_TOKEN_T23_DO_NOT_USE`) from `.github/workflows/leaky-debug.yml` and replaced it with a safe placeholder (`[REDACTED_TEST_TOKEN_T27]`).
- **Scan Targets Assessed**: Scanned source code, workflows, generated build output (`team-site/dist`), logs, and artifacts. Verified zero remaining occurrences of the seeded test token or private key patterns.
- **Automated Prevention**: Added an automated secret scanning step (`Scan for secret leaks (T27)`) to `.github/workflows/ci.yml` that checks for private key headers (`-----BEGIN .*PRIVATE KEY-----`) and token prefixes (`github_pat_`, `ghp_`, `GOCSPX-`) using `rg`.
- **Rotation & Revocation Protocol (Judge Question)**:
  1. **Immediate Revocation**: Deactivate and invalidate the exposed credential in the issuer console immediately to block unauthorized use.
  2. **Rotate & Store Securely**: Generate a replacement credential and store it exclusively in an encrypted secrets manager (such as GitHub Secrets), injecting it via environment variables (`${{ secrets.SECRET_NAME }}`).
  3. **Audit Access Logs**: Examine API audit trails and access logs during the exposure window for unauthorized activity.
  4. **Scrub Git History**: Remove token references from code and, if real sensitive credentials were committed, scrub repository history using `git filter-repo` or BFG Repo-Cleaner.
  5. **Enforce Automated Scanning**: Integrate CI/CD secret scanners to block future PRs containing token or key patterns.
