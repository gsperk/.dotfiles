---
name: release-notes
description: Draft the next Startflows stable release notes file from pending changesets. Use when the user asks to draft release notes, cut a release, or write docs/releases, and the repo has pnpm release:next-version and docs/releases/.
---

# Release notes

Create `docs/releases/<version>.md` for the next stable release. Layout and tone come from `docs/releases/TEMPLATE.md` and the newest `docs/releases/*.md`. Timing and branch rules are in `docs/releases/README.md`.

Write the file on `integration`, while `.changeset/*.md` files still exist. `pnpm release:version` deletes them. Do not commit unless the user asks.

## Steps

1. From the repo root, run:

   ```bash
   pnpm release:next-version
   ```

   Pass `--date=YYYYMMDD` only when the user names a cut date and the script accepts `--date`.

2. If the script prints `No pending changesets.`, stop and say so.

3. Take the version, notes path, and highest bump (`patch`, `minor`, or `major`) from the script output. Use those values as printed. Do not recompute the version.

4. Read each pending `.changeset/*.md` except `.changeset/README.md`. Use the script's per-file summary when it is enough. Ignore the package list in changeset frontmatter. Use the bump type and the summary below the second `---`.

5. Write the file. Match the newest `docs/releases/*.md` for the title, the opening line, and the heading level. If that file has an H1, use the same shape with the new version. If it starts with the blockquote, do not add an H1. Merge and dedupe when several changesets describe the same change. Polish vague summaries. Do not invent changes the summaries do not imply.

## Sections

Always include **⚠️ Breaking changes**. Use `- None` when there are none. Omit every other empty section.

| Changeset bump / summary | Section |
|---|---|
| `major`, or an explicit breaking change | ⚠️ Breaking changes |
| `minor`, or a new capability | 🚀 Features |
| `patch` bugfix | 🩹 Fixes |
| refactor | 💅 Refactors |
| docs | 📖 Documentation |
| chore, build, ci, deps | 🏡 Chore |

Headings, in this order when present: ⚠️ Breaking changes, 🚀 Features, 🩹 Fixes, 💅 Refactors, 📖 Documentation, 🏡 Chore.

Bullets use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) scope, Nuxt-style:

```markdown
- **scope:** description
```

Do not list every package in a fixed group unless that helps the reader.

## Checklist

- Filename is the path the script printed
- Title and opening line match the newest `docs/releases/*.md`
- Opening line uses the highest bump (`patch`, `minor`, or `major`)
- Breaking section is present; other empty sections are omitted
- Bullets are `- **scope:** description`
- File is ready to commit on `integration` before `integration` → `release`
