# CRAFT Kit: AI-native SDLC toolkit for Claude Code

**Fork it. Bend it. Ship it.**

CRAFT Kit is an open-source AI-native SDLC toolkit that turns Claude Code into a full software
lifecycle: plugins for planning, specs, plan-mode builds, fresh-context review and gated releases,
all under one `/craft:` command namespace. Built to be forked and customized by solo developers,
teams, or any stack: **intent → spec → plan → build → verify → review → ship → maintain**.

It implements the practices in Anthropic's
[*AI-native SDLC playbook*](https://academy.claude.com/courses/ai-native-sdlc-playbook)
(see [docs/PLAYBOOK-MAPPING.md](docs/PLAYBOOK-MAPPING.md)).

> Community project. Not affiliated with or endorsed by Anthropic.

## Quick start
Three steps: install once per machine, set up each app repo once, then ship changes.

### 1. Install (once per machine)
In Claude Code:
```
/plugin marketplace add eelinlin/craft-kit-ai-native-sdlc
/plugin install craft@craft-kit
/plugin install craft-mobile@craft-kit      # optional: iOS + Android pack (installs craft too)
```
This installs for your user account, so CRAFT is active in every project you open in Claude Code:
the `craft:` agents (verifier, reviewer, researcher, simplifier), the standards skills, the CRAFT
output style and the gate hooks. Nothing is added to your repos yet.

> The gates apply everywhere from this point. For example, `git push origin main` is blocked in any
> repo unless `RELEASE_APPROVAL` is set. The plan-before-code gate only applies on `feature/`, `fix/`
> and `task/` branches whose name carries a ticket key.

### 2. Set up an app repo (once per project)
1. Commit or stash your work first, so the setup lands as its own reviewable diff.
2. Open the repo in Claude Code and run `/craft:init`. It asks three questions:
   - **Solo or team?**
   - **Which tracker?** Jira, Linear, GitHub Issues, or none. With none, ticket keys are `0001`, `0002`, …
   - **Which stack pack?** For example `craft-mobile`, or none.
3. It adds these files. Where a file already exists, such as your own `CLAUDE.md`, it shows what it
   would add and asks first.

   | File | What it's for |
   |---|---|
   | `.claude/settings.json` | Installs the plugins automatically for anyone who opens the repo |
   | `.claude/sdlc.json` | Gate settings: ticket pattern, work branches, protected branches |
   | `CLAUDE.md`, `REVIEW.md` | Your build commands and architecture; what reviewers check |
   | `Makefile` | `make build`, `test`, `lint`, `screens` and `verify` |
   | `.github/` | PR template, CI review, agent evals |
   | `evals/`, `ops/bands.yaml`, `intent/` | Eval cases, metric control bands, the artifact folders |

4. It wires `make verify` to your real build, lint and test commands and runs it once. Check the
   result: every Claude session uses `make verify` to check its own work. The mobile pack's Makefile
   builds both iOS and Android, so remove the half your app doesn't have.

### 3. Ship your first change
Using a solo key; with a tracker, use its keys instead (e.g. `PROJ-123`).

| Step | Command | What you get |
|---|---|---|
| Start | `/craft:kickoff 0001` | Branch `feature/0001-<slug>` and a draft `intent/0001-<slug>/intent.md` |
| Intent | `/craft:intent 0001` | A brainstorm until intent.md is `Status: accepted` |
| Spec | `/craft:spec 0001` | spec.md, with concerns flagged for you to resolve |
| Plan | Plan mode (Shift+Tab), then `/craft:plan 0001 ios` | plan.ios.md; tasks marked `[P]` can run in parallel |
| Build | Ask Claude to implement the plan | Code commits pass the gate, because an accepted intent and a plan exist |
| Parallel | `claude --worktree task-0001-ios-store` | One session per `[P]` task, each in its own worktree |
| Review | `/craft:review` | Verifier and reviewer agents check it with fresh context; you pick which findings to fix, then it opens a PR |
| Ship | `/craft:ship beta` or `/craft:ship release` | The release checklist; production needs a human with `RELEASE_APPROVAL` |
| Weekly | `/craft:retro` | Metric bands, repeated mistakes, and new intents from both |

See [examples/intent/demo-hello-world](examples/intent/demo-hello-world) for a small, generic end-to-end example.

### Make it your own (optional)
To change the rules for your team, fork it: click **Use this template** on GitHub, clone your
copy, then:
```bash
./scripts/customize.sh --repo <you>/<your-craft-repo> --owner "<Your name or team>"
git commit -am "chore: customize starter" && git push
git branch stable && git push origin stable      # the branch your projects install from
```
Then install from your copy: `/plugin marketplace add <you>/<your-craft-repo>` and
`/plugin install craft@<your-craft-repo>`. See [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md).

## Uninstall
Nothing is permanent. In a repo, run `/craft:uninstall` first to remove the scaffolding (it keeps your
`intent/` history), then remove the plugins from your machine:
```
/plugin uninstall craft-mobile@craft-kit     # if installed
/plugin uninstall craft@craft-kit
/plugin marketplace remove craft-kit
```
Opting out of one repo just for yourself, removing it for a whole team, or undoing an org-wide
rollout: see [docs/UNINSTALL.md](docs/UNINSTALL.md).

## Why CRAFT
Agents write code fast; planning, review, testing and release still run at human speed. This
starter moves those stages into version-controlled artifacts, fresh-context review agents, and
hooks that enforce the gates, so humans spend their attention on intent and risk.

## What you get

| Layer | What it standardizes | Enforced by |
|---|---|---|
| **Workflow** | `/craft:kickoff`, `intent`, `spec`, `plan`, `fix`, `review`, `ship`, `retro`, `init`, `uninstall` | Skills |
| **Artifacts** | `intent/<KEY>-slug/` with intent.md, spec.md, plan.\\<track\\>.md, mocks/; PR format | Templates + commit hook |
| **Output style** | Result first; every task ends with Changed / Evidence / Open | Forced output style |
| **Review** | Verifier and adversarial reviewer agents with fresh context; REVIEW.md passes | Agents + optional CI review |
| **Gates** | No secrets edits; tests locked during fixes; no code before an accepted intent + plan; no production, protected-branch push or merge without a named approval | **Hooks** |
| **Maintain** | Control bands on your metrics → new intents; agent evals on config changes | Scripts + CI |

Two plugins ship in this marketplace:
- **`craft`** — the stack-neutral core of CRAFT Kit.
- **`craft-mobile`** — optional iOS + Android pack (mobile and store-release standards, Swift/Kotlin
  formatting, Xcode + Gradle Makefile). Use it as the model for your own stack pack.

## Guides
- [docs/SOLO.md](docs/SOLO.md) — one developer, no tracker, separating "author" from "approver"
- [docs/TEAM-ROLLOUT.md](docs/TEAM-ROLLOUT.md) — roles, branch model, cadence, org-wide lock-in
- [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md) — `sdlc.json` reference, output style, writing standards skills, building a stack pack
- [docs/GOVERNANCE.md](docs/GOVERNANCE.md) — template for how your standards change
- [docs/PLAYBOOK-MAPPING.md](docs/PLAYBOOK-MAPPING.md) — each playbook lesson → the file that implements it
- [docs/UNINSTALL.md](docs/UNINSTALL.md) — remove it from your machine, one repo, a team, or an org

## Repository layout
```
.claude-plugin/marketplace.json      marketplace: craft, craft-mobile
plugins/sdlc/                        core plugin
  output-styles/  skills/  agents/  hooks/  scripts/
  templates/artifacts/               intent, spec, plan, PR
  templates/repo/                    what /craft:init adds to a repo
plugins/sdlc-mobile/                 CRAFT mobile stack pack
admin/managed-settings.json          optional org-wide lock-in
examples/                            worked artifacts
scripts/customize.sh                 rename placeholders after templating
tests/                               gate, band, customize and repository contract tests (CI)
```

## Requirements
Claude Code (recent version with plugins and output styles), `git`, `jq`, `bash`. `gh` for PRs.
The gates need `jq`: without it they refuse the actions they check rather than let them through.

## Contributing
Issues and PRs welcome, especially new stack packs (web, backend, data). See
[CONTRIBUTING.md](CONTRIBUTING.md). Licensed under [MIT](LICENSE).
