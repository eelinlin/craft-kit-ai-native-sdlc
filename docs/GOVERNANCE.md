# Governance (template — edit for your team)

Your fork of this repo is the single source of truth for workflow, artifacts, output style and
gates. Nobody edits a local copy; changes go through this repo like code.

## Approvals (enforce with CODEOWNERS + branch protection)
| Path | Needs |
|---|---|
| `plugins/*/output-styles/`, `plugins/*/templates/` | Standards owner + 1 engineer |
| `plugins/*/skills/` (standards) | Standards owner + 1 engineer per affected track |
| `plugins/*/hooks/`, `plugins/*/scripts/` | Standards owner + tech lead; `tests/` must pass |
| `admin/managed-settings.json` | Tech lead + IT/platform |
| `docs/` | Team agreement at the monthly tune |

## Proposing a change
1. PR with the change and a one-paragraph "why" (a review finding, an incident, a repeated mistake).
2. Bump `version` in the plugin's `plugin.json` and in `.claude-plugin/marketplace.json`
   (patch = wording, minor = new skill or rule, major = workflow or gate change). Add a CHANGELOG entry.
3. CI validates JSON, versions, hooks and plugin manifests.
4. Try it locally: `claude --plugin-dir ./plugins/sdlc` inside a real repo.
5. Merge to `main` (early access). After a week with no regressions and evals at or above baseline,
   fast-forward `stable`, which every repo installs from.

## What belongs where
Must always hold → hook. Should usually hold → skill or output style. One repo only → that repo's
CLAUDE.md. When the same CLAUDE.md line appears in two repos, promote it into a plugin.

## Monthly tune
- Rate a sample of reviewer findings (useful / noise); adjust REVIEW.md passes and nit caps.
- Read `.claude/state/gates.log` and CI logs for gates that are noisy or routinely approved.
- Promote repeated CLAUDE.md lines into standards skills.
- Compare eval pass rates across plugin versions; retire cases every model now passes.
