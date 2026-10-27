# Dev process

How to move an open question into a design doc, then into code. OpenCode does the interview, the research, the critique, the plan, the build, and the retro. Cursor is where you sit and steer a modification or a refactor.

The design doc under `docs/design/` stays the contract. The plan under `.opencode/plans/` is the build order. Each step starts `open`, and the session that finishes it sets that line to `done`. A critique blocker becomes a doc edit only after a separate session agrees with it.

## Which tool

| Work | Tool |
|---|---|
| Interview an open design | OpenCode, `grill-with-docs` |
| Check a claim against a primary source | OpenCode, `research` |
| Throw away a prototype during design | OpenCode, `prototype` |
| Critique a design doc | OpenCode, `critique-design`, on a frontier model |
| Accept or reject each critique blocker | OpenCode, one fresh session per blocker |
| Write the plan | OpenCode, plan mode, `plan-from-design` |
| Implement a plan step | OpenCode, `implement`, one fresh session per step |
| Review the diff before you ask for a commit | Either tool, `code-review` |
| When the build is finished, improve the environment | OpenCode, `retro` |
| A change you want to steer yourself | Cursor, via `handoff` |
| A refactor of a module you are sitting in | Cursor, `codebase-design` |
| An interface that is still open while you steer | Cursor, `grill-me` |
| A hard bug while you are in Cursor | Cursor, `diagnosing-bugs` |

Switch from OpenCode to Cursor with `handoff`. The handoff file is in `$TMPDIR`. Open that path in the Cursor session.

## This walkthrough

The specimen is account images in `base`. Steps 1–4 are the sessions that produce the design doc. That file is already written; the prompts are the path that leads to it. From step 5 the doc is the spec, and the prompts are the next sessions.

| Artefact | Path |
|---|---|
| Design doc, written at step 4 | `docs/design/assets/account-images.md` |
| Plan the skill writes at step 7 | `.opencode/plans/account-images.md` |
| Handoff, only if you move a step to Cursor | `$TMPDIR/handoff-account-images.md` |

Each step below has the same shape: what the session is for, which skills it loads, and the prompt you paste. One session per step, except where the step says a later sitting of the same interview is fine.

## 1. Interview the open design

**Summary.** Start from today's behavior and the change you want. The session interviews you, names terms, and holds the decisions. It does not write the design doc yet.

**Skills.** `grill-with-docs`, which calls `grilling` and `domain-modeling`.

**Where.** OpenCode, new session, repo `base`.

```text
/grill-with-docs

I want a design for account images.

Today the images worker at src/endpoints/images reads {accountId}/{key} from the account images bucket and caches the response. The key is a filename stored on the subject (contexts.avatar_url, collect_sites.logo_url, split_sites.logo_url). The browser asks the app's GET /api/images to sign that filename.

I want those filename columns gone, and one upload path for every image kind. The images worker stays. Read these before you interview me:

- docs/design/files/flow-files.md
- docs/design/files/file-promoter.md

Interview me. Use the terms already defined in those docs. Do not write the design doc until I say the decisions have settled. Do not write a plan. Do not edit code.
```

A later sitting, when the context is spent and the doc still does not exist. Carry the settled points in the prompt. A new session does not remember the last one.

```text
/grill-with-docs

Continue the account-images interview. The design doc is not written yet.

Settled so far: the subject stores an asset id, a read that expands the image field signs {ownerId}/{assetId}, and one upload session serves every image kind. Staging reuses the flow-file upload bucket. The flow-file promoter allowlist stays unchanged.

Still open: who may upload a context icon, and where the image destination check lives. Parents: docs/design/files/flow-files.md and docs/design/files/file-promoter.md.

Do not write the design doc yet. Do not write a plan. Do not edit code.
```

## 2. Check a claim against a primary source

**Summary.** Take this step when a decision depends on a source outside the repo. Reading `src/endpoints/images` belongs in the interview. This step writes a cited note and leaves the design doc alone.

**Skills.** `research`.

**Where.** OpenCode, new session, during the interview and before step 4.

