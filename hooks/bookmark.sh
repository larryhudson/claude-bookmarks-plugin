#!/usr/bin/env bash
# UserPromptSubmit hook: if the prompt starts with `bm:`, block it from
# reaching the assistant. The raw prompt is still written to the session
# transcript jsonl as a queue-operation entry, which is what we want —
# bookmarks live in the transcript on disk but never enter model context.

set -euo pipefail

jq -c '
  if (.prompt | test("^\\s*(bm:|/bookmark(s:bookmark)?(\\s|$))"))
  then {
    decision: "block",
    reason: "📌 Bookmarked (hidden from assistant). Use /bookmarks:list-bookmarks to view. [bookmark-plugin:v1]",
    suppressOutput: true
  }
  else empty
  end
'
