#!/bin/bash
# Unit tests for the sdlc gates, with default and custom .claude/sdlc.json. Runs in CI.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
S="$ROOT/plugins/sdlc/scripts"
export CLAUDE_PROJECT_DIR
CLAUDE_PROJECT_DIR=$(mktemp -d)
cd "$CLAUDE_PROJECT_DIR" || exit 1
git init -q -b main && git config user.email t@t && git config user.name t
git commit -q --allow-empty -m init
fail=0; n=0
expect() { # expect <exit> <script> <json> <label>
  n=$((n+1))
  echo "$3" | "$S/$2" >/dev/null 2>&1; local got=$?
  if [ "$got" = "$1" ]; then echo "ok   $4"; else echo "FAIL $4 (want $1 got $got)"; fail=1; fi
}
edit() { printf '{"tool_input":{"file_path":"%s"}}' "$1"; }
run()  { printf '{"tool_input":{"command":"%s"}}' "$1"; }
cfg()  { mkdir -p .claude && echo "$1" > .claude/sdlc.json; }
nocfg(){ rm -f .claude/sdlc.json; }

echo "== protect-paths"
expect 2 protect-paths.sh "$(edit /r/.env.production)"                "block .env.*"
expect 2 protect-paths.sh "$(edit /r/ios/secrets/key.p8)"             "block .p8"
expect 2 protect-paths.sh "$(edit /r/android/app/release.jks)"        "block keystore"
expect 2 protect-paths.sh "$(edit /r/src/gen/api.ts)"                 "block generated"
expect 0 protect-paths.sh "$(edit /r/src/app/page.tsx)"               "allow source"
cfg '{"protectedPaths":["*/vault/*"]}'
expect 2 protect-paths.sh "$(edit /r/vault/x.txt)"                    "custom protectedPaths blocks"
expect 0 protect-paths.sh "$(edit /r/.env)"                           "custom protectedPaths replaces defaults"
nocfg

echo "== protect-tests"
expect 0 protect-tests.sh "$(edit /r/src/app.test.ts)"                "tests editable outside fix mode"
mkdir -p .claude/state && touch .claude/state/fix-mode
expect 2 protect-tests.sh "$(edit /r/ios/Tests/ChatTests.swift)"      "locked: Swift test"
expect 2 protect-tests.sh "$(edit /r/android/app/src/test/VmTest.kt)" "locked: Kotlin test"
expect 2 protect-tests.sh "$(edit /r/web/src/app.test.ts)"            "locked: JS test"
expect 2 protect-tests.sh "$(edit /r/api/tests/test_search.py)"       "locked: Python test"
expect 0 protect-tests.sh "$(edit /r/api/search.py)"                  "code editable in fix mode"
rm .claude/state/fix-mode

echo "== release-gate"
expect 2 release-gate.sh "$(run 'fastlane ios release')"              "block App Store"
expect 2 release-gate.sh "$(run 'fastlane android supply track:production')" "block Play production"
expect 2 release-gate.sh "$(run './deploy.sh --env production')"      "block prod deploy"
expect 2 release-gate.sh "$(run 'terraform apply -auto-approve')"     "block terraform apply"
expect 2 release-gate.sh "$(run 'git push origin main')"              "block push to main"
expect 2 release-gate.sh "$(run 'git push origin HEAD:main')"         "block push HEAD:main"
expect 2 release-gate.sh "$(run 'gh pr merge 12')"                    "block merge"
expect 0 release-gate.sh "$(run 'git push origin feature/PROJ-1-maintenance')" "allow feature push (name contains main)"
expect 0 release-gate.sh "$(run 'make verify')"                       "allow verify"
expect 2 release-gate.sh "$(run 'git push')"                         "block bare push while on main"
expect 2 release-gate.sh "$(run 'git push origin HEAD')"              "block push HEAD while on main"
expect 2 release-gate.sh "$(run 'git push origin +main')"             "block force refspec +main"
expect 2 release-gate.sh "$(run 'git push origin refs/heads/main')"   "block full ref refs/heads/main"
expect 2 release-gate.sh "$(run 'git -C . push origin main')"         "block push with git -C"
expect 0 release-gate.sh "$(run "git commit -m 'wip: push to main later'")" "allow commit message mentioning push"
git switch -q -c feature/PROJ-9-gate
expect 0 release-gate.sh "$(run 'git push')"                         "allow bare push on feature branch"
expect 0 release-gate.sh "$(run 'git push -u origin HEAD')"           "allow push HEAD from feature branch"
git switch -q main
RELEASE_APPROVAL="rm 2026-11-02 v2.3" expect 0 release-gate.sh "$(run 'fastlane ios release')" "allow with approval"
cfg '{"protectedBranches":["trunk"],"productionCommands":["*ship-it*"]}'
expect 2 release-gate.sh "$(run 'git push origin trunk')"             "custom protected branch"
expect 2 release-gate.sh "$(run './ship-it now')"                     "custom production command"
expect 0 release-gate.sh "$(run 'git push origin main')"              "main unprotected when overridden"
nocfg

