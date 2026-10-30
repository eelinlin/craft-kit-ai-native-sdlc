#!/bin/bash
# Production releases, pushes to protected branches and merges need a named human approval.
# Approver starts Claude with: RELEASE_APPROVAL="<name> <date> <version>" claude
# Configure with .claude/sdlc.json → "protectedBranches" and "productionCommands" (bash globs).
source "$(dirname "$0")/lib.sh"
cmd=$(jq -r '.tool_input.command // empty' < /dev/stdin)
[ -z "$cmd" ] && exit 0

PROD=$(cfg_list '.productionCommands' '*deploy*prod*\n*--env production*\n*--env=production*\n*terraform apply*\n*kubectl*prod*\n*fastlane*release*\n*deliver*\n*submit_for_review*\n*altool --upload*\n*supply*production*\n*track:production*\n*--track production*\n*npm publish*')
BRANCHES=$(cfg_list '.protectedBranches' 'main\nmaster')

# git, any global options (-C dir, -c k=v, --no-pager), then push
push_re='(^|[[:space:];&|(])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+push([[:space:]]|$)'

gate=""
if matches_any "$cmd" "$PROD"; then
  gate="production release"
elif [[ "$cmd" == *"gh pr merge"* ]]; then
  gate="merge"
elif [[ "$cmd" =~ $push_re ]]; then
  # Refspecs after the remote, up to the next ; & or |. HEAD means the current branch, and a push
  # without refspecs goes to the current branch's upstream.
  current=$(git -C "$PROJECT" rev-parse --abbrev-ref HEAD 2>/dev/null)
  args=${cmd#*"${BASH_REMATCH[0]}"}; args=${args%%[;&|]*}
  refs="" words=0
  set -f
  for w in $args; do
    [[ "$w" == -* ]] && continue
    words=$((words+1)); [ "$words" = 1 ] && continue
    refs+=" ${w//HEAD/$current}"
  done
  set +f
  if [ "$words" -le 1 ]; then
    upstream=$(git -C "$PROJECT" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
    refs=" ${upstream#*/} $current"
  fi
  while IFS= read -r b; do
    [[ "$refs" =~ [[:space:]:+](refs/heads/)?$b([[:space:]]|$) ]] && gate="push to $b"
  done <<< "$BRANCHES"
fi
[ -z "$gate" ] && exit 0

if [ -z "$RELEASE_APPROVAL" ]; then
  echo "Blocked: $gate needs a named human approval. Prepare the checklist and notes (/craft:ship) and hand off to the release approver, who runs it with RELEASE_APPROVAL set." >&2
  log_gate "release-gate block '$gate'"; exit 2
fi
log_gate "release-gate allow '$gate' by '$RELEASE_APPROVAL'"
exit 0
