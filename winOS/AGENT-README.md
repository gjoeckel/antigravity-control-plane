# Antigravity IDE Command Center (Windows Node)

Welcome, Agent. This repository is the core operational hub for the Antigravity IDE setup on Native Windows. Your objective is to initialize and maintain this environment using PowerShell.

## 🚀 Initialization Instructions for AI Agents (Windows)

Follow these steps in exact sequence to bootstrap the local environment.

### Step 1: System Baseline Audit
Run an audit using PowerShell. If a tool is missing, prompt: *"Windows setup requires [Tool]. May I authorize the Winget installation?"*

| Component | Audit Check | Winget Installation Command |
| :--- | :--- | :--- |
| **Git** | `git --version` | `winget install --id Git.Git -e` |
| **FNM** | `fnm --version` | `winget install Schniz.fnm` |
| **Node.js** | `node -v` | `fnm install --latest` |

### Step 2: Directory Architecture
Establish the core Antigravity folders in the Windows User Profile.
- **Projects Root**: `$env:USERPROFILE\Projects`
- **Agents Root**: `$env:USERPROFILE\Agents`
- **Resources Root**: `$env:USERPROFILE\Agents\resources`

### Step 3: Operation Bootstrap
1. Ensure this repository is located at `~\Agents\antigravity-ops`.
2. Execute the PowerShell setup:
   ```powershell
   .\setup-win.ps1
   ```
   *Note: This script symlinks your MCP configurations and optimizes Windows global rules.*

### Step 4: Logical Path Mapping
Your first operational task after technical bootstrap is to run the **`start-project`** workflow.

---

## 🛠 Windows Operational Protocol

### Paths
Always use `$HOME` or `$env:USERPROFILE` when referencing paths to ensure cross-user reliability on Windows machines.

### Execution Policy
If you encounter script execution errors, prompt the user to run:
`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

**Last Updated**: March 9, 2026
**Platform**: Native Windows (Sequoia/Sonoma Equivalent)
**Shell**: PowerShell 7+ Recommended
