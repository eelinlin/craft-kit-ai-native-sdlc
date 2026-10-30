#!/bin/bash
# Run each eval case headless in an isolated worktree; report pass rate.
set -uo pipefail
root=$(git rev-parse --show-toplevel)
pass=0; total=0
mkdir -p "$root/artifacts/evals"
for case in "$root"/evals/cases/*.json; do
  [ -e "$case" ] || { echo "no eval cases yet"; exit 0; }
  id=$(jq -r '.id' "$case"); total=$((total+1))
  wt=$(mktemp -d); git -C "$root" worktree add -q --detach "$wt" HEAD
  ( cd "$wt" && claude -p "$(jq -r '.prompt' "$case")" \
      --allowedTools "Read,Edit,Write,Bash(make build),Bash(make test),Bash(make lint)" \
      --output-format json > "$root/artifacts/evals/$id.json" 2>&1 )
  ok=1
  while IFS= read -r chk; do
    ( cd "$wt" && bash -c "$chk" >/dev/null 2>&1 ) || ok=0
  done < <(jq -r '.checks[]' "$case")
  while IFS= read -r p; do
    [ -n "$p" ] && [ -n "$(git -C "$wt" status --porcelain -- "$p")" ] && ok=0
  done < <(jq -r '.must_not_touch[]?' "$case")
  [ $ok = 1 ] && { pass=$((pass+1)); echo "PASS $id"; } || echo "FAIL $id"
  git -C "$root" worktree remove --force "$wt"
done
echo "evals: $pass/$total passed"
echo "$(date -u +%F) $pass/$total" >> "$root/evals/history.log"
[ "$pass" = "$total" ]
