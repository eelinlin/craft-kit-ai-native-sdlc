#!/bin/bash
# Make this starter yours after "Use this template": replaces the current repo, owner name and
# marketplace name everywhere. It reads the current values from the plugin manifests, so it works
# on the upstream repo or on any fork.
#
#   ./scripts/customize.sh --repo acme/acme-sdlc --owner "Acme Mobile" [--marketplace acme-sdlc]
set -euo pipefail
cd "$(dirname "$0")/.."

repo="" owner="" market=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --marketplace) market="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 1 ;;
  esac
done
[ -n "$repo" ] && [ -n "$owner" ] || { echo "usage: $0 --repo <owner/name> --owner \"<name>\" [--marketplace <name>]" >&2; exit 1; }
[[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "--repo must look like owner/name" >&2; exit 1; }
market="${market:-${repo#*/}}"
[[ "$market" =~ ^[a-z0-9-]+$ ]] || { echo "--marketplace must be lowercase letters, digits, dashes" >&2; exit 1; }
gh_owner="${repo%%/*}"

# Current values, read from the manifests.
from_repo=$(jq -r '.repository' plugins/sdlc/.claude-plugin/plugin.json | sed -E 's#^https://github.com/##; s#\.git$##')
from_owner=$(jq -r '.author.name' plugins/sdlc/.claude-plugin/plugin.json)
from_market=$(jq -r '.name' .claude-plugin/marketplace.json)
from_gh="${from_repo%%/*}"
echo "renaming  $from_repo → $repo  |  \"$from_owner\" → \"$owner\"  |  marketplace $from_market → $market"

files=$(grep -rlF -e "$from_repo" -e "$from_owner" -e "$from_market" -e "@$from_gh" \
  --exclude-dir=.git --exclude=customize.sh --exclude=CHANGELOG.md . || true)
# perl, not sed: macOS sed has no \b, so the word-boundary renames would silently do nothing there.
# \Q...\E matches the old values literally; the new values come in through the environment.
export FROM_REPO="$from_repo" FROM_OWNER="$from_owner" FROM_MARKET="$from_market" FROM_GH="$from_gh"
export TO_REPO="$repo" TO_OWNER="$owner" TO_MARKET="$market" TO_GH="$gh_owner"
for f in $files; do
  perl -pi -e '
    s#\Q$ENV{FROM_REPO}\E#$ENV{TO_REPO}#g;
    s#\@\Q$ENV{FROM_GH}\E\b#\@$ENV{TO_GH}#g;
    s#"\Q$ENV{FROM_OWNER}\E"#"$ENV{TO_OWNER}"#g;
    s#^(Copyright \(c\) [0-9]*) \Q$ENV{FROM_OWNER}\E$#$1 $ENV{TO_OWNER}#;
    s#\b\Q$ENV{FROM_MARKET}\E\b#$ENV{TO_MARKET}#g;
  ' "$f"
  echo "updated $f"
done
echo
echo "Done. Next: review the diff (git diff), set a maintainer contact in SECURITY.md and"
echo "CODE_OF_CONDUCT.md, edit docs/GOVERNANCE.md and CODEOWNERS, then commit, push, and create"
echo "the channel repos install from:  git branch stable && git push origin stable"
