# Antigravity IDE Command Center

Welcome, Agent. This repository is the core operational hub for the Antigravity IDE setup on macOS. Your objective is to initialize and maintain this environment to enable autonomous task execution.

## 🚀 Initialization Instructions for AI Agents

Follow these steps in exact sequence to bootstrap the local environment from absolute zero.

### Step 1: System Baseline Audit
Run an audit of the host machine. If a check fails, you must prompt: *"This setup requires the installation of [Tool]. May I authorize this and proceed?"*

| Component | Audit Check | Required Action (if missing) |
| :--- | :--- | :--- |
| **Xcode CLT** | `xcode-select -p` | `xcode-select --install` |
| **Homebrew** | `brew --version` | `NONINTERACTIVE=1 /bin/bash -c "$(curl ...)"` |
| **Git** | `git --version` | `brew install git` |
| **FNM** | `fnm --version` | `brew install fnm && fnm install --latest` |

### Step 2: Directory Architecture
Establish the core Antigravity directory structure. Briefly explain the purpose to the user during creation.
- **Projects Root**: `~/Projects` (Development codebases)
- **Agents Root**: `~/Agents` (Operational workspace)
- **Resources Root**: `~/Agents/resources` (Non-code artifacts/knowledge per project)

### Step 3: Operation Bootstrap
1. Ensure this repository is located at `~/Agents/antigravity-ops`.
2. Navigate to the root and execute the unified setup:
   ```bash
   bash setup.sh
   ```
   *Note: This script symlinks `config/mcp.json` to the global Antigravity config directory and initializes your Global Rules.*

### Step 4: Logical Path Mapping
Your first operational task after technical bootstrap is to run the **`start-project`** workflow.
- This will map the specific `Projects/` and `Agents/resources/` directories for your current mission.

---

## 🛠 Operational Protocol

### The First Mission (start-project)
The `start-project` workflow is your primary bridge between files on disk and your internal path awareness. Run this as soon as technical setup is complete.

### Communication (RRW)
For high-stakes changes or ambiguous user requests, always invoke the **`rrw`** workflow (Read-Request-Wait). This ensures alignment through a mandatory 3-step pause.

### Autonomous Mode (yolo-full)
When authorized for deep autonomous work, use the `yolo-full` workflow to bypass command confirmations and proceed with high-speed implementation and validation.

---

**Last Updated**: March 9, 2026
**Architecture**: Project-Resources Pattern (v1.0.1)
**Security Status**: Verified for macOS Sequoia/Sonoma
