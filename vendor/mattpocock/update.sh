#!/bin/sh
# Stage, patch, and install vendored mattpocock skills.
# Does nothing until you run it.
#
#   update.sh <sha>                  stage a clean tree, apply patches, install, write PIN
#   update.sh --stage <sha> <dest>   write a clean tree at <dest> and stop
#   update.sh --install <tree> <sha> copy <tree> into the repo, prune, write PIN
#
# The default mode leaves the repo and PIN unchanged when a patch fails.
# Uses the same bare clone as check.sh.
set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo=$(CDPATH= cd -- "$repo/../.." && pwd)
cd "$repo"

url=https://github.com/mattpocock/skills.git
cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/mattpocock-skills.git"
paths=$repo/vendor/mattpocock/paths.txt
patches=$repo/vendor/mattpocock/patches

usage() {
  echo "usage: vendor/mattpocock/update.sh <sha>" >&2
  echo "       vendor/mattpocock/update.sh --stage <sha> <dest>" >&2
  echo "       vendor/mattpocock/update.sh --install <tree> <sha>" >&2
  exit 1
}

reject_path() {
  case "$1" in
    ''|/*|*..*)
      echo "vendor/mattpocock: refusing path '$1'" >&2
      exit 1
      ;;
  esac
}

require_sha() {
  if ! printf '%s\n' "$1" | grep -Eq '^[0-9a-f]{40}$'; then
    echo "vendor/mattpocock: '$1' is not a full 40-character SHA" >&2
    exit 1
  fi
}

ensure_commit() {
  mkdir -p "$(dirname "$cache")"
  if [ ! -d "$cache" ]; then
    git clone --bare "$url" "$cache"
  fi
  if ! git --git-dir="$cache" cat-file -e "$1^{commit}" 2>/dev/null; then
    git --git-dir="$cache" fetch origin '+refs/heads/main:refs/heads/main'
  fi
  if ! git --git-dir="$cache" cat-file -e "$1^{commit}" 2>/dev/null; then
    echo "vendor/mattpocock: $1 is not in the cached history of main" >&2
    exit 1
  fi
}

stage_tree() {
  tree=$1
  sha=$2
  n=0
  mkdir -p "$tree"
  while read -r upstream dest; do
    [ -n "${upstream:-}" ] || continue
    reject_path "$upstream"
    reject_path "$dest"
    extract=$(mktemp -d)
    git --git-dir="$cache" archive -o "$extract/skill.tar" "$sha" "$upstream"
    tar -x -C "$extract" -f "$extract/skill.tar"
    rm -f "$extract/skill.tar"
    if [ ! -d "$extract/$upstream" ]; then
      echo "vendor/mattpocock: $upstream is not in $sha" >&2
      rm -rf "$extract"
      exit 1
    fi
    mkdir -p "$tree/$(dirname "$dest")"
    rm -rf "$tree/$dest"
    mv "$extract/$upstream" "$tree/$dest"
    rm -rf "$extract"
    n=$((n + 1))
  done < "$paths"
  if [ "$n" -eq 0 ]; then
    echo "vendor/mattpocock: paths.txt has no skills" >&2
    exit 1
  fi
}

is_kept() {
  case "$1" in
    skills/release-notes|config/opencode/skills/plan-from-design) return 0 ;;
    *) return 1 ;;
  esac
}

dest_listed() {
  while read -r _ dest; do
    [ -n "${dest:-}" ] || continue
    if [ "$dest" = "$1" ]; then
      return 0
    fi
  done < "$paths"
  return 1
}

install_tree() {
  tree=$1
  sha=$2
  if [ ! -d "$tree" ]; then
    echo "vendor/mattpocock: $tree is not a directory" >&2
    exit 1
  fi
  while read -r upstream dest; do
    [ -n "${upstream:-}" ] || continue
    reject_path "$dest"
    if [ ! -d "$tree/$dest" ]; then
      echo "vendor/mattpocock: $tree is missing $dest" >&2
      exit 1
    fi
    rm -rf "$repo/$dest"
    mkdir -p "$(dirname "$repo/$dest")"
    cp -R "$tree/$dest" "$repo/$dest"
  done < "$paths"
  for dir in "$repo"/skills/*/ "$repo"/config/opencode/skills/*/; do
    [ -d "$dir" ] || continue
    rel=${dir#"$repo/"}
    rel=${rel%/}
    if is_kept "$rel"; then
      continue
    fi
    if dest_listed "$rel"; then
      continue
    fi
    rm -rf "$dir"
  done
  printf '%s\n' "$sha" > "$repo/vendor/mattpocock/PIN"
}

apply_patches() {
  tree=$1
  found=0
  for p in "$patches"/*.patch; do
    [ -f "$p" ] || continue
    found=1
    (
      cd "$tree"
      git apply --check "$p"
      git apply "$p"
    )
  done
  if [ "$found" -eq 0 ]; then
    echo "vendor/mattpocock: no patches in $patches" >&2
    exit 1
  fi
}

mode=update
if [ "${1:-}" = "--stage" ]; then
  mode=stage
  shift
elif [ "${1:-}" = "--install" ]; then
  mode=install
  shift
fi

case "$mode" in
  stage)
    [ $# -eq 2 ] || usage
    require_sha "$1"
    ensure_commit "$1"
    if [ -e "$2" ]; then
      echo "vendor/mattpocock: $2 already exists" >&2
      exit 1
    fi
    stage_tree "$2" "$1"
    ;;
  install)
    [ $# -eq 2 ] || usage
    require_sha "$2"
    install_tree "$1" "$2"
    ;;
  update)
    [ $# -eq 1 ] || usage
    require_sha "$1"
    ensure_commit "$1"
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    stage_tree "$work/tree" "$1"
    apply_patches "$work/tree"
    install_tree "$work/tree" "$1"
    ;;
  *)
    usage
    ;;
esac
