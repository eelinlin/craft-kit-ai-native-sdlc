---
name: uninstall
description: Remove the SDLC scaffolding from this repo cleanly — plugin settings, sdlc.json, CI workflows, evals, bands — keeping intent/ history by default. Run before uninstalling the plugin.
disable-model-invocation: true
---
Remove the AI-native SDLC from this repo. Change nothing until the engineer confirms.

1. Inventory. For each path below that exists, show whether it still matches the plugin template
   in `${CLAUDE_PLUGIN_ROOT}/templates/repo/` (unchanged) or was edited (changed):
   `.claude/sdlc.json`, `.claude/state/`, `REVIEW.md`, `Makefile`, `CLAUDE.md`,
   `.github/pull_request_template.md`, `.github/workflows/claude-review.yml`,
   `.github/workflows/agent-evals.yml`, `evals/`, `ops/`, `intent/`.
   Also show the plugin-related keys in `.claude/settings.json` (`extraKnownMarketplaces`,
   `enabledPlugins`, `permissions`) and in `.claude/settings.local.json`.
2. Recommend: delete unchanged files; ask about changed ones; **keep `intent/` and `CLAUDE.md`**
   unless the engineer explicitly says to remove them (they're the change history and still useful
   without the plugin); ask whether to keep the `permissions` block.
3. Ask the engineer to confirm the final list.
4. On a new branch `chore/remove-sdlc`:
   - Remove this plugin's entries from `.claude/settings.json`: run
     `claude plugin uninstall craft-mobile@<marketplace> --scope project` (if enabled),
     `claude plugin uninstall craft@<marketplace> --scope project`, and
     `claude plugin marketplace remove <marketplace> --scope project`, where `<marketplace>` is the
     key in `extraKnownMarketplaces`. If the commands aren't available, edit the JSON directly.
     Delete `.claude/settings.json` only if it is left empty.
   - `git rm` the confirmed files; delete `.claude/state/` (untracked).
   - Commit `chore: remove CRAFT plugin` and, for a team repo, open a PR.
5. Tell the engineer what's left to do outside the repo: each person runs
   `claude plugin uninstall craft@<marketplace>` and `claude plugin marketplace remove <marketplace>`
   (see docs/UNINSTALL.md in the kit repo); optionally delete the `ANTHROPIC_API_KEY` and
   `PLUGIN_READ_TOKEN` repo secrets; an org admin removes any managed-settings entries.
