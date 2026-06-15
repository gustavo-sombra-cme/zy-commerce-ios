# Agent Instructions

## Project Overview

- ZY-Commerce iOS is a simple ecommerce test project used to validate app flows, integration patterns, and agent workflow.
- The app is a SwiftUI iPhone app in `Commerce-ios/`.
- The project is not positioned as a production commerce client. Keep implementation and documentation decisions aligned with a test-only app unless the user explicitly changes that direction.
- The Xcode project is `Commerce-ios.xcodeproj`.

## Project Purpose

- Exercise an end-to-end native iOS commerce surface against the ZY-Commerce backend.
- Validate authentication, session, catalog, and related app-state flows in a small SwiftUI codebase.
- Provide a repo where agents can work through GitHub-ticket-driven tasks with explicit progress tracking.

## Tech Stack

- Swift `6` for source authored in this repo.
- SwiftUI for UI composition.
- Observation framework for app state (`@Observable`, `@State`, `@Bindable` where needed).
- Foundation and `URLSession` for networking.
- Security framework for token storage.
- Swift Testing (`import Testing`) for unit tests in `Commerce-iosTests/`.
- Xcode `26.5.0` via the configured Xcode MCP bridge.
- iOS deployment target: `17.0` for the app target.
- App versioning in project settings: marketing version `1.0`, build number `1`.

## Repository Layout

- `Commerce-ios/Commerce_iosApp.swift`: app entry point.
- `Commerce-ios/ContentView.swift`: initial app bootstrap view.
- `Commerce-ios/AppState.swift`: launch/bootstrap state management.
- `Commerce-ios/AppConfiguration.swift`: environment and API base URL resolution.
- `Commerce-ios/APIClient.swift`: HTTP client and endpoint helpers.
- `Commerce-iosTests/`: Swift Testing test target.
- `docs/TicketWorkflow.md`: detailed GitHub ticket workflow for agents.
- `Progress.md`: session log and per-ticket progress record.

## First Run

1. Check repo state with `git status --short --branch`.
2. Read `Progress.md` at session start. If it is missing, create it before doing other task work.
3. Ensure Xcode is open with MCP access enabled.
4. Verify the Xcode MCP bridge is configured:

```sh
codex mcp add Xcode --env DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer -- xcrun mcpbridge
```

5. Open `Commerce-ios.xcodeproj` in Xcode if it is not already open.
6. Confirm the backend expectation for the chosen environment before running app flows:
   - local defaults to `http://localhost:5015`
   - development and production require configured base URLs
7. Use Xcode MCP to inspect, build, and test the project before shipping changes.

## Build And Test

- Use Xcode MCP for build, test, simulator, and project-inspection workflows.
- Prefer Xcode MCP over direct `xcodebuild` commands because it is faster and easier to operate from agents.
- Xcode must be open with MCP access enabled for the bridge to expose tools.
- After adding or changing MCP configuration, restart Codex or start a new Codex session so the MCP tools load.
- To verify the MCP connection, use Xcode MCP to list windows, then build the active project. A healthy connection should show `Commerce-ios.xcodeproj` and build the project successfully.
- Before every commit, run the relevant tests through Xcode MCP.
- If Xcode MCP is not available or not connected, stop and ask the user to connect it.
- Do not use `xcrun mcpbridge run-agent codex` for this repo workflow. That launches Codex from Xcode and requires Codex to be configured inside Xcode; this repo uses Codex connected to Xcode's native MCP bridge instead.
- Do not fall back to direct `xcodebuild` unless the user explicitly asks for that fallback.

## Non-Negotiable Constraints

- Never commit or push without explicit approval from the user.
- Never delete files without clear approval from the user.
- Do not invent product or process constraints that are not explicitly documented in this repo or provided by the user.
- Treat the current repo instructions and direct user instructions as the binding constraints unless the user updates them.

## Coding Guidelines

- Follow existing SwiftUI patterns unless a change clearly calls for a new structure.
- Prefer the Observation framework over the older `ObservableObject` / `@StateObject` APIs for new app state.
- Keep UI state local with `@State` until shared state or testability requires a model object.
- Prefer small SwiftUI views composed from focused private helpers or subviews.
- Keep user-facing strings centralized once the app has repeated text or localization needs.
- Unit tests are always part of the implementation plan when code changes are made, even if the ticket or user does not mention tests explicitly.
- Use Swift Testing for new unit tests with `@Test` and `#expect(...)`.
- Avoid broad project-file churn in `Commerce-ios.xcodeproj/project.pbxproj`; make the smallest necessary Xcode project changes.
- Favor modern SwiftUI APIs where they improve clarity or avoid legacy patterns.

## Agent Workflow

- Check `git status --short --branch` before editing.
- Read `Progress.md` at the start of every session. If it does not exist, create it.
- After each ticket update, append or revise the relevant entry in `Progress.md`.
- Do not revert or overwrite unrelated user changes.
- Every code or project change must be backed by a GitHub ticket.
- Keep changes scoped to the active ticket.
- Never assume missing product, design, or technical requirements. Ask the user when confused.
- Prefer `rg` for searching source files.
- Follow the detailed ticket workflow in `docs/TicketWorkflow.md`.

## Git Guidance

- Use `git` for local repository operations such as status, commit, branch, pull, and push.
- Use `gh` for GitHub operations such as pull requests, issues, checks, releases, and repository metadata.
- Do not commit or push unless the user explicitly approves it.

## Documentation Index

- Root repo overview: `README.md`
- Ticket workflow: `docs/TicketWorkflow.md`
- Session and ticket history: `Progress.md`
- App bootstrap entry point: `Commerce-ios/Commerce_iosApp.swift`
- Runtime configuration: `Commerce-ios/AppConfiguration.swift`
- App state bootstrap: `Commerce-ios/AppState.swift`
