#!/usr/bin/env bash
# Repository contract tests: catch broken paths and drift between manifests, docs and layout.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
checks=0
pass() { checks=$((checks + 1)); printf 'ok   %s\n' "$1"; }
bad() { checks=$((checks + 1)); printf 'FAIL %s\n' "$1"; fail=1; }
has_path() {
  local path="${1#./}"
  path="${path%/}"
  [ -e "$path" ]
}

echo "== marketplace plugin paths"
plugin_count=$(jq '.plugins | length' .claude-plugin/marketplace.json)
[ "$plugin_count" -gt 0 ] && pass "marketplace declares plugins" || bad "marketplace declares plugins"

while IFS=$'\t' read -r name source; do
  source="${source#./}"
  if [ -f "$source/.claude-plugin/plugin.json" ]; then
    pass "$name source resolves: $source"
  else
    bad "$name source is missing: $source/.claude-plugin/plugin.json"
    continue
  fi

  manifest_name=$(jq -r '.name' "$source/.claude-plugin/plugin.json")
  [ "$manifest_name" = "$name" ] && pass "$name matches its plugin manifest" || bad "$name does not match manifest name $manifest_name"
done < <(jq -r '.plugins[] | [.name, .source] | @tsv' .claude-plugin/marketplace.json)

echo "== customize script"
core_source=$(jq -r '.plugins[] | select(.name == "craft") | .source' .claude-plugin/marketplace.json)
core_manifest="${core_source#./}/.claude-plugin/plugin.json"
if grep -Fq "$core_manifest" scripts/customize.sh; then
  pass "customize.sh reads the core manifest at $core_manifest"
else
  bad "customize.sh does not follow marketplace core source $core_manifest"
fi

echo "== documented repository layout"
# These are concrete paths in the README layout block, not examples such as plugins/<stack>.
while IFS= read -r path; do
  [ -z "$path" ] && continue
  if has_path "$path"; then pass "README layout path exists: $path"; else bad "README layout path is missing: $path"; fi
done <<'PATHS'
.claude-plugin/marketplace.json
plugins/sdlc/
plugins/sdlc-mobile/
admin/managed-settings.json
examples/
scripts/customize.sh
tests/test-hooks.sh
PATHS

echo "== example artifact contract"
example_dir="examples/intent/demo-hello-world"
for file in intent.md spec.md plan.api.md; do
  [ -f "$example_dir/$file" ] && pass "example contains $file" || bad "example is missing $example_dir/$file"
done

echo "== local Markdown links"
# Resolve relative links from the directory containing each Markdown file.
while IFS= read -r -d '' markdown_file; do
  markdown_dir=$(dirname "$markdown_file")
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    case "$target" in
      http://*|https://*|mailto:*|\\#*|/*) continue ;;
    esac
    target="${target%% *}"
    target="${target%%\\#*}"
    [ -z "$target" ] && continue
    resolved="$markdown_dir/$target"
    if [ -e "$resolved" ]; then
      pass "Markdown link resolves: $markdown_file -> $target"
    else
      bad "Markdown link is broken: $markdown_file -> $target"
    fi
  done < <(grep -oE '\\]\\([^)]*\\)' "$markdown_file" | sed -E 's/^\\]\\(([^)]*)\\)$/\\1/')
done < <(find README.md docs plugins -type f -name '*.md' -print0)

