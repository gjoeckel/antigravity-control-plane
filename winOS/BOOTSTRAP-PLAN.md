# Antigravity IDE: Windows Absolute Zero Onboarding Plan

This plan outlines the "Absolute Zero" setup for a new Antigravity IDE instance on Native Windows. It is designed for execution via PowerShell and utilizes **Winget** for modern package management.

## 1. Proven Dependency Chain (Windows)

### Phase 0: System Prerequisites
1.  **Winget**: The native Windows Package Manager (usually pre-installed on Windows 10/11).
    *   **Check**: `winget --version`
2.  **Git for Windows**: Essential for repository management.
    *   **Action**: `winget install --id Git.Git -e --source winget`
3.  **FNM (Fast Node Manager)**: High-performance Node.js management for Windows.
    *   **Action**: `winget install Schniz.fnm`

### Phase 1: PowerShell Environment
Standardize the shell experience for AI Agents:
1.  **Execution Policy**: Ensure PowerShell can run local scripts.
    *   **Action**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
2.  **FNM Initialization**: Initialize Node runtime.
    *   **Action**: `fnm env --use-on-cd | Out-String | Invoke-Expression` followed by `fnm install --latest`

### Phase 2: Directory Architecture
Establish the core Antigravity folders:
- `$HOME\Projects`: Code repos.
- `$HOME\Agents\antigravity-ops`: This command center repo.
- `$HOME\Agents\resources`: Project knowledge vaults.

### Phase 3: Bootstrap & Activation
1.  **Ops Deployment**: Clone `antigravity-ops` into `$HOME\Agents\antigravity-ops`.
2.  **Logic Linking**: Run the `.ps1` setup script to link configurations and initialize global rules.
3.  **Path Mapping**: Execute the `start-project` workflow to initialize the first session.

---

## 2. Agent Execution Rules
- **Audit -> Report -> Authorize**: Check for `winget`, `git`, and `fnm` before installing.
- **Path Resolution**: Use environment variables (e.g., `$env:USERPROFILE`) to ensure location awareness.
- **Elevation Awareness**: Prompt the user if a command requires an Administrative PowerShell prompt.
