#!/bin/bash
# Plan-before-code gate: a commit that stages source code on a work branch (feature/, fix/ by
# default) needs an accepted intent.md and at least one plan*.md for that ticket.
# Other branches and artifact-only commits pass. Turn off with "requireArtifacts": false.
source "$(dirname "$0")/lib.sh"
cmd=$(jq -r '.tool_input.command // empty' < /dev/stdin)
[[ "$cmd" == *"git commit"* ]] || exit 0
[ "$(cfg '.requireArtifacts' 'true')" = "false" ] && exit 0

key=$(ticket_key)
[ -n "$key" ] || exit 0

ext_re=$(echo "$CODE_EXT" | paste -sd'|' -)
files=$(git -C "$PROJECT" diff --cached --name-only 2>/dev/null)
# commit -a / -am / --all also commits tracked files that aren't staged yet
if [[ "$cmd" =~ [[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$) ]]; then
  files+=$'\n'$(git -C "$PROJECT" diff --name-only 2>/dev/null)
fi
code=$(echo "$files" | grep -v "^$ARTIFACT_DIR/" | grep -E "\.($ext_re)\$")
[ -n "$code" ] || exit 0

dir=$(artifact_dir "$key")
if [ -z "$dir" ]; then
  echo "Blocked: code commit for $key, but $ARTIFACT_DIR/$key-*/ doesn't exist. Run /craft:kickoff $key first." >&2
  log_gate "require-artifacts block $key no-folder"; exit 2
fi
rel=${dir#"$PROJECT"/}
if ! grep -q 'Status: accepted' "$dir/intent.md" 2>/dev/null; then
  echo "Blocked: ${rel}intent.md is not accepted. The product owner sets Status: accepted before code is committed." >&2
  log_gate "require-artifacts block $key intent-not-accepted"; exit 2
fi
if ! ls "$dir"/plan*.md >/dev/null 2>&1; then
  echo "Blocked: no plan in $rel. Run /craft:plan $key <track> in plan mode first." >&2
  log_gate "require-artifacts block $key no-plan"; exit 2
fi
exit 0