```text
/research

The account-images design wants a signed image URL whose MAC covers the path and the expiry, so the client can change w, h, fit, and f and request the images worker again.

Does Cloudflare's Cache API, for caches.default, key the full request URL including those query parameters? Use Cloudflare's docs. Write a cited note at docs/design/assets/evidence/. Do not edit a design doc. Do not edit code.
```

## 3. Prototype a decision you cannot settle on paper

**Summary.** Take this step when you need to see a behavior before you will lock it. The prototype is throwaway. Skip the step when the interview can already name the behavior.

**Skills.** `prototype`.

**Where.** OpenCode, new session, before step 4.

```text
/prototype

Question: after a context-icon upload completes, is the signed URL on the complete response enough for the team switcher, with no further expand and no call to GET /api/images?

Look at the admin portal team switcher (TeamPopPnl.vue, TeamPopLayer.vue) and at FileUploadCtrl.vue only to copy the pick-or-drop shape. Build a throwaway. Do not edit product code. Do not write the design doc.
```

## 4. Write the design doc

**Summary.** The decisions have settled. This session writes the living design and stops. This is the file that already exists at `docs/design/assets/account-images.md`.

**Skills.** `grill-with-docs` if this is still the interview session. A fresh session with no skill is enough when you are only recording settled decisions.

**Where.** OpenCode, the interview session if its context is still good, otherwise a new session in `base`.

```text
The account-images interview has settled. Write the living design at docs/design/assets/account-images.md.

Record the decision, the read path, the operator write, subjects, the assets catalog, upload staging, the object key and cache, authorization, the HTTP sketch, layers, and the UI. Leave the open questions in "Still to decide". Point at docs/design/files/flow-files.md and docs/design/files/file-promoter.md where this design reuses them.

Match the shape of docs/design/files/flow-files.md: a dated living design, a decision section, and an explicit outside-this-design list. File paths and call sites belong in this doc.

Do not write a plan. Do not edit code.
```

The doc is the contract from here on. Later sessions point at the path. They do not replay the interview.

## 5. Critique the design doc

**Summary.** An independent pass over the written doc. It returns a verdict, blockers, and gaps. It does not edit the doc. Name the evidence directory in the prompt when one exists. The critic cannot search the web.

**Skills.** None. The `critique-design` agent denies skills.

**Where.** OpenCode, new session. Select the `critique-design` agent and a frontier model. One design doc per session.

```text
Critique docs/design/assets/account-images.md.

Parents: docs/design/files/flow-files.md and docs/design/files/file-promoter.md. Evidence: docs/design/assets/evidence/. The images worker is src/endpoints/images. The first product use is a context icon.
```

Leave that session when the critique is on screen.

## 6. Assess one blocker

**Summary.** One new session per blocker. The new agent may reject the blocker. It edits the design doc only when it agrees. It does not implement, and it does not start a plan. Gaps stay in "Still to decide" and do not get a session. If a gap is really a blocker, send it through this step.

**Skills.** None. This is a normal session, so it can edit. Do not reuse the `critique-design` agent.

**Where.** OpenCode, new session per blocker.

A critique of this doc might return a blocker like:

```text
Authorization still treats "who may upload a context icon" as confirm-later, while the first slice is that screen. Seeded context ACLs are often read-only (permissions 1). The working proposal requires the write bit (2), which excludes a member who can already see the team. The doc needs a decision, or an explicit statement that the first slice ships only for callers whose effective permissions include write.
```

Paste one blocker:

```text
A critique of docs/design/assets/account-images.md reported this blocker:

<paste one blocker>

Read the design doc and the files the blocker cites. Decide whether the blocker is right. If you agree, update that design doc and nothing else. If you disagree, say why and leave the doc unchanged.
```

Run step 5 again only when a blocker edit changed a decision. A doc with no open blockers is ready for a plan.

## 7. Write the plan

**Summary.** Turn the accepted doc into vertical slices. The session shows the breakdown, waits for you to accept it, then writes the plan file. It does not edit the design doc or the code. Skip this step when the accepted doc fits in one fresh session, and point step 8 at the doc.

**Skills.** `plan-from-design`.

**Where.** OpenCode, new session, plan mode, repo `base`.

