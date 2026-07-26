# Deploy Sprint Finale Submission

Complete this file on `main` as tasks are completed. Do not paste secrets, private keys, token values, or screenshots that reveal credentials.

## Team

- Team name: BigBug
- Team members: [Sithum Fernando, Ranuja Jayawardena, Sandaru Nethmina]
- Live IP URL: http://20.3.100.134
- Assigned domain URL: https://bigbug.deploysprint-finals.knurdz.org
- Repository URL: https://github.com/knurdz/deploy-sprint-finale-team-bigbug

## Release Evidence

- Current production commit:
- Current artifact/image identifier:
- Current deployment workflow run:
- Current release manifest path or URL:
- Notes on live evidence or fallback evidence:

## Score Summary

- Automated points out of 800:
- Judge points out of 200:
- Final total points out of 1000:

## Completed Tasks

Use this section for short public notes and links. Full task instructions and checks are in the finalist dashboard.

| Task | PR  | Evidence | Notes                                                                                                                                                                                    |
| ---- | --- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| T01  | #2  | [TBD]    | Added static `/health` endpoint and dynamic `/status` metadata via CI/Pages pipelines.                                                                                                   |
| T02  | #4  | [TBD]    | Connected custom domain.                                                                                                                                                                 |
| T03  | #8  | [TBD]    | Added a deploy-dry-run job in CI and modified pages.yml to download the CI build artifact rather than rebuilding source code.                                                            |
| T04  | #5  | [TBD]    | Added manual workflow_dispatch rollback workflow (.github/workflows/rollback.yml) accepting release_ref input to redeploy known-good release references without editing source code.     |
| T05  | #3  | [TBD]    | Moved runtime config to GitHub Secrets (`PUBLIC_URL`, `PRIVATE_DEPLOY_TOKEN`) and output safe redacted boolean flags in `/status`.                                                       |
| T06  | #6  | [TBD]    | Workflow explicitly builds on push/PR with npm ci and node 20, gates deployment.                                                                                                         |
| T07  | #7  | [TBD]    | Added OpenWeather API widget & deploy-time weather generator script (`generate-weather.mjs`); stored key in `OPENWEATHER_API_KEY` GitHub Secret without client exposure.                 |
| T08  | #10 | [TBD]    | Fetched and cleanly rebased the organizer's 'rebase-feature' branch onto main. Verified integration of the LearningVelocity component.                                                   |
| T09  | #9  | [TBD]    | Resolved merge conflict in deadlines.ts by preserving both deadline cards.                                                                                                               |
| T10  | #11 | [TBD]    | Added Web3Forms Contact modal & deploy-time generator (`generate-contact.mjs`); configured `WEB3FORMS_ACCESS_KEY` GitHub Secret and updated `/status` with `contact.provider=web3forms`. |
| T11  | #14 | [TBD]    | Added PR workflow step to generate a downloadable PR preview artifact, keeping production untouched.                                                                                                                                                                                        |
| T12  | #13 | [TBD]    | Verified that dependency caching with actions/cache or setup-node is safely implemented, tied to package-lock.json, and uses npm ci.                                                     |
| T13  | #15 | [TBD]    | Integrated organizer feature bundle: `ReleaseReadiness.tsx` component, `releaseReadiness.ts` data, and `check-release-readiness.mjs` validation script. Removed `AI-REVIEW-MARKER:T11`. Validation passes with `npm run check:readiness`. |
| T14  | #16 | [TBD]    | Added multi-stage Dockerfile (node:20-alpine build + nginx:alpine serve) and .dockerignore inside team-site/. Uses npm ci from lockfile. Image serves static Vite output on port 80.    |
| T15  | #18 | [TBD]    | Added feature flag utility and conditionally rendered LearningVelocity component; populated `/status` with redacted safe evidence. |
| T16  | #19 | [TBD]    | Added backend script and GitHub workflow for Resend alert to securely use RESEND_API_KEY without client exposure. |
| T17  | #TBD | [TBD]    | Implemented symlinked-release low-downtime deploy strategy (`scripts/low-downtime-deploy.sh`). CI `low-downtime-deploy` job creates candidate release in `releases/$SHA`, health-checks before switching `current` symlink, and preserves previous release on failure. Both success and failure paths are tested in CI. |
| T18  |     |          |                                                                                                                                                                                          |
| T19  |     |          |                                                                                                                                                                                          |
| T20  |     |          |                                                                                                                                                                                          |
| T21  |     |          |                                                                                                                                                                                          |
| T22  |     |          |                                                                                                                                                                                          |
| T23  |     |          |                                                                                                                                                                                          |
| T24  |     |          |                                                                                                                                                                                          |
| T25  |     |          |                                                                                                                                                                                          |
| T26  |     |          |                                                                                                                                                                                          |
| T27  |     |          |                                                                                                                                                                                          |
| T28  |     |          |                                                                                                                                                                                          |
| T29  |     |          |                                                                                                                                                                                          |
| T30  |     |          |                                                                                                                                                                                          |
