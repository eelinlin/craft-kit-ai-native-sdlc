#!/bin/bash
# Shared helpers for the sdlc hooks. Every rule is configurable per repo in .claude/sdlc.json;
# anything not set there falls back to the defaults below.

# The gates read the tool call with jq. Without it they can't tell what's being run, so they refuse
# rather than let everything through.
if ! command -v jq >/dev/null 2>&1; then
  echo "Blocked: the CRAFT gates need jq to check this action, and jq isn't installed. Install it (macOS: brew install jq; Debian/Ubuntu: sudo apt-get install jq) and try again." >&2
  exit 2
fi

PROJECT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CONFIG="$PROJECT/.claude/sdlc.json"

# cfg <jq path> <default>  — string value
cfg() {
  local v=""
  [ -f "$CONFIG" ] && v=$(jq -r "($1) | select(. != null)" "$CONFIG" 2>/dev/null)
  echo "${v:-$2}"
}
# cfg_list <jq path> <default newline list>  — one item per line
cfg_list() {
  local v=""
  [ -f "$CONFIG" ] && v=$(jq -r "($1 // empty) | .[]" "$CONFIG" 2>/dev/null)
  if [ -n "$v" ]; then echo "$v"; else printf '%b\n' "$2"; fi
}

TICKET_PATTERN=$(cfg '.ticketPattern' '[A-Z][A-Z0-9]+-[0-9]+')
BRANCH_PREFIXES=$(cfg_list '.workBranchPrefixes' 'feature\nfix\ntask')
ARTIFACT_DIR=$(cfg '.artifactDir' 'intent')
CODE_EXT=$(cfg_list '.codeExtensions' 'swift\nkt\nkts\njava\nm\nmm\nts\ntsx\njs\njsx\npy\ngo\nrb\nrs\ncs')

# Ticket key from the current branch: <prefix>/<KEY>-slug[/task] -> KEY
ticket_key() {  # feature/KEY-slug, fix/KEY-slug, task/KEY-slug-<track>-<who>-<task>
  local branch prefixes
  branch=$(git -C "$PROJECT" rev-parse --abbrev-ref HEAD 2>/dev/null)
  prefixes=$(echo "$BRANCH_PREFIXES" | paste -sd'|' -)
  echo "$branch" | sed -nE "s#^($prefixes)/($TICKET_PATTERN)(-.*)?(/.*)?\$#\\2#p"
}

# Artifact folder for a key: <artifactDir>/<KEY>-*/  (or exactly <KEY>/)
artifact_dir() {
  local key="$1"
  [ -n "$key" ] || return 1
  ls -d "$PROJECT/$ARTIFACT_DIR/$key"-*/ "$PROJECT/$ARTIFACT_DIR/$key"/ 2>/dev/null | head -1
}

# matches_any <string> <newline list of bash glob patterns>
matches_any() {
  local s="$1" p
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    # shellcheck disable=SC2053
    [[ "$s" == $p ]] && return 0
  done <<< "$2"
  return 1
}

log_gate() {
  mkdir -p "$PROJECT/.claude/state"
  echo "$(date -u +%FT%TZ) $*" >> "$PROJECT/.claude/state/gates.log"
}
