# Dotfiles

Personal macOS dev setup: Homebrew (`Brewfile`), shell, git globals, tmux, Alacritty, and personal agent instructions. Run `fresh.sh` on a new machine to install dependencies and symlink configs.

## Shell startup

`fresh.sh` symlinks `~/.zprofile` and `~/.zshrc` into this repo.

| File | Role |
|------|------|
| `.zprofile` | Homebrew only (`brew shellenv` on Apple Silicon). Read by **login** shells. |
| `.zshrc` | Oh My Zsh, tool PATH (pnpm, `~/.local/bin`), aliases, and helpers. |

Alacritty is configured to run `zsh -l`, so both files load. Terminals that start a non-login interactive shell only read `.zshrc`; a small fallback there runs `brew shellenv` if `brew` is not on `PATH` yet.

After changing shell files, open a new tab or run `exec zsh -l`.

## Coding agents

`fresh.sh` symlinks one personal instruction file, `config/opencode/AGENTS.md`, to both of these:

| Link | Who reads it |
|------|----------------|
| `~/.config/opencode/AGENTS.md` | OpenCode, on every session, then the repo `AGENTS.md` |
| `~/.claude/CLAUDE.md` | Claude Code |

Cursor uses User Rules and does not read this file. Project commands and layout stay in each repo's `AGENTS.md`.

Shared skills live in `skills/<name>/SKILL.md`. `fresh.sh` links that directory to `~/.agents/skills`, which Cursor and OpenCode both load. `config/opencode/skills/` stays linked to `~/.config/opencode/skills` for a skill that should exist only in OpenCode. A repo copy at `.agents/skills/<name>/` overrides the shared skill of the same name.

## Git defaults

`fresh.sh` applies shared **non-secret** global git settings. **Do not** commit `user.name` or `user.email` in this repo; set them once per machine.

### Applied by `fresh.sh`

| Setting | Value |
|--------|--------|
| `init.defaultBranch` | `main` |
| `core.excludesfile` | `~/.dotfiles/.gitignore_global` |
| `core.attributesfile` | `~/.dotfiles/.gitattributes_global` |
| `core.pager` | `diff-so-fancy \| less --tabs=4 -RFX` |
| `interactive.diffFilter` | `diff-so-fancy --patch` |

### One-time per machine (identity)

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Use the email tied to your Git host (GitHub, etc.) so commits match your account. `fresh.sh` prints a reminder if either value is missing.

### Manual setup (without `fresh.sh`)

```bash
git config --global init.defaultBranch main
git config --global core.excludesfile "$HOME/.dotfiles/.gitignore_global"
git config --global core.attributesfile "$HOME/.dotfiles/.gitattributes_global"
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
```

## Shell prompt

The prompt uses **stock** [Oh My Zsh Agnoster](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#agnoster) (`ZSH_THEME="agnoster"` in `.zshrc`). There is no custom theme file in this repo; OMZ loads `~/.oh-my-zsh/themes/agnoster.zsh-theme`.

`DEFAULT_USER` in `.zshrc` keeps the prompt minimal on your Mac by hiding the `user@hostname` segment when you are that user locally. SSH sessions may still show context so you can see which machine you are on.

Agnoster needs a Powerline or Nerd Font so the prompt arrows render. Alacritty is set to Inconsolata for Powerline in `config/alacritty/alacritty.toml`. Warp needs a font with the same glyphs.

## Alacritty and tmux

Alacritty is the terminal window. tmux runs inside it and keeps a shell session per project, so closing the window does not stop those shells. Sessions last until you kill them or restart the Mac.

`fresh.sh` symlinks `~/.tmux.conf` and `~/.config/alacritty/alacritty.toml`. tmux comes from the `Brewfile`. The Alacritty Homebrew cask is disabled (it fails macOS Gatekeeper), so the app is installed from the [GitHub release](https://github.com/alacritty/alacritty/releases). If macOS blocks the first open, right-click Alacritty and choose Open, or allow it under System Settings → Privacy & Security.

Alacritty reloads `alacritty.toml` when you save it. tmux reads `.tmux.conf` only when its server starts, so editing the file and opening a new Alacritty window leaves the running server on the old settings. Inside tmux, `Ctrl-a` then `r` sources `~/.tmux.conf` into that server. To start clean, run `tmux kill-server` and open a new session; the next server start loads the file on its own.

### One session per project

A **session** is a project, a **window** is a tab in that project, and a **pane** is a split. The green name on the left of the status bar is the session.

From a project directory, in a new Alacritty window (or after `source ~/.zshrc`):

```bash
tproj
```

That creates a session named after the folder, or switches to it if it already exists. `tproj api` uses an explicit name. `.` and `:` in the name become `-`.

Detach with `Ctrl-a` then `d`, close Alacritty, and come back later with `tproj` in that directory, or `tmux attach`. `Ctrl-a` then `s` lists sessions.

### Keys

The prefix is `Ctrl-a`: press it, release, then the key below. `Ctrl-a` `Ctrl-a` sends a normal `Ctrl-a` to the shell (start of line).

| Keys | Action |
|------|--------|
| `tproj` | Create or switch to this directory's session |
| `Ctrl-a` `s` | List sessions and windows |
| `Ctrl-a` `N` | New session in this directory |
| `Ctrl-a` `$` | Rename the session |
| `Ctrl-a` `c` | New window, same directory |
| `Cmd-1` … `Cmd-9` | Switch to that window (Alacritty only) |
| `Ctrl-a` `n` / `p` | Next / previous window |
| `Ctrl-a` `\|` / `-` | Split side by side / top and bottom |
| `Ctrl-a` `h` `j` `k` `l` | Move between panes |
| `Ctrl-a` `z` | Zoom the current pane |
| `Ctrl-a` `d` | Detach; the session keeps running |

`Cmd-1` through `Cmd-9` type the tmux prefix plus a window number, so use them once a session is open. Scroll with the mouse, or `Ctrl-a` then `[` and vi keys. `y`, or selecting with the mouse, copies to the macOS clipboard.

## diff-so-fancy

[diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) formats unified diffs with clearer headers, word-level highlights, and less noise. It is installed via Homebrew (`Brewfile`) and wired into git when you run `fresh.sh`:

- **`core.pager`** — `git diff`, `git show`, `git log -p`, etc. are piped through diff-so-fancy and `less`.
- **`interactive.diffFilter`** — staged hunks during `git add -p` / `git add -i` use the same styling.

After changing git config, existing shells pick it up automatically; no restart required.

### Git diffs (automatic)

Any normal git diff uses the pager:

```bash
git diff
git diff main -- path/to/file
git show HEAD~1
```

### Two local files (not in git)

diff-so-fancy expects unified diff input. The usual approach is `git diff --no-index`, which compares two paths on disk without needing a repository.

**Shell helper** (defined in `.zshrc`):

```bash
dif file1.js file2.js
```

**Equivalent one-liner:**

```bash
git diff --color --no-index -- file1.js file2.js | diff-so-fancy | less --tabs=4 -RFX
```

`--no-index` tells git to treat the paths as ordinary files. `--` avoids mistaking a path for an option if the filename starts with `-`.

### Without paging

For short compares, drop `less`:

```bash
git diff --color --no-index -- a.txt b.txt | diff-so-fancy
```

### Editor diff

For a side-by-side UI, use your editor instead, e.g. `cursor --diff file1 file2`.

### Manual git pager setup

If you skip `fresh.sh` but already have the brew formula:

```bash
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
```
