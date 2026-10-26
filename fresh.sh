#!/bin/sh
# Bootstrap a Mac from this repo, which must live at ~/.dotfiles.
# Installs Oh My Zsh and Homebrew, links configs into $HOME, then applies
# shared git defaults. Safe to re-run. Git name and email stay machine-local.

echo "Setting up your Mac..."

# Install Oh My Zsh when its `omz` command is not already on PATH.
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Link shell files before Homebrew. Its installer appends `brew shellenv` to
# ~/.zprofile when that file is missing; the copy in this repo already does that.
# .zshrc holds the prompt, PATH, and tool defaults such as OPENCODE_EXPERIMENTAL_PLAN_MODE.
rm -f $HOME/.zshrc $HOME/.zprofile
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/.zprofile $HOME/.zprofile

# Install Homebrew when `brew` is not on PATH. On Apple Silicon the new binary
# is /opt/homebrew/bin/brew, which this shell will not see until the next login,
# so load it for the brew commands below.
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Link files, not the whole config directory. ~/.config/opencode must stay a
# real directory: OpenCode writes machine-local state there (service.json).
mkdir -p $HOME/.config/alacritty $HOME/.config/opencode $HOME/.claude
rm -f $HOME/.tmux.conf $HOME/.config/alacritty/alacritty.toml $HOME/.config/opencode/opencode.json \
  $HOME/.config/opencode/AGENTS.md $HOME/.claude/CLAUDE.md
ln -s $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/config/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
ln -s $HOME/.dotfiles/config/opencode/opencode.json $HOME/.config/opencode/opencode.json
# One instruction file. OpenCode reads AGENTS.md; Claude Code reads CLAUDE.md.
ln -s $HOME/.dotfiles/config/opencode/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -s $HOME/.dotfiles/config/opencode/AGENTS.md $HOME/.claude/CLAUDE.md

# Relink a skill or agent directory only when it is missing or already a symlink.
# A real file or directory is left alone so a machine-local copy is not replaced.
# ~/.agents/skills is the shared set (Cursor and OpenCode). ~/.config/opencode/skills
# is for a skill that should exist only in OpenCode.
if [ ! -e "$HOME/.config/opencode/skills" ] || [ -L "$HOME/.config/opencode/skills" ]; then
  rm -f "$HOME/.config/opencode/skills"
  ln -s "$HOME/.dotfiles/config/opencode/skills" "$HOME/.config/opencode/skills"
else
  echo "fresh.sh: $HOME/.config/opencode/skills is a real directory, so the vendored skills stay hidden. Move that directory aside and re-run fresh.sh."
fi
mkdir -p "$HOME/.agents"
if [ ! -e "$HOME/.agents/skills" ] || [ -L "$HOME/.agents/skills" ]; then
  rm -f "$HOME/.agents/skills"
  ln -s "$HOME/.dotfiles/skills" "$HOME/.agents/skills"
else
  echo "fresh.sh: $HOME/.agents/skills is a real directory, so the vendored skills stay hidden. Move that directory aside and re-run fresh.sh."
fi
if [ ! -e "$HOME/.config/opencode/agents" ] || [ -L "$HOME/.config/opencode/agents" ]; then
  rm -f "$HOME/.config/opencode/agents"
  ln -s "$HOME/.dotfiles/config/opencode/agents" "$HOME/.config/opencode/agents"
else
  echo "fresh.sh: $HOME/.config/opencode/agents is a real directory, so the vendored agents stay hidden. Move that directory aside and re-run fresh.sh."
fi

# Formulae and casks from the Brewfile, including git and diff-so-fancy.
brew update
brew tap homebrew/bundle
brew bundle --file $HOME/.dotfiles/Brewfile

# Shared, non-secret git defaults. The pager needs diff-so-fancy from the Brewfile.
# Name and email are per machine; see README.md.
git config --global init.defaultBranch main
git config --global core.excludesfile "$HOME/.dotfiles/.gitignore_global"
git config --global core.attributesfile "$HOME/.dotfiles/.gitattributes_global"
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"

# Remind and continue. Do not invent an identity in this repo.
if ! git config --global user.name >/dev/null 2>&1 || ! git config --global user.email >/dev/null 2>&1; then
  echo ""
  echo "Git user.name / user.email are not set. Run once on this machine:"
  echo '  git config --global user.name "Your Name"'
  echo '  git config --global user.email "you@example.com"'
  echo ""
fi
