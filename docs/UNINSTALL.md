# Uninstalling cleanly

Pick the level you want to undo. Each level is independent; nothing here touches your code,
your Git history, or your `intent/` artifacts unless you choose to remove them.

| I want to… | Go to |
|---|---|
| Stop using it myself, everywhere | [1. Remove from your machine](#1-remove-from-your-machine) |
| Turn it off for me in one repo, without changing it for teammates | [2. Opt out in one repo, just for you](#2-opt-out-in-one-repo-just-for-you) |
| Remove it from a repo for everyone | [3. Remove from a repo](#3-remove-from-a-repo) |
| Remove it from every machine in an organization | [4. Remove an org-wide rollout](#4-remove-an-org-wide-rollout) |

> **Order matters:** if you want the scaffolding cleaned up too, run `/craft:uninstall` in the repo
> (step 3) *before* uninstalling the plugin, because the command ships with the plugin.

## 1. Remove from your machine
In a terminal (or the same commands with `/plugin …` inside Claude Code):
```bash
claude plugin uninstall craft-mobile@craft-kit    # only if you installed it; remove it first
claude plugin uninstall craft@craft-kit
claude plugin marketplace remove craft-kit
```
Optional: delete the download cache, which uninstall leaves behind:
```bash
rm -rf ~/.claude/plugins/cache/craft-kit
```
Check: `claude plugin list` no longer shows `craft`, and `/output-style` no longer shows
**CRAFT Standard** (the forced style goes away with the plugin).

If you installed with `--scope project` or `--scope local`, pass the same `--scope` to `uninstall`.
If a repo you open still lists the plugin in its `.claude/settings.json`, Claude Code will offer to
install it again there; use step 2 or 3 for that repo.

## 2. Opt out in one repo, just for you
The repo's `.claude/settings.json` turns the plugin on for everyone. To turn it off only for
yourself, from inside that repo:
```bash
claude plugin disable craft@craft-kit --scope local
```
This writes `"enabledPlugins": { "craft@craft-kit": false }` to
`.claude/settings.local.json`, which is personal and not committed. Undo with
`claude plugin enable craft@craft-kit --scope local`.

Note: if your organization requires the plugin through managed settings, you can't opt out
locally; ask your admin (step 4).

## 3. Remove from a repo
**Easiest:** in the repo, start Claude Code and run `/craft:uninstall`. It lists every file
`/craft:init` added, shows which ones you've edited, asks what to keep, and removes the rest on a
`chore/remove-craft` branch for review. It keeps `intent/` by default.

**By hand:**
1. Remove the plugin from the repo's settings (this edits `.claude/settings.json`):
   ```bash
   claude plugin uninstall craft-mobile@craft-kit --scope project   # if enabled
   claude plugin uninstall craft@craft-kit --scope project
   claude plugin marketplace remove craft-kit --scope project
   ```
   Then remove the `permissions` block from `.claude/settings.json` if you don't want it, or
   delete the file if nothing else is in it.
2. Delete the scaffolding you no longer want:

   | Added by `/craft:init` | Safe to delete? |
   |---|---|
   | `.claude/sdlc.json` | Yes: only the hooks read it |
   | `.claude/state/` | Yes: local gate logs and fix-mode flag |
   | `REVIEW.md` | Yes, unless your own review tooling uses it |
   | `Makefile` | Check first: you may have wired real targets you still want |
   | `CLAUDE.md` | Usually keep: it's useful to Claude without the plugin |
   | `.github/pull_request_template.md` | Optional |
   | `.github/workflows/claude-review.yml`, `agent-evals.yml` | Yes |
   | `evals/`, `ops/` | Yes, unless you still run them |
   | `intent/` | **Keep** unless you're sure: it's the record of why changes were made |

3. Commit on a branch and open a PR so teammates see the change:
   `git switch -c chore/remove-craft && git commit -am "chore: remove CRAFT plugin"`.
4. Optional, on GitHub: delete the `ANTHROPIC_API_KEY` and `PLUGIN_READ_TOKEN` repository secrets
   if nothing else uses them, and remove the repo from the Claude GitHub App if you installed it
   only for this.

After the PR merges, teammates can run step 1 to clear their own machines.

## 4. Remove an org-wide rollout
If an admin applied `admin/managed-settings.json` (claude.ai **Organization settings → Claude
Code → Managed settings**, MDM, or a `managed-settings.json` file):
1. Remove `"craft@craft-kit"` (and `craft-mobile`) from `enabledPlugins`, and the
   `craft-kit` entry from `extraKnownMarketplaces`.
2. Remove the two `craft-kit` entries from `strictKnownMarketplaces`. If that leaves
   the list holding only entries you no longer need, delete the key entirely; an empty list `[]`
   blocks **every** marketplace, including the official one.
3. Keep or remove the `permissions` block as your security policy requires; it's independent of
   the plugin.
4. Machines pick up the change at their next Claude Code session. Then each repo follows step 3,
   and each person can follow step 1.

## Leaving no trace — checklist
- [ ] `claude plugin list` shows no `craft` / `craft-mobile`
- [ ] `claude plugin marketplace list` shows no `craft-kit`
- [ ] `~/.claude/plugins/cache/craft-kit` deleted
- [ ] No `craft@craft-kit` in `~/.claude/settings.json`, any repo's
      `.claude/settings.json` / `.claude/settings.local.json`, or managed settings
- [ ] `outputStyle` in your settings isn't set to `CRAFT Standard`
- [ ] Repo scaffolding removed or intentionally kept (step 3)
