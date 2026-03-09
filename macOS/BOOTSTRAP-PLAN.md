# Antigravity IDE: Absolute Zero Onboarding Plan (Refined)

This plan outlines the "Absolute Zero" setup for a new Antigravity IDE instance on macOS. It implements 2025/2026 best practices for reliability, speed, and AI-agent compatibility.

## 1. Proven Dependency Chain

### Phase 0: The Base Layer (System)
1.  **Xcode Command Line Tools**: Essential compiler and UNIX utilities.
    *   **Check**: `xcode-select -p`
    *   **Action**: `xcode-select --install` (Prompts user for GUI agreement).
2.  **Homebrew**: The macOS package manager.
    *   **Check**: `which brew`
    *   **Action**: `NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### Phase 1: Runtimes & Versioning
1.  **Git**: Latest version for reliable repo management.
    *   **Action**: `brew install git`
2.  **FNM (Fast Node Manager)**: Rust-based, high-performance Node management.
    *   **Check**: `which fnm`
    *   **Action**: `brew install fnm` followed by `fnm install --latest`
    *   **Note**: Prefer FNM over standard `brew install node` to prevent permission issues.

### Phase 2: Directory Architecture
Establish the "Code vs. Knowledge" split:
- `~/Projects`: Root for codebase repositories.
- `~/Agents`: Root for Agent Operations.
- `~/Agents/antigravity-ops`: This command-center repository.
- `~/Agents/resources`: Knowledge vault for non-code artifacts (Reports, Docs, Local Tests).

### Phase 3: Bootstrap & Activation
1.  **Ops Deployment**: Clone `antigravity-ops` into `~/Agents/antigravity-ops`.
2.  **Logic Linking**: Run `bash setup.sh` to symlink configurations and apply Global Rules.
3.  **Path Mapping**: Execute the `start-project` workflow to initialize the first session with correct directory context.

---

## 2. Implementation Rules for Agents

### Rule 1: Audit -> Report -> Authorize
Do not perform silent installations. 
- **Audit**: Silently check for all dependencies in Phase 0 & 1.
- **Report**: Surface a status table to the user.
- **Authorize**: Ask, "May I install the missing components [X, Y, Z] to proceed?"

### Rule 2: Shell Context Persistence
After installing Homebrew or FNM, ensure the shell session is aware of the new paths:
- Add `eval "$(/opt/homebrew/bin/brew shellenv)"` to the current session.
- Add `eval "$(fnm env --use-on-cd)"` to the current session.

### Rule 3: Public-First Pushing
The Git configuration will start with Public HTTPS access. Complex Git/SSH auth is handled by the agent *after* the environment is stable in the `yolo-full` state.