echo "== require-artifacts (default Jira-style keys)"
git switch -q -c feature/PROJ-123-chat-history
mkdir -p src && echo x > src/a.ts && git add src/a.ts
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "block: no folder"
mkdir -p intent/PROJ-123-chat-history && echo "Status: draft" > intent/PROJ-123-chat-history/intent.md
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "block: intent not accepted"
echo "Status: accepted" > intent/PROJ-123-chat-history/intent.md
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "block: no plan"
touch intent/PROJ-123-chat-history/plan.web.md
expect 0 require-artifacts.sh "$(run 'git commit -m feat')"           "allow: accepted intent + plan"
git reset -q; git add intent
expect 0 require-artifacts.sh "$(run 'git commit -m intent')"         "allow: artifact-only commit"
git reset -q; echo "# doc" > README.md; git add README.md
expect 0 require-artifacts.sh "$(run 'git commit -m docs')"           "allow: non-code file"
git reset -q
git switch -q -c task/PROJ-123-web-jk-store
git add src/a.ts
expect 0 require-artifacts.sh "$(run 'git commit -m feat')"           "allow: task branch inherits ticket"
git reset -q; git switch -q -c chore/readme; git add src/a.ts
expect 0 require-artifacts.sh "$(run 'git commit -m chore')"          "allow: chore branch"
git reset -q

echo "== require-artifacts (custom config)"
cfg '{"ticketPattern":"GH-[0-9]+"}'
git switch -q -c feature/GH-77-dark-mode; git add src/a.ts
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "GitHub Issues keys recognized"
git reset -q
cfg '{"ticketPattern":"[0-9]{4}"}'
git switch -q -c feature/0001-local-editor; git add src/a.ts
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "solo 4-digit keys recognized"
mkdir -p intent/0001-local-editor && printf 'Status: accepted\n' > intent/0001-local-editor/intent.md && touch intent/0001-local-editor/plan.ios.md
expect 0 require-artifacts.sh "$(run 'git commit -m feat')"           "solo: allow with artifacts"
cfg '{"ticketPattern":"[0-9]{4}","requireArtifacts":false}'
rm -rf intent/0001-local-editor
expect 0 require-artifacts.sh "$(run 'git commit -m feat')"           "requireArtifacts:false turns gate off"
git reset -q
cfg "$(cat "$ROOT/plugins/sdlc/templates/repo/.claude/sdlc.json")"
git switch -q -c task/PROJ-789-web-jk-store; git add src/a.ts
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "init template gates task branches"
git reset -q; nocfg

echo "== require-artifacts (commit -a)"
git switch -q -c feature/PROJ-456-search
git add src/a.ts && git commit -q -m seed && echo more >> src/a.ts
expect 2 require-artifacts.sh "$(run 'git commit -am feat')"          "block: -am includes unstaged code"
expect 2 require-artifacts.sh "$(run 'git commit --all -m feat')"     "block: --all includes unstaged code"
expect 0 require-artifacts.sh "$(run 'git commit -m feat')"           "allow: nothing staged without -a"
expect 0 require-artifacts.sh "$(run 'git commit --amend --no-edit')" "allow: --amend is not --all"
git checkout -q -- src/a.ts

echo "== require-artifacts (shipped templates)"
TPL="$ROOT/plugins/sdlc/templates/artifacts"
git switch -q -c feature/PROJ-321-templates
mkdir -p intent/PROJ-321-templates src && cp "$TPL/intent.md" intent/PROJ-321-templates/intent.md
echo y > src/b.ts && git add src/b.ts
expect 2 require-artifacts.sh "$(run 'git commit -m feat')"           "block: intent template starts as draft"
out=$("$S/session-context.sh" </dev/null); n=$((n+1))
[[ "$out" == *"intent Status: draft"* ]] && echo "ok   session reads the template's draft status" || { echo "FAIL template status: $out"; fail=1; }
sed -i.bak 's/Status: draft/Status: accepted/' intent/PROJ-321-templates/intent.md && rm intent/PROJ-321-templates/intent.md.bak
cp "$TPL/plan.md" intent/PROJ-321-templates/plan.ios.md
expect 0 require-artifacts.sh "$(run 'git commit -m feat')"           "allow: accepted template intent + plan template"
git reset -q; rm -rf intent/PROJ-321-templates src/b.ts

echo "== session-context"
git switch -q feature/PROJ-123-chat-history
out=$("$S/session-context.sh" </dev/null); n=$((n+1))
[[ "$out" == *"PROJ-123"*"plan.web.md"*"accepted"* ]] && echo "ok   names ticket, artifacts, status" || { echo "FAIL context: $out"; fail=1; }
git switch -q main
out=$("$S/session-context.sh" </dev/null); n=$((n+1))
[[ "$out" == *"isn't a work branch"* ]] && echo "ok   explains non-work branch" || { echo "FAIL context main: $out"; fail=1; }

echo "== mobile pack format hook"
n=$((n+1))
edit /r/x.swift | "$ROOT/plugins/sdlc-mobile/scripts/format.sh" && echo "ok   format hook exits 0 without formatters" || { echo "FAIL format"; fail=1; }

echo "== gates without jq fail closed"
nojq="$CLAUDE_PROJECT_DIR/.nojq"; mkdir -p "$nojq"
for tool in bash git sed grep cat dirname paste ls mkdir date head tr; do ln -sf "$(command -v "$tool")" "$nojq/$tool"; done
PATH="$nojq" expect 2 release-gate.sh      "$(run 'git push origin main')" "release-gate blocks without jq"
PATH="$nojq" expect 2 protect-paths.sh     "$(edit /r/.env)"               "protect-paths blocks without jq"
PATH="$nojq" expect 2 require-artifacts.sh "$(run 'git commit -m x')"      "require-artifacts blocks without jq"
n=$((n+1))
msg=$(run 'ls' | PATH="$nojq" "$S/release-gate.sh" 2>&1 >/dev/null)
[[ "$msg" == *"need jq"* ]] && echo "ok   explains that jq is missing" || { echo "FAIL jq message: $msg"; fail=1; }

rm -rf "$CLAUDE_PROJECT_DIR"
[ $fail = 0 ] && echo "all $n hook tests passed"
exit $fail
