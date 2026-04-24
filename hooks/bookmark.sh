#!/usr/bin/env bash
# UserPromptSubmit hook: if the prompt starts with `/bookmark` (or the
# namespaced `/bookmarks:bookmark`), block it from reaching the assistant.
# Claude Code still writes the original prompt to the session transcript
# jsonl on disk, which is what list-bookmarks reads.

set -euo pipefail

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
