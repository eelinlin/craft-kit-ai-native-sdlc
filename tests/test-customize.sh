#!/usr/bin/env bash
# customize.sh tests: rename a copy of this repo, then check nothing still points at the old names
# and the renamed copy still passes the repository contract tests. Runs in CI.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0; n=0
check() { # check <label> <command...>
  n=$((n+1))
  if "${@:2}" >/dev/null 2>&1; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi
}
copy_repo() { # tracked files, including uncommitted edits, into a fresh git repo
  local dir; dir=$(mktemp -d)
  (cd "$ROOT" && git ls-files -z | tar --null -T - -cf -) | tar -xf - -C "$dir"
  git -C "$dir" init -q -b main && git -C "$dir" add -A
  echo "$dir"
}
leftovers() { # leftovers <dir> <string>: tracked files that still contain <string>
  git -C "$1" ls-files -z -- . ':!CHANGELOG.md' ':!scripts/customize.sh' | (cd "$1" && xargs -0 grep -lF -- "$2")
}

from_repo=$(jq -r '.repository' "$ROOT/plugins/sdlc/.claude-plugin/plugin.json" | sed -E 's#^https://github.com/##')
from_owner=$(jq -r '.author.name' "$ROOT/plugins/sdlc/.claude-plugin/plugin.json")
from_market=$(jq -r '.name' "$ROOT/.claude-plugin/marketplace.json")

echo "== rename everything"
T=$(copy_repo)
(cd "$T" && ./scripts/customize.sh --repo widgetco/widget-craft --owner "Widget Co" --marketplace widget-craft) >/dev/null
check "marketplace renamed"           test "$(jq -r .name "$T/.claude-plugin/marketplace.json")" = widget-craft
check "core repository renamed"       test "$(jq -r .repository "$T/plugins/sdlc/.claude-plugin/plugin.json")" = https://github.com/widgetco/widget-craft
check "mobile repository renamed"     test "$(jq -r .repository "$T/plugins/sdlc-mobile/.claude-plugin/plugin.json")" = https://github.com/widgetco/widget-craft
check "author renamed"                test "$(jq -r .author.name "$T/plugins/sdlc/.claude-plugin/plugin.json")" = "Widget Co"
check "LICENSE holder renamed"        grep -q "^Copyright (c) [0-9]* Widget Co$" "$T/LICENSE"
check "CODEOWNERS renamed"            grep -q "@widgetco$" "$T/CODEOWNERS"
check "install command renamed"       grep -qF "craft@widget-craft" "$T/README.md"
check "no '$from_repo' left"          test -z "$(leftovers "$T" "$from_repo")"
check "no '$from_market' left"        test -z "$(leftovers "$T" "$from_market")"
check "no '\"$from_owner\"' left"     test -z "$(leftovers "$T" "\"$from_owner\"")"
check "no '@${from_repo%%/*}' left"   test -z "$(leftovers "$T" "@${from_repo%%/*}")"
check "CHANGELOG left alone"          cmp -s "$ROOT/CHANGELOG.md" "$T/CHANGELOG.md"
check "all JSON still valid"          bash -c "cd '$T' && git ls-files '*.json' | xargs -n1 jq empty"
git -C "$T" add -A
check "renamed copy passes contracts" bash "$T/tests/test-repository-contracts.sh"
rm -rf "$T"

echo "== marketplace defaults to the repo name"
T=$(copy_repo)
(cd "$T" && ./scripts/customize.sh --repo acme/widgets --owner "Acme") >/dev/null
check "marketplace is widgets"        test "$(jq -r .name "$T/.claude-plugin/marketplace.json")" = widgets
check "install command uses widgets"  grep -qF "craft@widgets" "$T/README.md"
rm -rf "$T"

echo "== bad arguments"
check "rejects missing --owner"       bash -c "! '$ROOT/scripts/customize.sh' --repo acme/x"
check "rejects repo without owner"    bash -c "! '$ROOT/scripts/customize.sh' --repo x --owner y"
check "rejects uppercase marketplace" bash -c "! '$ROOT/scripts/customize.sh' --repo acme/x --owner y --marketplace Bad"

[ $fail = 0 ] && echo "all $n customize tests passed"
exit $fail