```text
/plan-from-design

Spec: docs/design/assets/account-images.md
Plan: .opencode/plans/account-images.md

Slice it for one fresh session per step. The first product use is a context icon. Account logos, site covers, and video are later slices. Prefactor the assets table and contexts.icon_asset_id before the read that depends on them. Dropping contexts.avatar_url is a contract step after readers have moved. Name the seam and the tests on each step.
```

Read the plan before you build. If a step is horizontal, or too big for one session, say so in that session and let it revise the plan file. Send a hole in the decision back to step 5. The title is the identity of a step. Prompts name that title, or say "the first step whose status is open." When a revision inserts a step, update the `Blocked by` numbers in that same edit, and leave any `Status: done` line as it is.

The plan that session writes, once you accept the breakdown, looks like this:

```markdown
# Account images

Spec: docs/design/assets/account-images.md

Seam: one context icon. A subject read that expands icon_url signs {ownerId}/{assetId}. One upload moves that context's pointer. The shared default stays live. Account logos, site covers, and video are out of these steps.

## 1. Store an asset id on the context

Status: open
Blocked by: none

Delivers: a context row can hold icon_asset_id, seed inserts one live default asset per owning account and stores that id on the contexts that start from it, and existing avatar_url reads still work.

Seam: repository tests for a context that round-trips icon_asset_id, and for seed leaving the shared default live.

## 2. Sign icon_url when the read expands it

Status: open
Blocked by: 1

Delivers: a context read with expand=icon_url returns a signed URL for that asset and omits the field otherwise. The item includes no filename and no asset id. The client does not call GET /api/images.

Seam: context read tests for expand present, expand absent, and a pointer at the shared default.

## 3. Upload a context icon

Status: open
Blocked by: 2

Delivers: an admin caller who may write the context can start a session, PUT the bytes, and complete. Complete copies into the account images bucket, marks the asset live, stores the new id on that context, marks the previous own upload replaced, leaves the shared default live, and returns the signed URL on the subject.

Seam: session and complete tests for the happy path, a read-only member rejected, and a complete that does not mark the shared default replaced. The flow-file promoter allowlist stays unchanged.

## 4. Drop the context filename column

Status: open
Blocked by: 2

Delivers: context reads no longer select avatar_url, and the column is gone. Site logo filename columns stay until a site slice exists.

Seam: the same context read tests, now asserting the filename column is absent.
```

When a step has been built, the file records it. The status line is the only edit:

```markdown
## 1. Store an asset id on the context

Status: done
Blocked by: none
```

The next prompt says "the first step whose status is open." That survives a new session. To build a different open step, name its title.

## 8. Implement one step

**Summary.** Build the one step you name, at the seam that step names. Then stop. If the step contradicts the design doc, the session stops before it edits code. When the step is finished, the only edit to the plan is that step's `Status` line, set to `done`. The repo `AGENTS.md` still names the commands.

**Skills.** `implement`, which uses `tdd` at the seam and runs `code-review` before it stops.

**Where.** OpenCode, new session per step, build mode.

```text
/implement

Plan: .opencode/plans/account-images.md
Spec: docs/design/assets/account-images.md
Step: the first step whose status is open

Use tdd at the seam the plan names. Run the tests for that step, then pnpm run lint and pnpm typecheck. If the step contradicts the design doc, stop and do not edit code. When the step is finished, set its Status line to done and leave the rest of the plan unchanged. Do not take the next step. Do not commit.
```

When the step is the admin-portal screen, the plan says there is no new seam. `admin-portal` and `starters-preview` have no test suite.

```text
/implement

Plan: .opencode/plans/account-images.md
Spec: docs/design/assets/account-images.md
Step: the first step whose status is open

This repo has no test suite. There is no new seam. Run pnpm run lint and pnpm typecheck. If the step contradicts the design doc, stop and do not edit code. When the step is finished, set its Status line to done and leave the rest of the plan unchanged. Do not take the next step. Do not commit.
```

An accepted doc that fits one fresh session has no plan file.

