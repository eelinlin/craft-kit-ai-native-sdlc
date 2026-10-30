# Customizing

## Where each kind of rule belongs
| Rule | Put it in |
|---|---|
| Must always hold (block or allow an action) | A hook in a plugin; configure via `.claude/sdlc.json` |
| How every response is shaped | `plugins/sdlc/output-styles/sdlc-standard.md` |
| A standard applied while writing specs, plans or code | A skill in a stack pack (or your own pack) |
| Artifact sections and naming | `plugins/sdlc/templates/artifacts/` + `skills/artifact-standards` |
| One repo's commands, architecture, quirks | That repo's `CLAUDE.md` |

## `.claude/sdlc.json` reference (per repo)
All keys optional. A list you set **replaces** that list's defaults.

| Key | Default | Purpose |
|---|---|---|
| `ticketPattern` | `[A-Z][A-Z0-9]+-[0-9]+` | Ticket key regex (Jira/Linear). `GH-[0-9]+` for GitHub Issues, `[0-9]{4}` for solo |
| `workBranchPrefixes` | `feature`, `fix`, `task` | Branches that must carry a ticket key and artifacts |
| `artifactDir` | `intent` | Folder holding `<KEY>-slug/` artifact folders |
| `requireArtifacts` | `true` | Block code commits on work branches without accepted intent + plan |
| `codeExtensions` | common source extensions | Which staged files count as code for that gate |
| `protectedBranches` | `main`, `master` | Pushes need `RELEASE_APPROVAL` |
| `productionCommands` | deploy/terraform/store/npm publish globs | Commands that need `RELEASE_APPROVAL` |
| `protectedPaths` | env, secrets, keys, signing files | Never editable by Claude |
| `generatedPaths` | `*/Generated/*`, `*.generated.*`, `*/gen/*` … | Edit the generator instead |
| `testPaths` | common test globs for Swift, Kotlin, JS/TS, Python, Go | Locked during `/craft:fix` |

Patterns are bash globs matched against the absolute path or full command.
After changing a gate, add a case to `tests/test-hooks.sh`.

## Output style
Edit `sdlc-standard.md`. `force-for-plugin: true` applies it to everyone with the plugin enabled;
remove that line to make it opt-in via `/output-style`.

## Writing a standards skill
A folder with `SKILL.md`. The frontmatter `description` decides when Claude loads it, so name the
triggering tasks ("Use when writing a spec, adding an endpoint, …"). Keep it short and numbered so
reviewers can cite rules ("mobile-standards #11"). Put a version in the heading; `spec.md` records
which versions were applied. If a rule must never be broken, back it with a hook.

## Building a stack pack
Copy `plugins/sdlc-mobile/` to `plugins/sdlc-<stack>/`:
1. Rename in `.claude-plugin/plugin.json`; keep `"dependencies": ["craft"]`.
2. Replace `skills/` with your stack's standards and release items.
3. Point `hooks/hooks.json` at your formatter/linter script (fast, single file).
4. Ship a `templates/Makefile` with real `build/test/lint/screens/verify` targets.
5. Add the plugin to `.claude-plugin/marketplace.json`, then run `claude plugin validate .`.
PRs adding packs (web, backend, data, infra) are welcome upstream.
