# agent-workspace

Personal config for the terminal setup I run AI coding agents in: [Ghostty](https://ghostty.org) as the terminal and [Herdr](https://herdr.dev) as the agent workspace manager.

## Install

```sh
# from a checkout
./install.sh            # all tools
./install.sh herdr      # one tool

# from GitHub, without cloning
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyleczhang/agent-workspace/main/install.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyleczhang/agent-workspace/main/install.sh)" _ herdr
```

## Layout

| Path | What |
| --- | --- |
| `ghostty/` | Ghostty config, app icons, cursor-trail shader |
| `herdr/` | Herdr config |
| `claude/`, `codex/` | Placeholders for agent configs |
| `themes/herdr-ink/` | Optional dark theme across Ghostty, Herdr, and Claude Code, applied by hand |

More Ghostty icons: <https://github.com/jasonlong/ghostty-theme-icons>
