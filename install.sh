#!/usr/bin/env bash
#
# Install the per-tool configs in this repo. Runs <tool>/install.sh for each
# tool given (default: all of them).
#
#   ./install.sh                  # from a checkout: ghostty + herdr
#   ./install.sh herdr            # just one tool
#
#   # from GitHub, without cloning (downloads the repo tarball first):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyleczhang/agent-workspace/main/install.sh)"
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyleczhang/agent-workspace/main/install.sh)" _ herdr
#
set -euo pipefail

TARBALL="https://codeload.github.com/kyleczhang/agent-workspace/tar.gz/refs/heads/main"
DEFAULT_TOOLS=(ghostty herdr)

die() { echo "agent-workspace: $*" >&2; exit 1; }

# Use the checkout this script sits in; when piped from curl there is none,
# so fetch the repo into a temp dir.
root=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -z "$root" ] || [ ! -d "$root/ghostty" ]; then
  command -v curl >/dev/null 2>&1 || die "curl is required"
  root="$(mktemp -d)"
  trap 'rm -rf "$root"' EXIT
  curl -fsSL "$TARBALL" | tar -xz -C "$root" --strip-components=1 || die "download failed: $TARBALL"
fi

tools=("$@")
[ ${#tools[@]} -gt 0 ] || tools=("${DEFAULT_TOOLS[@]}")

for tool in "${tools[@]}"; do
  [ -f "$root/$tool/install.sh" ] || die "no installer for '$tool' (expected $tool/install.sh)"
  echo "==> $tool"
  bash "$root/$tool/install.sh"
done
