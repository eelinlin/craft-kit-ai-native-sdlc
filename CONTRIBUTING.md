# Contributing

Thanks for helping improve the starter. The most useful contributions:
- **Stack packs** (`plugins/sdlc-<stack>/`): web, backend, data, infra. See docs/CUSTOMIZING.md.
- **Gate fixes**: false positives/negatives in hooks, with a test case.
- **Docs**: clearer setup, real-world examples in `examples/`.

## Ground rules
- Keep the core (`plugins/sdlc`) stack-neutral. Stack-specific rules go in a pack.
- Every hook change needs a case in `tests/test-hooks.sh`; hooks must be fast and single-file.
- Bump versions in `plugin.json` and `.claude-plugin/marketplace.json` together; add a CHANGELOG line.
- Skills: short, numbered rules; a `description` that names when the skill applies.

## Before opening a PR
```bash
tests/test-hooks.sh
tests/test-bands.sh
tests/test-customize.sh
tests/test-repository-contracts.sh
claude plugin validate ./plugins/sdlc
claude plugin validate ./plugins/sdlc-mobile
claude plugin validate .
```
Then try your change in a real repo with `claude --plugin-dir ./plugins/sdlc`.

By contributing you agree your work is released under the MIT License and that you follow the
[Code of Conduct](CODE_OF_CONDUCT.md).
