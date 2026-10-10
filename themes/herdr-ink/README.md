# herdr-ink

A dark terminal look matched to the [herdr.dev](https://herdr.dev) site ("ink" ground), applied across three tools: Ghostty, Herdr, and Claude Code. It is an optional look for occasional use; the everyday default is light. This folder is a self-contained record of it, written so an AI agent can read, modify, or apply it later. The repo's default configs (`herdr/config.toml` uses `catppuccin-latte`, `ghostty/config.ghostty` uses Ayu) are unaffected; the files here are layered on top when applying.

## Palette

All values come from herdr.dev's `site.css` (ink tokens) and Herdr's built-in Catppuccin Mocha palette (`src/app/state.rs` in `herdrdev/herdr`).

| Role | Color | Used by |
| --- | --- | --- |
| Background | `#17171a` | Ghostty `background`; Herdr sidebar (via `sidebar_bg = Reset`) |
| Panel | `#1e1e22` | Herdr `panel_bg` |
| Raised surface | `#26262b` | Herdr `active_row_bg`, `surface0` |
| Line / selection | `#35353d` | Ghostty selection, palette 0; Herdr `selection_bg`, `surface1` |
| Plain text | `#b0afb6` | Ghostty `foreground` (muted grey, like the site's Claude Code mock) |
| Bright ink | `#eae8ee` | Ghostty `bold-color`, palette 15; Herdr `text` |
| Dim ink | `#cdccd2` | Ghostty palette 7; Herdr `subtext0` |
| Accent (mauve) | `#cba6f7` | Herdr `accent`, sidebar branch name |
| Cursor | `#9d6ef0` | Ghostty `cursor-color` (and the cursor-smear shader trail) |
| Claude user message | `#d6d4da` on `#303036` | Claude Code `text`, `userMessageBackground` |

ANSI colors 1–6 and 9–14 are Catppuccin Mocha, unchanged.

## Files

Paths are relative to this folder (`themes/herdr-ink/`), not the repo root.

| File | Installs to | How |
| --- | --- | --- |
| `ghostty/themes/herdr-ink` | `~/.config/ghostty/themes/herdr-ink` | Copy |
| `ghostty/config.snippet` | `~/.config/ghostty/config` | Merge: replace existing `theme`, `bold-is-bright`, `bold-color`, and `cursor-color` lines |
| `herdr/theme.toml` | `~/.config/herdr/config.toml` | Merge: replace the whole `[theme]` block (and any `[theme.custom*]` tables); apply the branch-color note at the bottom to `[ui.sidebar.spaces]` |
| `claude/themes/herdr-ink.json` | `~/.claude/themes/herdr-ink.json` | Copy |
| `claude/settings.snippet.json` | `~/.claude/settings.json` | Merge: set the top-level `theme` key; leave every other key alone |

## Applying

1. Copy and merge the files per the table above. Never overwrite `~/.config/ghostty/config`, `~/.config/herdr/config.toml`, or `~/.claude/settings.json` wholesale — they hold unrelated settings (fonts, keybindings, permissions, plugins).
2. Validate:
   - Ghostty: `/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config`, then `ghostty +show-config | grep -E '^(theme|foreground|background|cursor-color|bold-color) '`.
   - Herdr: `herdr config check`, then `herdr server reload-config` to apply to a running server.
   - Claude Code: `python3 -c "import json; json.load(open('$HOME/.claude/themes/herdr-ink.json'))"`.
3. Reload: Ghostty `Cmd+Shift+,`; Claude Code picks up the theme on restart (or via `/theme`).

## Constraints and gotchas

- Herdr sidebar token `fg` accepts only fixed `#RGB`/`#RRGGBB` hex, not theme token names, and the `agent` token is always grey (mauve when focused) — it cannot follow the agent's state color. Only `state_text` is state-colored.
- Ghostty `bold-color` is set in the main config, not in the theme file, because a main-config `bold-is-bright = true` would override it. `bold-is-bright` is deprecated since Ghostty 1.2.
- Claude Code custom themes are not in the public docs; the format was read from the 2.1.286 binary. A theme file is `{ "name", "base", "overrides" }`, where `base` is a built-in theme (`dark`, `light`, `dark-ansi`, …) and `overrides` maps theme keys (`text`, `userMessageBackground`, `promptBorder`, `diffAdded`, …) to `#hex`, `rgb(r,g,b)`, `ansi256(n)`, or `ansi:<name>`. Unknown keys are ignored. It is selected with `"theme": "custom:<file slug>"`. If a future version drops this, fall back to `"theme": "dark"`.
- Claude Code's `text` key colors the user's own messages. Keep it noticeably brighter than Ghostty's `foreground` (assistant prose uses the terminal default) or the two become hard to tell apart; `#b0afb6` was tried and rejected for that reason, pure white `#ffffff` was rejected as too bright.
- This bundle is an optional, occasional dark look, not the default. The user's everyday setup is light (`herdr/config.toml` and `ghostty/config.ghostty`), so never change the defaults to match this bundle. When applied, it is always dark rather than following macOS appearance. For Claude Code, use the default (non-daltonized) themes.
