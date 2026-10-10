# AGENTS.md — herdr/

Herdr config. Repo-wide rules (commit messages, markdown style) are in the root `AGENTS.md`.

## Commands

```sh
./install.sh                                             # validate, install, and hot-reload a running server
HERDR_CONFIG_PATH=./config.toml herdr config check      # validate after any edit
herdr --default-config                                   # every option and its default
herdr server reload-config                               # hot-reload the installed config
```

`herdr config check` is the test suite here — run it after any edit to `config.toml`. `install.sh` runs it itself and aborts before touching the real config if it fails. It fails outright when the `herdr` binary isn't on `PATH` — install Herdr first.

## Files

`config.toml` installs to `${HERDR_CONFIG_PATH:-${XDG_CONFIG_HOME:-~/.config}/herdr/config.toml}`. It deliberately lists **only non-default values** — do not add an option just to restate its default, and check `herdr --default-config` before adding one. Sections in use: `[keys]`, `[theme]`, `[ui]`, `[ui.toast]`, `[ui.sidebar.spaces]`, `[ui.sidebar.agents]`.

## Config notes

The `[keys]` block is organized by sidebar area rather than by action, and that grouping is load-bearing: each area owns one modifier, and number jumps and `n`/`p` cycling within an area share it — tabs use `prefix` plain, spaces use `prefix+shift`, agents use `prefix+alt`. A new binding belongs to whichever area's modifier it extends (e.g. `new_workspace = "prefix+shift+c"` parallels the default `new_tab = "prefix+c"`). Area groups also hold that area's non-navigation bindings — `rename_tab = "prefix+r"` sits under `# Tabs` because `prefix` plain is the tabs modifier — and `""` unbinds an action outright, which is how `resize_mode = ""` frees `prefix+r`.

Sidebar `rows` are arrays of lines; each line is an array of cells, where a cell is either a bare token string (`"state_icon"`, `"tab"`, `"agent"`) or an inline table adding style (`{ token = "branch", fg = "#8839ef" }`). Colors are hard-coded hex values matched to the `catppuccin-latte` theme set in `[theme]`, so changing the theme means revisiting them.
