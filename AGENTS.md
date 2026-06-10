# Agent Instructions

## Project Overview

- This is the iOS repository for the ZY-Commerce project.
- The app is a SwiftUI application in `Commerce-ios/`.
- Unit tests live in `Commerce-iosTests/` and use Swift Testing (`import Testing`).
- The Xcode project is `Commerce-ios.xcodeproj`.

## Repository Layout

- `Commerce-ios/Commerce_iosApp.swift`: app entry point.
- `Commerce-ios/ContentView.swift`: initial SwiftUI view.
- `Commerce-ios/Assets.xcassets/`: app colors and icons.
- `Commerce-iosTests/`: Swift Testing test target.
- `Commerce-ios.xcodeproj/`: Xcode project configuration.

## Build And Test

- Use Xcode MCP for build, test, simulator, and project-inspection workflows.
- Prefer Xcode MCP over direct `xcodebuild` commands because it is faster and easier to operate from agents.
- The native Xcode MCP bridge is connected to Codex as the `Xcode` MCP server:

```sh
codex mcp add Xcode --env DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer -- xcrun mcpbridge
```

- Xcode must be open with MCP access enabled for the bridge to expose tools.
- After adding or changing MCP configuration, restart Codex or start a new Codex session so the MCP tools load.
- To verify the MCP connection, use Xcode MCP to list windows, then build the active project. A healthy connection should show `Commerce-ios.xcodeproj` and build the project successfully.
- Before every commit, run the relevant tests through Xcode MCP.
- If Xcode MCP is not available or not connected, stop and ask the user to connect it.
- Do not use `xcrun mcpbridge run-agent codex` for this repo workflow. That launches Codex from Xcode and requires Codex to be configured inside Xcode; this repo uses Codex connected to Xcode's native MCP bridge instead.
- Do not fall back to direct `xcodebuild` unless the user explicitly asks for that fallback.

## Coding Guidelines

- Follow existing SwiftUI patterns unless a change clearly calls for a new structure.
- Keep UI state local with `@State` until shared state or testability requires a model object.
- Prefer small SwiftUI views composed from focused private helpers or subviews.
- Keep user-facing strings centralized once the app has repeated text or localization needs.
- Use Swift Testing for new unit tests with `@Test` and `#expect(...)`.
- Avoid broad project-file churn in `Commerce-ios.xcodeproj/project.pbxproj`; make the smallest necessary Xcode project changes.

## Agent Workflow

- Check `git status --short --branch` before editing.
- Do not revert or overwrite unrelated user changes.
- Every code or project change must be backed by a GitHub ticket.
- Keep changes scoped to the active ticket.
- Never assume missing product, design, or technical requirements. Ask the user when confused.
- Prefer `rg` for searching source files.

## Ticket Workflow

- Use `gh` for GitHub ticket operations.
- When asked to work on an existing ticket, fetch it from GitHub with `gh`, show the user a concise summary, branch from `main`, and ask whether they want to plan the ticket.
- If the user wants a plan, inspect the current codebase and write a plan based on both the ticket and the code. Ask clarifying questions for any ambiguity.
- Implement only after the ticket and plan are clear.
- When implementation is done, show the user a summary of the changes and ask them to test.
- After the user approves, prepare a commit message, run tests through Xcode MCP, commit, push, open a PR, and wait for user approval.
- After the PR is approved or merged, ask whether the user wants to close the ticket.
- When asked to file a new ticket, create it in GitHub with `gh issue create` and include enough context for another agent or developer to act on it.
- For issue comments with Markdown, prefer `gh issue comment --body-file <file>` to avoid shell quoting problems with backticks and code fences.
- Use `gh api --method PATCH .../issues/comments/<id>` only when editing an existing comment.

## Git Guidance

- Use `git` for local repository operations such as status, commit, branch, pull, and push.
- Use `gh` for GitHub operations such as pull requests, issues, checks, releases, and repository metadata.
- Do not commit or push unless the user explicitly asks.
