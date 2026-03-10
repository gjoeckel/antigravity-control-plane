# Antigravity Global Rules (Ops)

## 1. Project & Resources Pattern
Every project is split into two primary locations:
- **Project Folder**: `~/Projects/<project_name>` (Source code only)
- **Resources Folder**: `~/Agents/resources/<project_name>` (Operational context, scripts, rules, and docs)

**Agent Instruction**: Upon starting a session, always look for an `AGENT-STARTUP.md` in the Resources folder for the current project to understand boundaries and key paths.

## 2. Testing Constraints
- **Server-Side Testing**: Preference is to test on the deployed server (rsync → test).
- **No Mock Noise**: Do not add test mocks, runners, or spec files to the Project Folder unless explicitly requested. Keep testing artifacts in the Resources folder.

## 3. Autonomous (YOLO) Policy
- When `/yolo-full` is active, the agent has full permission to execute shell commands and edit files.
- Always run `validate-autonomous-mode.sh` before starting large autonomous tasks.
- Respect the **40-tool limit**. Always check tool count before adding new MCP servers.
