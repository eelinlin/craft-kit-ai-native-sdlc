#!/bin/bash
# SessionStart: tell Claude which ticket and artifacts this session belongs to (stdout becomes context).
source "$(dirname "$0")/lib.sh"
branch=$(git -C "$PROJECT" rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
key=$(ticket_key)
prefixes=$(echo "$BRANCH_PREFIXES" | paste -sd'/' -)
if [ -z "$key" ]; then
  echo "SDLC: branch '$branch' isn't a work branch ($prefixes/<KEY>-slug). Feature and fix work starts with /craft:kickoff <KEY>; chores and docs may proceed."
  exit 0
fi
dir=$(artifact_dir "$key")
if [ -z "$dir" ]; then
  echo "SDLC: ticket $key on '$branch' has no $ARTIFACT_DIR/$key-*/ folder yet. Run /craft:kickoff $key."
  exit 0
fi
rel=${dir#"$PROJECT"/}
have=$(cd "$dir" && ls ./*.md 2>/dev/null | sed 's#^\./##' | tr '\n' ' ')
status=$(grep -m1 -oE 'Status: [a-z]+' "$dir/intent.md" 2>/dev/null)
echo "SDLC: ticket $key · artifacts in $rel ($have) · intent $status. Read the plan for your track before changing code."
exit 0
