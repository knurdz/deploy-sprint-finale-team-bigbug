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

| Task | PR | Evidence | Notes |
| --- | --- | --- | --- |
| T01 | #2 | [TBD] | Added static `/health` endpoint and dynamic `/status` metadata via CI/Pages pipelines. |
| T02 | #4 | [TBD] | Connected custom domain.  |
| T03 |  |  |  |
| T04 | #5 | [TBD] | Added manual workflow_dispatch rollback workflow (.github/workflows/rollback.yml) accepting release_ref input to redeploy known-good release references without editing source code. <!-- AI-REVIEW-MARKER: participant must manually remove this marker --> |
| T05 | #3 | [TBD] | Moved runtime config to GitHub Secrets (`PUBLIC_URL`, `PRIVATE_DEPLOY_TOKEN`) and output safe redacted boolean flags in `/status`. |
| T06 |  |  |  |
| T07 | [TBD] | `/api/weather` & `/status` | Added OpenWeather API widget & deploy-time weather generator script (`generate-weather.mjs`); stored key in `OPENWEATHER_API_KEY` GitHub Secret without client exposure. <!-- AI-REVIEW-MARKER: participant must manually remove this marker --> |
| T08 |  |  |  |
| T09 |  |  |  |
| T10 |  |  |  |
| T11 |  |  |  |
| T12 |  |  |  |
| T13 |  |  |  |
| T14 |  |  |  |
| T15 |  |  |  |
| T16 |  |  |  |
| T17 |  |  |  |
| T18 |  |  |  |
| T19 |  |  |  |
| T20 |  |  |  |
| T21 |  |  |  |
| T22 |  |  |  |
| T23 |  |  |  |
| T24 |  |  |  |
| T25 |  |  |  |
| T26 |  |  |  |
| T27 |  |  |  |
| T28 |  |  |  |
| T29 |  |  |  |
| T30 |  |  |  |
| Task | PR  | Evidence | Notes                                                                                                                                                                                |
| ---- | --- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| T01  | #2  | [TBD]    | Added static `/health` endpoint and dynamic `/status` metadata via CI/Pages pipelines.                                                                                               |
| T02  | #4  | [TBD]    | Connected custom domain.                                                                                                                                                             |
| T03  |     |          | Added a deploy-dry-run job in CI and modified pages.yml to download the CI build artifact rather than rebuilding source code.                                                        |
| T04  | #5  | [TBD]    | Added manual workflow_dispatch rollback workflow (.github/workflows/rollback.yml) accepting release_ref input to redeploy known-good release references without editing source code. |
| T05  | #3  | [TBD]    | Moved runtime config to GitHub Secrets (`PUBLIC_URL`, `PRIVATE_DEPLOY_TOKEN`) and output safe redacted boolean flags in `/status`.                                                   |
| T06  | [TBD] | [TBD] | Workflow explicitly builds on push/PR with npm ci and node 20, gates deployment. |
| T07  |     |          |                                                                                                                                                                                      |
| T08  |     |          |                                                                                                                                                                                      |
| T09  |     |          |                                                                                                                                                                                      |
| T10  |     |          |                                                                                                                                                                                      |
| T11  |     |          |                                                                                                                                                                                      |
| T12  |     |          |                                                                                                                                                                                      |
| T13  |     |          |                                                                                                                                                                                      |
| T14  |     |          |                                                                                                                                                                                      |
| T15  |     |          |                                                                                                                                                                                      |
| T16  |     |          |                                                                                                                                                                                      |
| T17  |     |          |                                                                                                                                                                                      |
| T18  |     |          |                                                                                                                                                                                      |
| T19  |     |          |                                                                                                                                                                                      |
| T20  |     |          |                                                                                                                                                                                      |
| T21  |     |          |                                                                                                                                                                                      |
| T22  |     |          |                                                                                                                                                                                      |
| T23  |     |          |                                                                                                                                                                                      |
| T24  |     |          |                                                                                                                                                                                      |
| T25  |     |          |                                                                                                                                                                                      |
| T26  |     |          |                                                                                                                                                                                      |
| T27  |     |          |                                                                                                                                                                                      |
| T28  |     |          |                                                                                                                                                                                      |
| T29  |     |          |                                                                                                                                                                                      |
| T30  |     |          |                                                                                                                                                                                      |

## Public Notes

### T07 Judge Question: Why is the OpenWeather API key stored as a GitHub Secret instead of a `VITE_*` variable?
Vite environment variables prefixed with `VITE_*` (such as `VITE_OPENWEATHER_API_KEY`) are statically replaced and bundled directly into plain-text client JavaScript files during `vite build`. Any user visiting the website could open browser Developer Tools, inspect the static JS bundles or network requests, and extract the API key. By storing `OPENWEATHER_API_KEY` as a GitHub Secret, the key exists solely in the server-side CI/CD execution environment. During build/deployment, our server-side process (`generate-weather.mjs`) calls OpenWeather and outputs a safe, sanitized JSON payload (`/api/weather`) containing only the weather results (`temp`, `city`, `weather.provider=openweather`), ensuring the raw secret is never transmitted to or accessible by client browsers.
