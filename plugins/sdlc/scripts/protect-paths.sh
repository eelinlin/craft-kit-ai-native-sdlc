#!/bin/bash
# Block edits to secrets, signing material and generated code. Configure with
# .claude/sdlc.json → "protectedPaths" and "generatedPaths" (bash glob patterns).
source "$(dirname "$0")/lib.sh"
file=$(jq -r '.tool_input.file_path // empty' < /dev/stdin)
[ -z "$file" ] && exit 0

SECRETS=$(cfg_list '.protectedPaths' '*.env\n*.env.*\n*/secrets/*\n*.pem\n*.key\n*.p8\n*.p12\n*.mobileprovision\n*.jks\n*.keystore\n*/google-services.json\n*/GoogleService-Info.plist\n*/local.properties')
GENERATED=$(cfg_list '.generatedPaths' '*/Generated/*\n*.generated.*\n*/build/generated/*\n*/gen/*')

if matches_any "$file" "$SECRETS"; then
  echo "Blocked: $file holds secrets or signing material. A human edits it outside Claude." >&2
  log_gate "protect-paths block $file"; exit 2
fi
if matches_any "$file" "$GENERATED"; then
  echo "Blocked: $file is generated. Change the generator input instead." >&2
  exit 2
fi
exit 0