echo "== plugin file references resolve"
# Skills, agents and output styles name files as ${CLAUDE_PLUGIN_ROOT}/<path>; each must ship in the plugin.
while IFS=$'\t' read -r name source; do
  source="${source#./}"
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    path="$source/${ref#\$\{CLAUDE_PLUGIN_ROOT\}/}"
    path="${path%.}"
    # Tracked, not just on disk: .gitignore once hid templates/artifacts/ from every commit.
    if [ -n "$(git ls-files -- "$path")" ]; then
      pass "$name ships $ref"
    elif [ -e "$path" ]; then
      bad "$name references $path, which exists but isn't committed (check .gitignore)"
    else
      bad "$name references a missing file: $path"
    fi
  done < <(grep -rhoE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+' "$source/skills" "$source/agents" "$source/output-styles" 2>/dev/null | sort -u || true)
done < <(jq -r '.plugins[] | [.name, .source] | @tsv' .claude-plugin/marketplace.json)

echo "== templates"
# The PR template a repo gets from /craft:init and the one /craft:review fills must be the same.
if cmp -s plugins/sdlc/templates/artifacts/pr.md plugins/sdlc/templates/repo/.github/pull_request_template.md; then
  pass "artifacts/pr.md matches the repo PR template"
else
  bad "artifacts/pr.md differs from templates/repo/.github/pull_request_template.md"
fi
# Workflows must still run for public marketplaces, where PLUGIN_READ_TOKEN isn't set.
while IFS= read -r workflow; do
  if grep -B1 'gh auth setup-git' "$workflow" | grep -q "if: env.GH_TOKEN != ''"; then
    pass "$workflow only sets up git auth when a token is set"
  else
    bad "$workflow runs gh auth setup-git without checking GH_TOKEN"
  fi
done < <(grep -rl 'gh auth setup-git' plugins/*/templates || true)

echo "== hook commands resolve"
# Every hook command must point at a script that ships in the plugin and is executable in git.
while IFS=$'\t' read -r name source; do
  source="${source#./}"
  hooks="$source/hooks/hooks.json"
  [ -f "$hooks" ] || continue
  while IFS= read -r command; do
    script=$(echo "$command" | sed 's#"${CLAUDE_PLUGIN_ROOT}"#'"$source"'#' | awk '{print $1}')
    if [ ! -f "$script" ]; then
      bad "$name hook script is missing: $script"
    elif [ "$(git ls-files -s "$script" | cut -c1-6)" != "100755" ]; then
      bad "$name hook script is not executable in git: $script"
    else
      pass "$name hook resolves: $script"
    fi
  done < <(jq -r '.hooks[][].hooks[].command' "$hooks")
done < <(jq -r '.plugins[] | [.name, .source] | @tsv' .claude-plugin/marketplace.json)

echo "== names match the marketplace"
# Install commands, enabledPlugins keys and repo links must all use the current marketplace and repo,
# so a rename can't leave half the docs pointing somewhere else.
market=$(jq -r '.name' .claude-plugin/marketplace.json)
repo=$(jq -r '.repository' "$core_manifest" | sed -E 's#^https://github.com/##; s#\.git$##')
plugins=$(jq -r '.plugins[].name' .claude-plugin/marketplace.json)
sources=$(git ls-files -- . ':!tests' ':!CHANGELOG.md')

# The manifest must name the GitHub repo this checkout came from, so renaming the repo on GitHub
# fails CI until the docs follow. Skipped without a GitHub origin (e.g. a fresh copy).
origin=$(git remote get-url origin 2>/dev/null | sed -nE 's#^(https://github\.com/|git@github\.com:)([^/]+/[^/]+)$#\2#p' | sed -E 's#\.git$##' || true)
if [ -n "$origin" ]; then
  [ "$repo" = "$origin" ] && pass "manifest repository matches git origin $origin" || bad "manifest repository $repo is not git origin $origin; run scripts/customize.sh --repo $origin"
fi

for manifest in plugins/*/.claude-plugin/plugin.json; do
  [ "$(jq -r '.repository' "$manifest")" = "https://github.com/$repo" ] && pass "$manifest repository is $repo" || bad "$manifest repository is not https://github.com/$repo"
done
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  plugin="${ref%@*}" at="${ref#*@}"
  [[ "$at" =~ ^v[0-9] ]] && continue  # GitHub Actions versions such as checkout@v4
  if [ "$at" = "$market" ] && grep -qx "$plugin" <<< "$plugins"; then
    pass "plugin reference uses the marketplace: $ref"
  else
    bad "plugin reference doesn't match a plugin@$market: $ref"
  fi
done < <(echo "$sources" | xargs grep -ohE '[a-z0-9-]+@[a-z0-9-]+([^a-z0-9.-]|$)' | sed -E 's/[^a-z0-9-]$//' | sort -u)
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  [ "$ref" = "$repo" ] && pass "repo reference is current: $ref" || bad "repo reference is stale: $ref (expected $repo)"
done < <(echo "$sources" | xargs grep -ohE "${repo%%/*}/[A-Za-z0-9_.-]+" | sort -u)
for settings in plugins/sdlc/templates/repo/.claude/settings.json admin/managed-settings.json; do
  keys=$(jq -r '.extraKnownMarketplaces | keys[]' "$settings")
  [ "$keys" = "$market" ] && pass "$settings knows marketplace $market" || bad "$settings marketplaces are '$keys', expected $market"
done

echo "== commands and agents exist"
# /craft:<skill> and `craft:<agent>` references must name a skill or agent of that plugin.
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  ref="${ref#/}" ref="${ref//\`/}"
  ns="${ref%%:*}" item="${ref#*:}"
  source=$(jq -r --arg n "$ns" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
  if [ -z "$source" ]; then
    bad "reference to unknown plugin namespace: $ref"
  elif [ -f "${source#./}/skills/$item/SKILL.md" ] || [ -f "${source#./}/agents/$item.md" ]; then
    pass "command or agent exists: $ref"
  else
    bad "no skill or agent for: $ref"
  fi
done < <(echo "$sources" | xargs grep -ohE '/[a-z][a-z-]*:[a-z][a-z-]*|`[a-z][a-z-]*:[a-z][a-z-]*`' | sort -u)

if [ "$fail" -eq 0 ]; then echo "all $checks repository contract checks passed"; else echo "repository contract checks failed"; fi
[ "$fail" -eq 0 ]
