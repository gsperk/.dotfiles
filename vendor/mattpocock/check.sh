#!/bin/sh
# Show what changed in mattpocock/skills since vendor/mattpocock/PIN.
# Does not copy files or move the pin.
# The bare clone stays at ~/.cache/dotfiles/mattpocock-skills.git (or $XDG_CACHE_HOME).
set -eu
cd "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/../.."
pin=$(tr -d '[:space:]' < vendor/mattpocock/PIN)
set --
while read -r upstream _; do
  [ -n "${upstream:-}" ] || continue
  set -- "$@" "$upstream"
done < vendor/mattpocock/paths.txt
if [ "$#" -eq 0 ]; then
  echo "vendor/mattpocock: paths.txt has no skills" >&2
  exit 1
fi
cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/mattpocock-skills.git"
mkdir -p "$(dirname "$cache")"
tip=$(git ls-remote https://github.com/mattpocock/skills.git refs/heads/main | awk 'NR==1 { print $1 }')
if [ -z "$tip" ]; then
  echo "vendor/mattpocock: could not read main from mattpocock/skills" >&2
  exit 1
fi
if [ ! -d "$cache" ]; then
  git clone --bare https://github.com/mattpocock/skills.git "$cache"
fi
if ! git --git-dir="$cache" rev-parse --verify --quiet refs/heads/main >/dev/null; then
  git --git-dir="$cache" fetch origin '+refs/heads/main:refs/heads/main'
fi
have=$(git --git-dir="$cache" rev-parse refs/heads/main)
if [ "$have" != "$tip" ]; then
  git --git-dir="$cache" fetch origin '+refs/heads/main:refs/heads/main'
  have=$(git --git-dir="$cache" rev-parse refs/heads/main)
fi
if [ "$have" != "$tip" ]; then
  echo "vendor/mattpocock: cache main is $have, GitHub main is $tip" >&2
  exit 1
fi
echo "Pinned at $pin"
echo "main is $tip"
echo
echo "Commits that touched CHANGELOG.md:"
git --git-dir="$cache" log --oneline "$pin".."$tip" -- CHANGELOG.md
echo
echo "Stat diff of vendored paths:"
git --git-dir="$cache" diff --stat "$pin" "$tip" -- "$@"
