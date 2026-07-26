# Broken Deploy Rehearsal

Seeded symptom: deployment artifact upload fails because the workflow points at `build`, but Vite writes production output to `dist`.

Expected fix: identify the log line, restore the previous release if production is affected, then change the workflow to upload/deploy `dist`.

## Incident Analysis & Resolution (T26)

- **Symptom**: The GitHub Actions deployment workflow (`deploy-broken.yml`) fails at the artifact upload step because it attempts to upload the non-existent `build` directory, whereas Vite builds frontend production files into `team-site/dist`.
- **Decisive Log Line**: `Error: No files were found with the provided path: build. No artifacts will be uploaded.`
- **Recovery Action**:
  1. **Rollback vs. Forward Fix**: If a broken deployment reaches live production and impairs user-facing availability (`/health` check failing or returning HTTP 500/404), rollback to a known-good release is performed first to immediately restore service and mitigate user impact. In this dry-run / rehearsal workflow where the failure occurred in CI artifact upload before production deployment, applying a forward fix directly to `.github/workflows/deploy-broken.yml` is the safest and fastest recovery path.
  2. **Workflow Forward Fix**: Updated `.github/workflows/deploy-broken.yml` step `Upload dist directory` to upload `team-site/dist` instead of `build`. Added `Prepare recovery request` and `Record recovery attempt` starter snippet steps with `RECOVERY_REF: ${{ github.sha }}`.
- **Verification**: Confirmed local build with `npm run build` generates `team-site/dist` cleanly and `npm run check:readiness` passes all sprint checks.
