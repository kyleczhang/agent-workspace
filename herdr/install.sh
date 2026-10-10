#!/usr/bin/env bash
#
# Install the Herdr config from this folder: validate, copy it into place, and
# hot-reload a running server.
#
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.toml"
dest="${HERDR_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml}"

die() { echo "herdr: $*" >&2; exit 1; }

[ -f "$src" ] || die "source config not found: $src"

# Validate against the live binary before touching the real config.
# Skipped when herdr isn't installed.
if command -v herdr >/dev/null 2>&1; then
  if ! out="$(HERDR_CONFIG_PATH="$src" herdr config check 2>&1)"; then
    printf '%s\n' "$out" >&2
    die "config failed validation"
  fi
fi

mkdir -p "$(dirname "$dest")"

cp "$src" "$dest"
echo "installed -> $dest"

if command -v herdr >/dev/null 2>&1 && herdr server reload-config >/dev/null 2>&1; then
  echo "reloaded running herdr server"
fi
