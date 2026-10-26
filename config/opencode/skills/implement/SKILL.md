---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

The user will point at one step in `.opencode/plans/<slug>.md` and at a design doc under `docs/design/`. The step is the title they name, or the first step whose `Status` is `open`. Implement that step only. The design doc is the spec. The plan step names the seam. A plan path and a step title are not a ticket reference. Do not fetch a GitHub or GitLab issue, and do not read `.scratch/`. If the step contradicts the design doc, stop and do not edit code. Do not edit the design doc. Do not take the next step. When the step is finished, set its `Status` line to `done` and leave every other line of the plan unchanged. If there is no plan and the user says the accepted doc fits one session, build from the doc and do not write a plan.

The seam on that step is already confirmed. Do not ask the user to confirm it again. That overrides the confirm-the-seam step in `tdd`. Call the Skill tool with "tdd" at that seam. When the step says there is no new seam, or the repo has no test suite, do not invent tests and do not run a suite that is not there. `admin-portal` and `starters-preview` have no test suite.

The repo `AGENTS.md` names the lint and typecheck commands. Run those.

Once done, call the Skill tool with "code-review". The fixed point is the commit this step branched from. The diff includes uncommitted work.

Do not commit, push, amend, or open a pull request. The user commits in a separate step. When they ask to commit, and the repo has `conventional-commit`, load that skill.
