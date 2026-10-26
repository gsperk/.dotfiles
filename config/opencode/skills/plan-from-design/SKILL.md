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
