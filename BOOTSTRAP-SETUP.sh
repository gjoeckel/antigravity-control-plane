#!/bin/bash
# Antigravity IDE - Absolute Zero Bootstrap Setup
# Version: 1.1.0 (Synced with Antigravity Ops setup.sh)

echo "🚀 Initializing Antigravity Operations Node (macOS)..."

# 0. Quick Dependency Check
for cmd in osascript jq; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "❌ Error: $cmd is required."; exit 1; }
done

# 1. Environment Metadata
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANTIGRAVITY_CONFIG_DIR="$HOME/.gemini/antigravity"
MCP_CONFIG_FILE="$ANTIGRAVITY_CONFIG_DIR/mcp_config.json"
GLOBAL_RULES_FILE="$HOME/.gemini/GEMINI.md"

# 2. Dependency Management Logic
check_and_prompt() {
    local TOOL_NAME=$1
    local INSTALL_CMD=$2
    local VERIFY_CMD=${3:-$1}

    if ! command -v $VERIFY_CMD &> /dev/null; then
        echo "⚠️  MISSING: $TOOL_NAME"
        echo "   This setup requires $TOOL_NAME to proceed."
        read -p "Authorize installation? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📦 Installing $TOOL_NAME..."
            eval "$INSTALL_CMD"
            
            if [[ "$TOOL_NAME" == "Homebrew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        else
            echo "❌ Setup halted. $TOOL_NAME is required."
            exit 1
        fi
    else
        echo "✅ $TOOL_NAME is already installed."
    fi
}

# --- Phase 0: System Prerequisites ---
if ! xcode-select -p &>/dev/null; then
    echo "⚠️  Xcode Command Line Tools missing."
    echo "   Action: Triggering xcode-select --install. Please complete the pop-up."
    xcode-select --install
    exit 1
fi

check_and_prompt "Homebrew" "NONINTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" "brew"

# --- Phase 1: Runtimes ---
check_and_prompt "Git" "brew install git"
check_and_prompt "FNM" "brew install fnm && eval \"\$(fnm env --use-on-cd)\" && fnm install --latest" "fnm"

# --- Phase 2: Operations Linkage ---
mkdir -p "$ANTIGRAVITY_CONFIG_DIR"
if [ -f "$REPO_DIR/config/mcp.json" ]; then
    echo "🔗 Symlinking config/mcp.json to $MCP_CONFIG_FILE"
    ln -sf "$REPO_DIR/config/mcp.json" "$MCP_CONFIG_FILE"
fi

# --- Phase 3: Global Rules (Synced with setup.sh logic) ---
# We append if patterns aren't present, or create new.
if [ -f "$REPO_DIR/docs/GLOBAL-RULES-TEMPLATE.md" ]; then
    if [ -f "$GLOBAL_RULES_FILE" ] && ! grep -q "Project & Resources Pattern" "$GLOBAL_RULES_FILE"; then
        echo "📦 Appending Antigravity Ops patterns to $GLOBAL_RULES_FILE"
        cat "$REPO_DIR/docs/GLOBAL-RULES-TEMPLATE.md" >> "$GLOBAL_RULES_FILE"
    elif [ ! -f "$GLOBAL_RULES_FILE" ]; then
        echo "�� Creating new $GLOBAL_RULES_FILE"
        cat "$REPO_DIR/docs/GLOBAL-RULES-TEMPLATE.md" > "$GLOBAL_RULES_FILE"
    fi
fi

# --- Phase 4: Permissions ---
chmod +x "$REPO_DIR/scripts/"*.sh 2>/dev/null || true

echo "-----------------------------------------------"
echo "✅ BOOTSTRAP COMPLETE"
echo "Mission: Open your IDE and run 'start-project'."
echo "-----------------------------------------------"
