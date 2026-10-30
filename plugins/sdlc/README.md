# CRAFT Kit — core plugin

The core plugin for CRAFT Kit, with the `/craft:` command namespace.
Provides the workflow commands (`/craft:kickoff`,
`intent`, `spec`, `plan`, `fix`, `review`, `ship`, `retro`, `init`, `uninstall`), artifact templates linked to
your ticket tracker, fresh-context verifier and reviewer agents, guardrail hooks configured per repo
in `.claude/sdlc.json`, and the forced "CRAFT Standard" output style.

Add a stack pack (for example `craft-mobile`) for language-specific standards and formatting.
See the repository README and `docs/` for setup and customization.
