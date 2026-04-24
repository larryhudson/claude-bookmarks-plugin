---
name: bookmark
description: Save a bookmark into the session transcript without consuming assistant context. Invoked via `/bookmarks:bookmark <note>`. The UserPromptSubmit hook blocks the message before it reaches the assistant, but Claude Code still persists it to the session jsonl where /bookmarks:list-bookmarks can find it later.
---

# bookmark

**You should never see this file loaded.** The plugin's `UserPromptSubmit` hook intercepts any prompt starting with `/bookmarks:bookmark` or `/bookmark` and blocks it before the skill content is injected. This file exists purely so the command appears in the slash-command picker.

If you ARE reading this, something went wrong with the hook. Tell the user:

> The bookmark hook didn't fire — your message was not saved as a bookmark. Check that the `bookmarks` plugin is enabled and that `UserPromptSubmit` hooks are running (`/hooks`).
