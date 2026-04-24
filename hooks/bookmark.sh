#!/usr/bin/env bash
# UserPromptSubmit hook: if the prompt starts with `/bookmark` (or the
# namespaced `/bookmarks:bookmark`), block it from reaching the assistant.
# Claude Code still writes the original prompt to the session transcript
# jsonl on disk, which is what list-bookmarks reads.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  # Emit a system message so the user sees why bookmarks aren't working,
  # but don't block the prompt — fall through and let it reach the assistant.
  printf '{"systemMessage":"claude-bookmarks: jq not installed — bookmark prompt passed through to assistant. Install jq (brew install jq) to enable bookmarking."}\n'
  exit 0
fi

jq -c '
  if (.prompt | test("^\\s*/bookmark(s:bookmark)?(\\s|$)"))
  then {
    decision: "block",
    reason: "📌 Bookmarked (hidden from assistant). Use /bookmarks:list-bookmarks to view. [bookmark-plugin:v1]",
    suppressOutput: true
  }
  else empty
  end
'
