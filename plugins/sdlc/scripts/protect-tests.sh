#!/bin/bash
# During a bug fix the committed failing test is the proof, so the agent may not edit tests.
# On: /craft:fix creates .claude/state/fix-mode   Off: a human deletes it.
# Configure test locations with .claude/sdlc.json → "testPaths".
source "$(dirname "$0")/lib.sh"
[ -f "$PROJECT/.claude/state/fix-mode" ] || exit 0
file=$(jq -r '.tool_input.file_path // empty' < /dev/stdin)
TESTS=$(cfg_list '.testPaths' '*/Tests/*\n*/tests/*\n*/test/*\n*/__tests__/*\n*/src/test/*\n*/src/androidTest/*\n*Tests.swift\n*Test.swift\n*Test.kt\n*Tests.kt\n*.test.*\n*.spec.*\n*_test.*\n*/test_*')
if matches_any "$file" "$TESTS"; then
  echo "Blocked: fix mode is on, so test files are locked. Make the committed failing test pass by changing code. To change the test, a human removes .claude/state/fix-mode." >&2
  log_gate "protect-tests block $file"; exit 2
fi
exit 0
