#!/usr/bin/env bash
# List all bookmarks across every Claude Code session in every project.
#
# When the UserPromptSubmit hook blocks a bookmark prompt, Claude Code writes
# a system/informational entry to the transcript jsonl with the original
# prompt embedded as "Original prompt: <text>". We scan for those.
#
# Output: TSV columns: line_number \t timestamp \t file_path \t content
set -euo pipefail

missing=()
for cmd in rg jq; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ ${#missing[@]} -gt 0 ]; then
  # Map binary name -> package name (rg lives in the ripgrep package).
  pkgs=()
  for cmd in "${missing[@]}"; do
    case "$cmd" in
      rg) pkgs+=("ripgrep") ;;
      *)  pkgs+=("$cmd") ;;
    esac
  done
  echo "claude-bookmarks: missing required command(s): ${missing[*]}" >&2
  echo "Install with: brew install ${pkgs[*]}  (macOS)" >&2
  echo "          or: apt install ${pkgs[*]}   (Debian/Ubuntu)" >&2
  exit 127
fi

PROJECTS="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"

# Filter on the sentinel marker emitted by our hook — robust to Claude Code
# changing its wrapper phrasing. If we ever change the marker, bump the version.
MARKER='[bookmark-plugin:v1]'

rg --json --glob '*.jsonl' --no-messages --fixed-strings \
   "$MARKER" \
   "$PROJECTS" 2>/dev/null \
| jq -r '
    select(.type == "match")
    | .data as $m
    | ($m.lines.text | fromjson?) as $e
    | select($e != null and ($e.content // "") != "")
    | ($e.content | capture("Original prompt: (?<p>.*)$"; "m").p) as $prompt
    | "\($m.line_number)\t\($e.timestamp)\t\($m.path.text)\t\($prompt)"
  ' \
| sort -t$'\t' -k2
