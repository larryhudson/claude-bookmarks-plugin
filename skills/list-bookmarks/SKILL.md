---
name: list-bookmarks
description: List all bookmarks the user has saved across every Claude Code session in every project. Bookmarks are messages prefixed with `bm:` that were blocked from the assistant's context but persisted to the session transcript on disk. Use when the user asks to see their bookmarks, review bookmarks, or says "/list-bookmarks".
---

# list-bookmarks

Bookmarks are stored as `queue-operation` / `enqueue` entries inside session transcript jsonl files under `~/.claude/projects/`. Each project directory is a sanitized cwd; within it, one jsonl per session.

## How to list them

Run the bundled script — it scans every jsonl across every project using ripgrep and returns one row per bookmark.

The script lives two directories up from this skill, at `../../scripts/list-bookmarks.sh` relative to the skill's base directory. The base directory is given to you in the skill invocation header (something like `/Users/<you>/.claude/plugins/cache/claude-bookmarks/bookmarks/<version>/skills/list-bookmarks`). Run it with its absolute path:

```bash
# Replace <SKILL_BASE> with the base directory from the skill header above.
"<SKILL_BASE>/../../scripts/list-bookmarks.sh"
```

Do NOT use `$CLAUDE_PLUGIN_ROOT` — that env var is only set inside hook processes, not in the Bash tool you invoke from this skill.

Output is TSV with columns: `line_number`, `timestamp`, `file_path`, `content`, sorted by timestamp ascending.

## Presenting results

- Format as a numbered list. Ask the user if they want newest-first, or grouped by project, if ambiguous.
- Strip the `bm:` prefix from content when displaying.
- Show timestamps in a human-readable form (relative time or local date).
- **Keep the file path + line number available** so you can Read the jsonl at that line later if the user asks what was happening around a bookmark. Read a window (e.g. 20 lines before and after) and summarize the surrounding `user` / `assistant` entries.

If the script emits no output, tell the user there are no bookmarks yet and remind them to prefix messages with `bm:`.

## Notes

- Do not edit the jsonl files.
- The script uses `rg --json` and a single jq pass — it's fast (<1s for thousands of sessions).
- Override the projects root with `CLAUDE_PROJECTS_DIR` if needed (defaults to `~/.claude/projects`).
