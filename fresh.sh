#!/bin/sh

echo "Setting up your Mac..."

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Symlink shell config from dotfiles (before brew install so ~/.zprofile is not appended ad hoc)
rm -f $HOME/.zshrc $HOME/.zprofile
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/.zprofile $HOME/.zprofile

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

mkdir -p $HOME/.config/alacritty
rm -f $HOME/.tmux.conf $HOME/.config/alacritty/alacritty.toml
ln -s $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/config/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file $HOME/.dotfiles/Brewfile

# Git defaults (after brew installs git). Identity is machine-specific — see README.md.
git config --global init.defaultBranch main
git config --global core.excludesfile "$HOME/.dotfiles/.gitignore_global"
git config --global core.attributesfile "$HOME/.dotfiles/.gitattributes_global"
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"

if ! git config --global user.name >/dev/null 2>&1 || ! git config --global user.email >/dev/null 2>&1; then
  echo ""
  echo "Git user.name / user.email are not set. Run once on this machine:"
  echo '  git config --global user.name "Your Name"'
  echo '  git config --global user.email "you@example.com"'
  echo ""
fi

# Set default MySQL root password and auth type
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
# pecl install imagick redis swoole

# Install global Composer packages
# /usr/local/bin/composer global require laravel/installer laravel/valet beyondcode/expose spatie/global-ray spatie/visit

# Install Laravel Valet
# $HOME/.composer/vendor/bin/valet install

# Install Global Ray
# $HOME/.composer/vendor/bin/global-ray install

# Create a Sites directory
# mkdir $HOME/Projects

# Create sites subdirectories
# mkdir $HOME/Sites/blade-ui-kit
# mkdir $HOME/Sites/laravel

# Clone Github repositories
# $DOTFILES/clone.sh

# Symlink the Mackup config file to the home directory
# ln -s $DOTFILES/.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences - we will run this last because this will reload the shell
# source $DOTFILES/.macos
