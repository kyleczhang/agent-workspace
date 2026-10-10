# AGENTS.md — ghostty/

Ghostty terminal config. Repo-wide rules (commit messages, markdown style) are in the root `AGENTS.md`.

## Commands

```sh
./install.sh                                                     # install from this folder
ghostty +validate-config --config-file=./config.ghostty          # validate after any edit
ghostty +show-config --default --docs                            # every option and its docs
```

## Files

`config.ghostty` installs to `${XDG_CONFIG_HOME:-~/.config}/ghostty/config`. `install.sh` also copies `icons/ghostty-light.icns` to `Ghostty.icns` (referenced by `macos-custom-icon`) and `shaders/cursor_smear.glsl` (referenced by `custom-shader`, path relative to the config dir). The other files in `icons/` are alternatives, not installed.

## Config notes

The theme follows macOS appearance (Ayu Light / Ayu Mirage); `cursor-color` was picked to read on both, and the cursor-smear shader takes its color from it, so changing the theme means revisiting the cursor color.
