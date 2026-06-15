# Ticket Workflow

## Required Flow

1. Use `gh` for GitHub ticket operations.
2. When asked to work on an existing ticket, fetch it from GitHub with `gh`, show the user a concise summary, branch from `main`, and ask whether they want to plan the ticket.
3. If the user wants a plan, inspect the current codebase and write a plan based on both the ticket and the code. Include unit test work in the plan even if the ticket or user does not mention tests explicitly. Ask clarifying questions for any ambiguity.
4. Implement only after the ticket and plan are clear.
5. When implementation is done, show the user a summary of the changes and ask them to test.
6. After the user approves, prepare a commit message, run tests through Xcode MCP, commit, push, open a PR, and wait for user approval.
7. After the PR is approved or merged, ask whether the user wants to close the ticket.

## Ticket Creation

- When asked to file a new ticket, create it in GitHub with `gh issue create` and include enough context for another agent or developer to act on it.
- Every code or project change in this repo must be backed by a GitHub ticket.

## Ticket Notes And Comments

- For issue comments with Markdown, prefer `gh issue comment --body-file <file>` to avoid shell quoting problems with backticks and code fences.
- Use `gh api --method PATCH .../issues/comments/<id>` only when editing an existing comment.

## Progress Tracking

- Read `Progress.md` at session start.
- After each ticket update, record the current state, notable decisions, and next steps in `Progress.md`.
