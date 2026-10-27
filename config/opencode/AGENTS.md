# Personal

How to work in any repo. A repo `AGENTS.md` adds that project's commands and layout.

## Tools

- Use the package manager the repo already uses. Startflows repos use `pnpm` (`packageManager` is `pnpm@…`, or `preinstall` runs `only-allow pnpm`).
- When asked to commit, run the `commit` subagent. It loads `conventional-commit` and commits the staged changes. Do not load `conventional-commit` in this session.

## Dev servers

If a dev server is already running, leave it running.

## tmux

One session per project. From the project directory, `tproj` creates that session or switches to it. The name is the folder name. `.` and `:` become `-`. Prefix is `Ctrl-a`. Detach with `Ctrl-a` then `d`.

Run project commands in that session.

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
