# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Non-login interactive shells skip ~/.zprofile; see README.md.
if ! command -v brew >/dev/null && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Oh My Zsh Agnoster: hide user@host when logged in as this user locally (stock theme in ~/.oh-my-zsh).
export DEFAULT_USER=graeme

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# pnpm
export PNPM_HOME="/Users/graeme/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end export 


export PATH="$HOME/.local/bin:$PATH"

# Homebrew Claude Code does not auto-update. This lets the CLI upgrade its own cask.
export CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1

# Private startflows modules (GitHub Packages). The token stays in the gh keychain.
# One-time, so this credential can read packages:
#   gh auth refresh -h github.com -s read:packages
if [[ -z ${STARTFLOWS_GH_PKGS_TOKEN:-} ]] && command -v gh >/dev/null; then
  _startflows_gh_token="$(gh auth token 2>/dev/null)" || true
  if [[ -n ${_startflows_gh_token:-} ]]; then
    export STARTFLOWS_GH_PKGS_TOKEN="$_startflows_gh_token"
  fi
  unset _startflows_gh_token
fi

# Pretty diff for two arbitrary local files (not necessarily in a git repo).
# See README.md — requires diff-so-fancy (Brewfile) and core.pager from fresh.sh.
dif() {
  if [[ $# -ne 2 ]]; then
    echo "usage: dif <file1> <file2>" >&2
    return 1
  fi
  git diff --color --no-index -- "$1" "$2" | diff-so-fancy | less --tabs=4 -RFX
}

# One tmux session per project. Name defaults to the current directory.
#   tproj          # create or switch to a session for this folder
#   tproj api      # explicit session name
# Session names cannot contain "." or ":"; those become "-".
tproj() {
  local name="${1:-${PWD:t}}"
  name="${name#.}"
  name="${name//[.:]/-}"
  if [[ -z "$name" ]]; then
    echo "usage: tproj [session-name]" >&2
    return 1
  fi
  if [[ -n "$TMUX" ]]; then
    tmux has-session -t "=$name" 2>/dev/null || tmux new-session -d -s "$name" -c "$PWD"
    tmux switch-client -t "=$name"
  else
    tmux new-session -A -s "$name" -c "$PWD"
  fi
}

