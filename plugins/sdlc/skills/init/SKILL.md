---
name: init
description: One-time setup — add the SDLC scaffolding to a repo (settings, sdlc.json, CLAUDE.md, REVIEW.md, PR template, CI, evals, bands).
disable-model-invocation: true
---
Set up this repo for the CRAFT. Don't overwrite existing files; for each one that exists,
show what you'd add and ask.

1. Ask three questions: solo or team? which ticket tracker (Jira, Linear, GitHub Issues, none)?
   which stack pack, if any (e.g. `craft-mobile`)?
2. Copy everything under `${CLAUDE_PLUGIN_ROOT}/templates/repo/` into the repo root, keeping paths
   (`.claude/`, `.github/`, `evals/`, `ops/`, `intent/`).
3. Tune `.claude/sdlc.json`: for GitHub Issues set `"ticketPattern": "GH-[0-9]+"`; for solo with no
   tracker set `"ticketPattern": "[0-9]{4}"`; otherwise keep the Jira-style default. Set
   `protectedBranches` to the real default branch. If a stack pack was chosen, add it to
   `enabledPlugins` in `.claude/settings.json` and merge its Makefile targets.
4. Fill CLAUDE.md from the codebase: the real build/test/lint/screens commands and a few lines of
   architecture. Keep it under one page; shared rules stay in the plugins.
5. Wire `make build`, `make test`, `make lint`, `make screens` (if there's UI) and `make verify` to
   the real commands, each exiting non-zero on failure. Run `make verify` once and paste the result.
6. `chmod +x evals/run.sh`. Solo: delete `.github/workflows/claude-review.yml` if not wanted.
7. Commit on `chore/sdlc-init` and open a PR (team) or commit directly (solo).
