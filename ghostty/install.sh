#!/usr/bin/env bash
#
# Install the Ghostty config, custom icon, and cursor-trail shader from this
# folder into Ghostty's config directory.
#
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

die() { echo "ghostty: $*" >&2; exit 1; }

for f in config.ghostty icons/ghostty-light.icns shaders/cursor_smear.glsl; do
  [ -f "$src/$f" ] || die "missing source file: $src/$f"
done

mkdir -p "$dest/shaders"

cp "$src/config.ghostty" "$dest/config"
cp "$src/icons/ghostty-light.icns" "$dest/Ghostty.icns"
cp "$src/shaders/cursor_smear.glsl" "$dest/shaders/cursor_smear.glsl"
echo "installed -> $dest (config, Ghostty.icns, shaders/cursor_smear.glsl)"

echo "reload Ghostty with Cmd+Shift+, (needs JetBrainsMono Nerd Font: brew install --cask font-jetbrains-mono-nerd-font)"
