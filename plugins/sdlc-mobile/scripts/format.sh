#!/bin/bash
# Format the one file that just changed, with the team's formatter for its language.
file=$(jq -r '.tool_input.file_path // empty' < /dev/stdin)
case "$file" in
  *.swift)
    if command -v swift-format >/dev/null; then swift-format format --in-place "$file"
    elif command -v swiftformat >/dev/null; then swiftformat "$file" --quiet; fi ;;
  *.kt|*.kts)
    command -v ktlint >/dev/null && ktlint --format "$file" >/dev/null ;;
esac 2>/dev/null
exit 0
