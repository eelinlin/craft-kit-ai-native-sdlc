# <Repo name>

Workflow, artifact formats, standards and gates come from the `sdlc` plugin (and any stack pack in
`.claude/settings.json`). This file holds only what is specific to this repo. Keep it under one page.

## Commands
- Build: `make build` (healthy output: <what success looks like>)
- Test: `make test` (unit, state/view-model and networking tests)
- Lint: `make lint` (zero warnings)
- Screens: `make screens` (UI screenshots → artifacts/screens/; remove if no UI)
- All: `make verify` — run before reporting any task complete and paste the tail.

## Architecture
- <dir>/  <one line>
- <dir>/  <one line>

## Conventions specific to this repo
- <e.g. feature flags live in …; all network calls go through …>

## Things Claude gets wrong
<!-- When Claude makes the same mistake twice here, add a line. If it shows up in two repos,
     promote it into a plugin skill instead (docs/GOVERNANCE.md). -->