```text
/implement

Spec: docs/design/assets/account-images.md

This fits one session. There is no plan. If the doc contradicts itself, stop and do not edit code. Use tdd at the seam the doc names. Run the tests, then pnpm run lint and pnpm typecheck. Do not write a plan. Do not commit.
```

Commit only when you ask, in the usual way. In OpenCode, run the `commit` subagent. It loads `conventional-commit` and writes the message. A user-facing package change in `startflows`, `admin-portal`, or `starters-preview` still gets a changeset. The plan is not a changeset.

## 9. Review the diff

**Summary.** This is the close of the implement session: `implement` loads `code-review` before it stops. Run the same prompt yourself in Cursor before you ask for a commit, and whenever you want a second pass.

**Skills.** `code-review`.

**Where.** The implement session, or the Cursor session that steered the step.

```text
/code-review

Fixed point: the commit this step branched from.
Spec: docs/design/assets/account-images.md
Plan step: .opencode/plans/account-images.md — Store an asset id on the context.
```

When the plan has no `Status: open` step left, or the build had no plan, run step 11.

## 10. Steer a step in Cursor

**Summary.** Stay in OpenCode for a step the plan already describes. Move to Cursor before you build a step you want to steer, or when the step is a refactor of a module.

**Skills.** `handoff` in OpenCode. In Cursor, `codebase-design` when you are refactoring a module, `grill-me` when the interface is still open. `grill-me` does not write the design doc.

**Where.** The OpenCode session writes the handoff. The Cursor session opens the path it printed.

In OpenCode:

```text
/handoff user-driven edit of the context-icon upload in Cursor

Spec: docs/design/assets/account-images.md
Plan: .opencode/plans/account-images.md — Upload a context icon
The flow-file promoter allowlist stays unchanged. Load codebase-design for the destination-check split. Do not implement the rest of the plan there. When the step is finished, set its Status line to done and leave the rest of the plan unchanged.
```

In Cursor:

```text
Continue from <the handoff path>.

I am driving this edit. Use codebase-design for the destination-check split. The spec is docs/design/assets/account-images.md. The plan step is .opencode/plans/account-images.md — Upload a context icon. If the step contradicts the design doc, stop and do not edit code. When the step is finished, set its Status line to done and leave the rest of the plan unchanged. Do not write a plan. Do not commit.
```

Before you commit, run step 9 in that Cursor session. For a fixed point of `main`, say so in the prompt. When that step was the last open one, run step 11 in OpenCode.

## 11. Retro the build

**Summary.** The build is finished. The plan has no open step, or the accepted doc had no plan. This session reads that build and proposes changes to the agent environment, so the next build goes better. You accept or reject each one. It writes only what you accept, and it keeps `AGENTS.md` short. A line that will not change the next run stays out. If the design was wrong, that goes back to step 5. It is not an environment change.

**Skills.** `retro`, which calls `writing-for-agents`.

**Where.** OpenCode, new session, after the last review. The same session is enough when the whole build was that one sitting.

```text
/retro

The account-images build is finished.
Spec: docs/design/assets/account-images.md
Plan: .opencode/plans/account-images.md

Read this build. Present candidates for the agent environment, in order of severity. Wait for me to accept or reject each one. Write only what I accept.

A mechanical mistake becomes a check this repo already runs. A line in AGENTS.md is a short pointer the next session needs. A long procedure becomes a skill with a one-line pointer, in the dotfiles, not in this repo's skills. The issue tracker, the triage labels, and where design docs live stay as they are. Do not edit the design doc or the plan. If the design was wrong, say so and stop.
```

Omit the Plan line when the build had no plan.

## Small edits

A local change that does not need a design doc stays a normal session. Name the files and the check. Do not open a design doc, a critique, or a plan for it.

```text
In TeamPopPnl.vue, show the empty state when the context item has no icon_url. Match the surrounding components. Run pnpm run lint and pnpm typecheck. Do not commit.
```

## Architecture survey

Every few days, in OpenCode, you can survey one area. The report is HTML in `$TMPDIR`. You pick a candidate. The resulting refactor happens in Cursor with `codebase-design`.

```text
/improve-codebase-architecture src/endpoints/images

Read docs/design/assets/account-images.md first. Write the report and stop. Do not edit the code.
```
