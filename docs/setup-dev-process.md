# Setup for the dev process

How this machine, these dotfiles, and a Startflows repo are set up so a developer can run [the dev process](dev-process.md).

The process doc is the sessions and the prompts. This doc is the install: which skills are vendored, the local edits those prompts rely on, the files each repo needs, and how to move the pin. The choices below stay settled when the pin moves or another repo is added. Do not reopen the issue tracker, the triage labels, or where design docs live.

Source repo: [mattpocock/skills](https://github.com/mattpocock/skills). The pin is a commit on that repo. As first written, that commit is `5beb35b040e3de97e54fa9e386d7e42d15c295c2` (2026-10-19), which was `main` on that date. Do not track the branch.

## What the process needs from this install

| Process step | What has to be true |
|---|---|
| Interview, `grill-with-docs` | The skill is installed, and `grilling` and `domain-modeling` are on the shared path. The domain-modeling edit keeps terms in the conversation until the design doc exists. |
| `research` | Installed for OpenCode only. The prompt names the evidence path. The skill writes through a background agent. |
| `prototype` | Installed for OpenCode only, and patched so the throwaway does not edit product code or commit. |
| `critique-design` | The agent in `config/opencode/agents/critique-design.md` is unchanged, including `skill: deny`. The session selects a frontier model. The agent file does not pin one. |
| One blocker, then the plan | A normal OpenCode session can edit. `plan-from-design` is installed. Plan mode is on. |
| `implement` | Patched so one plan step is the whole task, the seam is already confirmed, a repo with no test suite does not gain one, and the session does not commit. It calls shared `tdd` and `code-review`. |
| `code-review` | Patched so the spec is the design doc plus the plan step, the fixed point can be "the commit this step branched from", and the diff includes uncommitted work. The session can spawn sub-agents. The repo `AGENTS.md` block is present, so the skill can see the tracker. |
| `retro` | Installed for OpenCode only, with `writing-for-agents` beside it. The session presents candidates and edits a file only after you accept that candidate. |
| Cursor, via `handoff` | `handoff` writes `$TMPDIR`. The Cursor user rule below is installed. Shared skills include `codebase-design`, `grill-me`, `diagnosing-bugs`, and `code-review`. |

## Decisions

- Personal skills only. Do not copy these skills into any Startflows repo's `.agents/skills/`, and do not add them to `scripts/install-skills.sh`. A repo copy overrides the personal skill of the same name.
- Do not run `npx skills add`. Copy the skill directories from the pinned commit into the dotfiles paths below.
- Do not run `npx skills update`. It follows a skills.sh install, overwrites the local patches, and does not know which skills are OpenCode-only. There is no per-skill version. The version is the pinned commit. Upstream `CHANGELOG.md` is what you read when checking what moved.
- Record the pin, the upstream path of each copied skill, and the local patches under `vendor/mattpocock/`. The copies the agents load stay patched. The patch files are what get re-applied when the pin moves. A skill update is a dotfiles change. Do not add a submodule of mattpocock/skills to a Startflows repo.
- OpenCode-only skills go in `config/opencode/skills/<name>/`, which `fresh.sh` links to `~/.config/opencode/skills`.
- Skills both tools should see go in `skills/<name>/`, which `fresh.sh` links to `~/.agents/skills`.
- `fresh.sh` links those two directories, not each skill. A new skill directory is visible on the next session once the symlink is in place. Re-run `fresh.sh` when `~/.config/opencode/skills` or `~/.agents/skills` is missing. If either path is a real directory, `fresh.sh` leaves it alone, prints a warning, and the vendored copies stay hidden. Move that directory aside, then re-run `fresh.sh`. The same warning is printed for `~/.config/opencode/agents`.
- `config/opencode/agents/critique-design.md` stays as it is, including `skill: deny`. `fresh.sh` links `config/opencode/agents` to `~/.config/opencode/agents`.
- The design doc remains the spec. Do not install or invoke `to-spec`. A second spec would drop the current-state paths the design doc is for.
- Do not install `ask-matt`, `setup-matt-pocock-skills`, `pr`, `implement-spec`, `wayfinder`, `triage`, `to-tickets`, `to-questionnaire`, `teach`, `wizard`, `wait-what`, anything under `skills/misc/`, `skills/deprecated/`, or `skills/in-progress/`. `ask-matt` is the upstream router. The process doc is the router. `pr` is not a step. The existing pull-request rule sets the body.
- Do not create a root `GLOSSARY.md` by mining `docs/design/`. Terms stay defined in the canonical design doc. A glossary, when a session coins a term the docs do not define, is an index of pointers.
- Do not extract existing numbered decisions out of design docs into `docs/adr/`.
- `implement` must not commit. Repo `AGENTS.md` files already forbid committing unless asked.
- Single-context domain layout in every repo, including `base` and `startflows`, including when the repo has a workspace file.
- The first configuration of a repo is written from this doc. Do not install or run `setup-matt-pocock-skills`. That skill proposes GitHub issues when `git remote` points at GitHub, and it will offer to replace `docs/agents/`.

## Machine

`~/.zshrc` already exports `OPENCODE_EXPERIMENTAL_PLAN_MODE=1`. Confirm that one line. Do not add a second export. `fresh.sh` symlinks that file. A shell started after that sees plan mode. Step 7 of the process is an OpenCode session in plan mode. Start OpenCode from a shell that has read `~/.zshrc`. An app launched from the Dock does not read `.zshrc`, so plan mode stays off there.

Plan mode is the session switch. `plan-from-design` is what writes `.opencode/plans/<slug>.md` in the shape below. A plan the harness writes at any other path is not the plan the process builds from.

Cursor does not read `config/opencode/AGENTS.md`. The user rule text is `config/cursor/dev-process-user-rule.txt`. Paste that file by hand in Cursor Settings → Rules → User rules. This repo cannot symlink it. A new machine needs the same paste.

## Skill placement

Copy each directory from `skills/engineering/<name>/` or `skills/productivity/<name>/` at the pinned commit. Keep `SKILL.md`, the sibling markdown and scripts, and `agents/openai.yaml`. That file is Codex metadata. It stays in the copy. `config/opencode/skills/.gitkeep` can stay.

A skill that calls another by name fails when that skill is not loaded. OpenCode loads both directories. Cursor loads `~/.agents/skills` only.

| Caller | Loads |
|---|---|
| `grill-with-docs` | `grilling`, `domain-modeling` |
| `grill-me` | `grilling` |
| `implement` | `tdd`, `code-review`. On a commit, the `commit` subagent, which loads `conventional-commit`. |
| `tdd` | `codebase-design`, when the shape of the interface is in question |
| `improve-codebase-architecture` | `codebase-design`, `grilling`, `domain-modeling` |
| `retro` | `writing-for-agents` |
| `code-review` | two sub-agents, not skills |

`grilling` and `domain-modeling` sit in the shared directory. `writing-for-agents` sits next to `retro`. `code-review` runs in a normal session. `critique-design` denies sub-agents, so that agent cannot run the review.

### OpenCode only — `config/opencode/skills/`

| Skill | Role |
|---|---|
| `grill-with-docs` | Interview at the start of a design. Unchanged from upstream. It only calls the two shared skills. |
| `research` | Primary-source notes during design. Model-invoked, so it stays out of Cursor. It spins up a background agent and writes the note at the path in the prompt. Wait until that file is on disk before a later session treats it as evidence. |
| `prototype` | A throwaway during design. Patched so it does not edit product code, write the design doc, or commit. |
| `improve-codebase-architecture` | Survey. The report is HTML in `$TMPDIR`. The skill then asks which candidate to grill and can edit `GLOSSARY.md`. The process prompt stops after the report. The refactor is a later Cursor session with `codebase-design`. Leave that second half in the file. |
| `retro` | After a finished build. It calls `writing-for-agents`, then proposes environment changes and waits. Unchanged. The process prompt is what keeps the design doc, the plan, the tracker, and the triage labels as they are. |
| `writing-for-agents` | Style guide `retro` calls. Not a step on its own. |
| `handoff` | The note that carries a step into Cursor. Upstream writes `$TMPDIR` (else `/tmp`). Unchanged. |
| `implement` | One plan step. Patched below. |
| `plan-from-design` | Local. Not in the upstream repo. Body below. |
| `conventional-commit` | Commit messages. The `commit` subagent loads it. The parent session does not. Copied from [jkappers/agent-skills](https://github.com/jkappers/agent-skills) `skills/conventional-commit` at `9fce9393c3af5c062b367bf8fd17994939257436`. Not in `paths.txt`. Cursor does not load this directory. |

### Both tools — `skills/`

| Skill | Role |
|---|---|
| `grilling` | Interview primitive used by `grill-with-docs` and `grill-me`. Unchanged. |
| `grill-me` | Interview in Cursor when an interface is still open. It does not write the design doc. Unchanged. |
| `domain-modeling` | Patched below. |
| `tdd` | Red-green at a seam the plan already names. Unchanged. It still says to confirm the seam. `implement` tells it the plan seam is that confirmation. In Cursor, with no plan, confirming the seam is the skill working as written. |
| `codebase-design` | Vocabulary for a refactor the user is steering in Cursor. Unchanged. |
| `diagnosing-bugs` | A hard bug in either tool. Unchanged. |
| `code-review` | After a step, against the design doc. Patched below. |

## Vendoring

The copies live in the skill directories above. `vendor/mattpocock/` is how a later session sees what changed, and how it moves the pin without `npx skills`. `check.sh` only reports. `update.sh` copies skills into this repo when you run it. Nothing in that directory runs on its own.

### `vendor/mattpocock/PIN`

One line, the full commit SHA. A branch name in this file will not match the next diff.

```text
5beb35b040e3de97e54fa9e386d7e42d15c295c2
```

### `vendor/mattpocock/paths.txt`

Two columns, upstream path then dotfiles path. One skill per line. End the file with a newline. `plan-from-design` and `conventional-commit` are absent, so an update does not touch them. The repo `docs/agents/` files are written from this doc, so an upstream tracker skill is not on this list.

```text
skills/engineering/grill-with-docs config/opencode/skills/grill-with-docs
skills/engineering/research config/opencode/skills/research
skills/engineering/prototype config/opencode/skills/prototype
skills/engineering/improve-codebase-architecture config/opencode/skills/improve-codebase-architecture
skills/engineering/retro config/opencode/skills/retro
skills/productivity/writing-for-agents config/opencode/skills/writing-for-agents
skills/productivity/handoff config/opencode/skills/handoff
skills/engineering/implement config/opencode/skills/implement
skills/productivity/grilling skills/grilling
skills/productivity/grill-me skills/grill-me
skills/engineering/domain-modeling skills/domain-modeling
skills/engineering/tdd skills/tdd
skills/engineering/codebase-design skills/codebase-design
skills/engineering/diagnosing-bugs skills/diagnosing-bugs
skills/engineering/code-review skills/code-review
```

### `vendor/mattpocock/patches/`

One unified diff per edited skill, against the upstream file at the pin. The file the agent loads is the patched copy. `plan-from-design` and `conventional-commit` have no patch.

- `implement.patch`
- `domain-modeling.patch`
- `code-review.patch`
- `prototype.patch`

Each diff uses the dotfiles-relative path in both headers, with an `a/` and `b/` prefix:

```text
--- a/skills/domain-modeling/SKILL.md
+++ b/skills/domain-modeling/SKILL.md
```

`git apply` from a tree root that contains that path applies it. `git apply` is stricter than `patch` and does not prompt. A hunk that does not match is a failed update.

Rebuild a patch from a clean staged tree and the edited copy. Both trees use the destination paths from `paths.txt`. The labels use that same destination path.

```sh
diff -u \
  --label a/skills/domain-modeling/SKILL.md \
  --label b/skills/domain-modeling/SKILL.md \
  "$clean/skills/domain-modeling/SKILL.md" \
  "$edited/skills/domain-modeling/SKILL.md" \
  > vendor/mattpocock/patches/domain-modeling.patch
```

`$clean` is the tree from `update.sh --stage`. `$edited` is the copy you changed. Use the destination path from `paths.txt` in the labels and in both file arguments.

### `vendor/mattpocock/check.sh`

Executable. It asks GitHub for the tip of `main`, then prints that commit, the commits that touched `CHANGELOG.md` since `PIN`, and a stat diff of the upstream paths in `paths.txt`. Read the changelog before the diff. It does not copy files or move the pin.

One bare clone is kept at `~/.cache/dotfiles/mattpocock-skills.git` (`$XDG_CACHE_HOME` when that is set). The script clones that cache when it is missing, and fetches `main` only when the cached tip differs from GitHub. It reads `refs/heads/main` from the cache. `update.sh` uses the same cache.

```sh
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
```

A missing upstream path in that diff means the skill moved or was removed. Update that line of `paths.txt` from the tree at `$tip` before copying. Do not rediscover it with `npx skills`.

The first install records the pin and does not need this script. Run it when you want to know whether `main` has moved.

### `vendor/mattpocock/update.sh`

Executable. It uses the same cache as `check.sh`. A full history is what makes a SHA that is not today's `main` resolve. The script copies each upstream directory unchanged, including `agents/openai.yaml`.

```sh
vendor/mattpocock/update.sh <sha>
vendor/mattpocock/update.sh --stage <sha> <dest>
vendor/mattpocock/update.sh --install <tree> <sha>
```

`<sha>` with no flag stages a clean tree, applies every file in `vendor/mattpocock/patches/` with `git apply`, and stops at the first failure. `set -eu` is on. A failed patch leaves the live skill directories and `PIN` as they were. The throwaway tree is deleted. When every patch applies, the script copies that tree over the live destinations, then writes `PIN`.

`--stage` writes a clean tree at `<dest>` and stops. `<dest>` must not already exist. It does not apply patches and does not change the repo.

`--install` copies `<tree>` into the live destinations and then writes `PIN`. It does not apply patches. The first install uses this on the edited tree.

After a successful copy, a destination under `skills/` or `config/opencode/skills/` that is no longer listed in `paths.txt` is removed. The script never removes `skills/release-notes`, `config/opencode/skills/plan-from-design`, `config/opencode/skills/conventional-commit`, or `config/opencode/skills/.gitkeep`.

A failure during the copy can leave a mix of old and new skill directories while `PIN` still names the previous commit. Restore those directories from git.

### First install

The patch files do not exist yet, so `update.sh <sha>` would stop before copying. Stage a clean tree, edit a second copy, write the patches from those two trees, then install the edited copy. Do not run `git apply` on the edited tree.

`vendor/mattpocock/PIN` and `vendor/mattpocock/paths.txt` are already filled in. The SHA is the line in `PIN`.

1. Stage a clean tree and copy it. This uses the same cache and `paths.txt` loop as a pin move.

```sh
sha=$(tr -d '[:space:]' < vendor/mattpocock/PIN)
work=$(mktemp -d)
vendor/mattpocock/update.sh --stage "$sha" "$work/clean"
cp -R "$work/clean" "$work/edited"
clean=$work/clean
edited=$work/edited
```

2. Edit the four skills under `$edited` until they match the intents below. Leave every other skill as the clean copy.

3. Write each patch with `diff -u`, as in the patch section. The first file is the clean tree. The second is the edited tree.

4. Copy the edited tree into this repo and write the pin.

```sh
vendor/mattpocock/update.sh --install "$edited" "$sha"
rm -rf "$work"
```

5. Add `plan-from-design`, the OpenCode section, and the files in `/Users/graeme/Projects/startflows/base`. Those are not in the upstream repo. Paste `config/cursor/dev-process-user-rule.txt` into Cursor user rules. Start OpenCode from a shell that has read `~/.zshrc`.

### Move the pin

Latest means the `main is` SHA from `check.sh`. You can pin an older commit from that range instead. Write a full SHA either way. Do this in a terminal. The dotfiles checkout stays on the old pin until every patch applies.

1. Run `vendor/mattpocock/check.sh`. Read the changelog commits, then the stat diff.
2. Run `vendor/mattpocock/update.sh <sha>`. The script stages a clean tree, applies every patch, and writes `PIN` only after every patch applies.
3. When a patch fails, the repo is unchanged. Read the new upstream skill against the intent in this doc. Rebuild that one patch with `diff -u` from a clean `--stage` tree and an edited copy. Run `vendor/mattpocock/update.sh <sha>` again. It restages a clean tree and applies every patch from the start. Do not apply the new patch onto a tree that already has patches applied. Do not hand-merge the reject into the live skill directory. Do not change the process prompts to fit an upstream skill. The prompts are the contract these patches keep.
4. Leave each Startflows repo's `docs/agents/` files as this doc wrote them. Commit the pin, the recopied skills, and any rebuilt patches in the dotfiles repo when you are ready to record the update.

To undo a bad copy before that commit, restore the skill directories and `PIN` from git.

## Patch intents

These are the edits the patch files must produce. After a failed apply, rebuild the patch to this intent.

### `implement`

Replace the body of `config/opencode/skills/implement/SKILL.md`. Leave the frontmatter. The upstream body fetches a ticket, asks `tdd` to confirm a seam, runs a full test suite, and commits. None of that matches the process.

```markdown
The user will point at one step in `.opencode/plans/<slug>.md` and at a design doc under `docs/design/`. The step is the title they name, or the first step whose `Status` is `open`. Implement that step only. The design doc is the spec. The plan step names the seam. A plan path and a step title are not a ticket reference. Do not fetch a GitHub or GitLab issue, and do not read `.scratch/`. If the step contradicts the design doc, stop and do not edit code. Do not edit the design doc. Do not take the next step. When the step is finished, set its `Status` line to `done` and leave every other line of the plan unchanged. If there is no plan and the user says the accepted doc fits one session, build from the doc and do not write a plan.

The seam on that step is already confirmed. Do not ask the user to confirm it again. That overrides the confirm-the-seam step in `tdd`. Call the Skill tool with "tdd" at that seam. When the step says there is no new seam, or the repo has no test suite, do not invent tests and do not run a suite that is not there. `admin-portal` and `starters-preview` have no test suite.

The repo `AGENTS.md` names the lint and typecheck commands. Run those.

Once done, call the Skill tool with "code-review". The fixed point is the commit this step branched from. The diff includes uncommitted work.

Do not commit, push, amend, or open a pull request. The user commits in a separate step. When they ask to commit, run the `commit` subagent. Do not load `conventional-commit` in this session.
```

### `domain-modeling`

Upstream tells the session to create `GLOSSARY.md` and `docs/adr/` as soon as a term or a decision settles, and to write a full definition. During the interview the design doc does not exist yet, so that would become a second spec. In `skills/domain-modeling/SKILL.md`:

Replace the lazy-create paragraph with:

```markdown
Do not create `GLOSSARY.md` or `docs/adr/` while the design doc for this work is still unwritten. Hold new terms in the conversation until that doc exists. Once it exists, create `GLOSSARY.md` only for a term the docs do not define, and create `docs/adr/` only for a decision that is not part of a design doc.
```

Replace the "Update GLOSSARY.md inline" section with:

```markdown
### Glossary entries are pointers

Canonical definitions live in `docs/design/`. When a term is resolved and a design doc already defines it, use that definition. Do not copy it into `GLOSSARY.md`.

When a design doc defines the term, a `GLOSSARY.md` entry is the term, one line, and a link to that section. Write a full definition, in the format of [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md), only when no design doc defines the term. `GLOSSARY.md` stays free of implementation detail. It is not a second spec.
```

Under "Offer ADRs sparingly", after the three conditions, add:

```markdown
A decision that belongs to a design under `docs/design/` is recorded in that design doc, not in `docs/adr/`.
```

Leave `GLOSSARY-FORMAT.md` and `ADR-FORMAT.md` unchanged. Do not append a second copy of these rules.

### `code-review`

Upstream reviews `git diff <fixed-point>...HEAD`, which is commits only, and it asks for a ref when the phrase does not resolve. The process reviews the step before the commit, and the prompt's fixed point is a phrase. The skill also stops until it can see an issue tracker. The per-repo `AGENTS.md` block below is that tracker. In `skills/code-review/SKILL.md`, add this at the end of "Pin the fixed point":

```markdown
When the user describes the fixed point as the commit this step branched from and does not give a ref, resolve it with `git merge-base HEAD origin/main` if `origin/main` exists, otherwise `git merge-base HEAD main`. Do not ask them to restate it.

The review covers uncommitted work. Use `git diff <fixed-point>` so the index and the working tree are included. `git diff <fixed-point>...HEAD` misses an uncommitted step. A clean commit range with a dirty worktree is still a review. Fail for an empty diff only when both that command and `git status --porcelain` are empty.
```

Under "Identify the spec source", add:

```markdown
In these repos the spec is the design doc the user names under `docs/design/`, plus the plan step they name under `.opencode/plans/`. Prefer that path over an issue number in a commit message. Do not ask for a GitHub issue when the user has given a design doc path.
```

### `prototype`

Upstream rule 6 folds the result into product code and commits a throwaway branch. Replace that rule in `config/opencode/skills/prototype/SKILL.md` with:

```markdown
6. **Leave the product tree alone.** Do not edit product code, do not write a design doc, and do not commit, push, or open a pull request. Put the prototype outside the product modules, in a temp directory or a scratch file the user named. The validated answer stays in the conversation until the design doc is written.
```

Leave the logic-versus-UI branch choice as it is.

## New skill `plan-from-design`

Create `config/opencode/skills/plan-from-design/SKILL.md`:

```markdown
---
name: plan-from-design
description: Turn an accepted design doc into one OpenCode plan of vertical slices. Use when the user asks for a plan from a docs/design file, or names .opencode/plans.
disable-model-invocation: true
---

# Plan from design

Write one plan file. The design doc is already accepted. Do not interview. Do not edit the design doc, any glossary, or any code.

## Inputs

The user names the design doc under `docs/design/` and the plan path under `.opencode/plans/<slug>.md`. If either is missing, ask once, then stop.

Read the design doc and any parent it links as canonical. Read `GLOSSARY.md` if it exists. Use those terms in step titles.

If the accepted doc fits in one fresh session, do not write a plan. Say so and stop.

## Slices

Break the design into tracer bullets:

- Each slice is a narrow, complete path. A finished slice is verifiable on its own.
- Each slice fits in one fresh context window.
- Prefactoring is its own earlier slice.
- Each slice lists the slices that block it.
- Each slice names the seam and the tests, or states that this repo has no test suite and this slice adds no seam.
- A wide mechanical change is expand, then migrate, then contract. Do not force it into one tracer bullet.

`admin-portal` and `starters-preview` have no test suite. A slice there states "no new seam".

## Write the plan

Write only `.opencode/plans/<slug>.md`. Create the directory if needed. Match this shape:

- Title
- `Spec:` the design doc path
- `Seam:` the seam for the whole change, in a few lines
- Numbered steps. Each step has a title, `Status: open`, `Blocked by`, `Delivers` (behaviour, not a file list), and `Seam`. The title is the identity of the step. `Blocked by` cites step numbers.

Do not copy the design doc into the plan. Do not put a call-site map in the plan. Cite the design doc instead.

When you revise an existing plan, update `Blocked by` numbers in that same edit. Leave any `Status: done` line as it is. The only later edit to a step is its status line, made by `implement` when the step is finished.

Show the breakdown and wait for the user to accept it before you write the file. After it is written, stop. Do not implement.
```

## Personal OpenCode instructions

If `config/opencode/AGENTS.md` has no `## Design and build` heading, append this block. If that heading is already there, replace that section in place, from the heading through the line before the next `##` heading, or through the end of the file. Do not remove the tools, dev server, or tmux sections.

```markdown
## Design and build

Design docs under `docs/design/` are the spec. Plans under `.opencode/plans/<slug>.md` are the build order. `critique-design` is the acceptance gate. Do not load that agent's instructions in any other session.

- While a design is still open, `grill-with-docs` may sharpen it. Hold new terms in the conversation until the design doc exists. `research` writes a cited note at the path in the prompt and does not edit the design doc unless asked. The note is written by its background agent. Wait until the file is on disk before treating it as evidence.
- `prototype` answers one question with throwaway code. It does not edit product code, write the design doc, or commit.
- `plan-from-design` writes the plan from an accepted design doc and leaves the rest of the repo unchanged. When the doc fits one session, it writes no plan. Run that session in plan mode.
- `implement` builds the step the user names, or the first step whose `Status` is `open`, at the seam that step names, then runs `code-review` on the uncommitted diff. When the step is finished it sets that line to `done` and leaves the rest of the plan unchanged. If the step contradicts the design doc, it stops. It does not commit.
- `handoff` is how a step moves to Cursor. The next session is user-driven. The file is in `$TMPDIR`.
- `improve-codebase-architecture` writes the HTML report and stops when the prompt says to stop. The refactor of a chosen candidate is a Cursor session.
- `retro` runs when a build is finished. It proposes changes to the agent environment and edits a file only after you accept that candidate. It does not edit the design doc or the plan.
- Do not run `ask-matt`, `setup-matt-pocock-skills`, `to-spec`, `implement-spec`, `wayfinder`, `to-tickets`, or `triage`. Follow `docs/dev-process.md`.
```

## Cursor user rule

Paste `config/cursor/dev-process-user-rule.txt` into Cursor Settings → Rules → User rules. Cursor does not read `config/opencode/AGENTS.md`, and this repo cannot symlink a user rule. That file is the text you paste. A new machine needs the same paste.

## Per repo

Write these files in the Startflows repo, not in this dotfiles repo. The first repo is `/Users/graeme/Projects/startflows/base`. Then:

- `/Users/graeme/Projects/startflows/startflows`
- `/Users/graeme/Projects/startflows/admin-portal`
- `/Users/graeme/Projects/startflows/starters-preview`

`base` has `## Skills` and `## OpenCode`. It has no `## Agent skills` section and no `docs/agents/` files. Leave `## Skills` and `## OpenCode` as they are. `## Skills` is the repo's own skills (`cloudflare`, `vue`, and the rest) and the `pnpm run install:skills` install. The OpenCode paragraph stays: plan mode writes `.opencode/plans/<slug>.md` and leaves the rest of the repo unchanged. Build implements that file.

These repos have `AGENTS.md` and no `CLAUDE.md`. Add the block below at the end of `AGENTS.md`. If an `## Agent skills` section already exists, replace that section in place, from its heading through the line before the next `##` heading, or through the end of the file. Do not fold it into `## Skills`. The two `docs/agents/` files below are written in that Startflows repo. Write each one when it is missing, and replace it when its contents differ.

A later repo uses the same rule. Keep single-context even when a workspace file is present. Do not install or run `setup-matt-pocock-skills`. Do not copy these skills into the repo.

```markdown
## Agent skills

### Issue tracker

There is no GitHub or GitLab issue queue for this loop. The spec is the design doc under `docs/design/` that the user names. The plan is `.opencode/plans/<slug>.md`. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context. Terms are defined in `docs/design/`. `GLOSSARY.md` is an index of pointers when it exists. See `docs/agents/domain.md`.
```

There is no `### Triage labels` sub-block. `triage` is not installed. Do not write `docs/agents/triage-labels.md`. Do not create GitHub labels.

Write `docs/agents/issue-tracker.md`:

```markdown
# Issue tracker

Plans and specs for agent sessions are files in this repo.

- The spec is the design doc the user names under `docs/design/`. Do not publish a second spec. Do not call `gh issue` or `glab issue` for this loop.
- When a skill says to fetch a ticket or publish to the tracker, read or edit the design doc and the plan step the user named. There is no `.scratch/` issue directory for this loop.
- The plan is one file, `.opencode/plans/<slug>.md`, written by `plan-from-design` during plan mode. One step is one fresh implementation session. Each step starts `Status: open`. The session that finishes the step sets that line to `done` and leaves the rest of the plan unchanged. An accepted design doc that fits one session has no plan.
- A follow-up under `docs/design/**/follow-ups/` is not a plan. It becomes a plan only after the user accepts it.
- Changesets and `docs/releases/` record a user-facing release. They are not the plan.
```

Write `docs/agents/domain.md`:

```markdown
# Domain docs

## Before exploring, read these

- The design doc the user names, and the canonical parents it links.
- `GLOSSARY.md` at the repo root, if it exists. It points at definitions. It is not a second definition.
- `docs/adr/`, if it exists, for decisions that are not already in a design doc.

If a file is missing, proceed. Do not create a glossary or an ADR up front. Do not create either while the design doc for this work is still unwritten.

## Use the design doc's vocabulary

When an output names a domain concept, use the term as the design doc defines it.

## Flag conflicts

If an output contradicts a canonical design doc or an ADR, say so in the output. Do not silently override it.
```

Do not create `GLOSSARY.md` or `docs/adr/` in this change.

## Docs to leave alone

- `docs/design/**`, including canonical docs, follow-ups, archive, and evidence.
- `config/opencode/agents/critique-design.md` and `config/opencode/agents/commit.md`.
- Repo `skills/` trees and `scripts/install-skills.sh`.
- The release-notes skill. `conventional-commit` stays in `config/opencode/skills/`. Do not add it to a repo `scripts/install-skills.sh`. A copy under that repo's `.agents/skills/` overrides the user skill.
- Changeset and release-notes rules in each `AGENTS.md`.
- The repo `## Skills` section.

## Limits that remain

- `research` returns through a background agent. The evidence file can land after the parent session has already replied.
- `improve-codebase-architecture` keeps a grilling loop after the report. The process prompt is what stops the survey session.
- `tdd` still contains a confirm-the-seam step. `implement` overrides it for a plan step. A Cursor session with no plan still confirms the seam.
- `code-review` spawns two sub-agents. The implement session and the Cursor review session have to be allowed to do that.
- `retro` still looks at global steering files and `CODING_STANDARDS.md`. The process prompt is what keeps the design doc, the plan, the tracker, and the triage labels unchanged.
- Plan mode follows `OPENCODE_EXPERIMENTAL_PLAN_MODE` from the shell that started OpenCode.
- The Cursor user rule is machine-local. This repo cannot symlink it.

## Done when

- The OpenCode-only skills and the shared skills are in the dotfiles paths, at the pinned commit, with the four patches and `plan-from-design` applied.
- `vendor/mattpocock/PIN`, `vendor/mattpocock/paths.txt`, `vendor/mattpocock/check.sh`, `vendor/mattpocock/update.sh`, and the four patch files exist.
- `ls -ld ~/.config/opencode/skills ~/.agents/skills ~/.config/opencode/agents` shows each path is a symlink into this repo.
- `config/opencode/skills/implement/SKILL.md` contains "Do not commit, push, amend, or open a pull request." `skills/domain-modeling/SKILL.md` contains "Do not create `GLOSSARY.md` or `docs/adr/` while the design doc for this work is still unwritten." `skills/code-review/SKILL.md` contains "The review covers uncommitted work." `config/opencode/skills/prototype/SKILL.md` contains "Leave the product tree alone."
- `config/opencode/AGENTS.md` contains the Design and build section once.
- Each Startflows repo that runs the process has the `## Agent skills` block once, `docs/agents/issue-tracker.md`, and `docs/agents/domain.md`, and still has its `## Skills` section. `/Users/graeme/Projects/startflows/base/AGENTS.md` is the first of those.
- No skill from this setup is under a repo's `.agents/skills/`.
- `critique-design` is unchanged.
- `config/cursor/dev-process-user-rule.txt` has been pasted into Cursor user rules.
- A later update ran `vendor/mattpocock/update.sh`, which writes `PIN` only after every patch applies.
