# Changelog

## Unreleased

## 2.0.2 — 2026-11-10

craft 2.0.2, craft-mobile 2.0.0. The first public release as **CRAFT Kit**.

### Install
- The repository is `eelinlin/craft-kit-ai-native-sdlc`; the marketplace is named `craft-kit`:
  ```
  /plugin marketplace add eelinlin/craft-kit-ai-native-sdlc
  /plugin install craft@craft-kit
  ```
- Projects set up with `/craft:init` install from the new `stable` branch.
- **Upgrading from an earlier address** (`eelinlin/craft-kit` or `eelinlin/ai-native-sdlc-kit`, which no
  longer resolve): run `/plugin marketplace remove craft-kit`, then the two commands above.

### Workflow
- Ship the artifact templates `templates/artifacts/intent.md`, `spec.md`, `plan.md` and `pr.md`.
  `/craft:kickoff`, `/craft:spec`, `/craft:plan`, `/craft:review` and artifact-standards use them, but
  they were never committed: `.gitignore`'s `artifacts/` rule matched them. It now only ignores the
  root `artifacts/` folder.
- The `/craft:init` settings template enables `craft@craft-kit` (it named a non-existent `sdlc` plugin)
  and gates `task/` branches, matching the documented default.
- `/craft:init` CI workflows (Claude review, agent evals) only run `gh auth setup-git` when
  `PLUGIN_READ_TOKEN` is set, so they work with a public marketplace.
- Hook messages, templates and `/craft:init` name the `craft` plugin and `/craft:` commands
  instead of the old `sdlc` ones.

### Gates
- Release gate: block pushes to a protected branch made with no refspec or `HEAD` while on that
  branch, `+main`, `refs/heads/main`, or `git -C <dir> push`.
- Plan-before-code gate: also check code committed with `git commit -a` / `-am` / `--all`.
- Without `jq`, the gates refuse the actions they check instead of allowing everything.
- Remove the core PostToolUse hook that ran a non-existent `format.sh` after every edit; formatting
  lives in stack packs such as `craft-mobile`.

### Tooling
- `check-bands.sh` skips the CSV header instead of reading it as a 0 data point, which raised false
  3sigma breaches on short histories.
- `customize.sh` works on macOS; its `sed \b` renames silently did nothing there.
- Tests: new `tests/test-bands.sh` and `tests/test-customize.sh`. Contract tests check that hook
  scripts and every file a skill names are committed, that plugin, marketplace and repo names agree
  with each other and with the git remote, and that `/craft:` commands and agents exist.

## 2.0.0 — 2026-10-29

- Establish CRAFT as the workflow identity and `/craft:` command namespace.
- Ship the stack-neutral `craft` plugin and optional `craft-mobile` extension.
- Standardize the lifecycle from intent through planning, implementation, verification, review, release and maintenance.
- Add repository templates, engineering guardrails, review agents, customization tooling and automated validation.
