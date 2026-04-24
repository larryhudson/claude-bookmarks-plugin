# claude-bookmarks

A Claude Code plugin that lets you drop bookmarks into your session transcript **without consuming any assistant context**.

## How it works

Type a bookmark:

```
/bookmark remember to investigate the auth regression
```

A `UserPromptSubmit` hook intercepts the message and blocks it (`decision: "block"`) so it never reaches the assistant. Claude Code still writes the original prompt to the session transcript jsonl on disk, where it can be retrieved later.

Later, run `/bookmarks:list-bookmarks` and the assistant will pull up every bookmark you've ever made across every project — with file paths and line numbers so it can Read surrounding context if you ask "what was I working on when I wrote bookmark #3?".

## Install

```
/plugin marketplace add larryhudson/claude-bookmarks-plugin
/plugin install bookmarks@claude-bookmarks
```

Or declare it in `~/.claude/settings.json` for auto-install on every session:

```json
{
  "extraKnownMarketplaces": {
    "claude-bookmarks": {
      "source": { "source": "github", "repo": "larryhudson/claude-bookmarks-plugin" }
    }
  },
  "enabledPlugins": {
    "bookmarks@claude-bookmarks": true
  }
}
```

## Usage

```
/bookmark fix the rate limiter next
/bookmarks:list-bookmarks
```

Or ask the assistant in plain English: "list my bookmarks" / "show me bookmarks from yesterday" / "what was I doing around bookmark #3?".

## How it actually works (implementation notes)

- **`hooks/bookmark.sh`** — fires on `UserPromptSubmit`. If the prompt starts with `/bookmark` (or the namespaced `/bookmarks:bookmark`), returns `decision: "block"` with a sentinel marker `[bookmark-plugin:v1]` in the reason. The assistant never sees the prompt.
- **`skills/bookmark/`** — an empty skill that exists only to make `/bookmarks:bookmark` appear in the slash-command picker. Its content is never loaded because the hook fires first.
- **`scripts/list-bookmarks.sh`** — scans every `~/.claude/projects/*/*.jsonl` with `rg --json` for the sentinel marker, extracts the original prompt, and emits one TSV row per bookmark.
- **`skills/list-bookmarks/`** — the skill the assistant invokes when you ask for your bookmarks. It just runs the script.

## Dev

```bash
git clone https://github.com/larryhudson/claude-bookmarks-plugin ~/claude-bookmarks-plugin
/plugin marketplace add ~/claude-bookmarks-plugin
/plugin install bookmarks@claude-bookmarks
```

After editing files, bump `version` in `.claude-plugin/plugin.json` and run `/plugin marketplace update claude-bookmarks`. Claude Code caches by version.

## License

MIT
