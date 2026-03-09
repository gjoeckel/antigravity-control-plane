#!/bin/bash

# Cursor IDE Full Autonomy Configuration Script
# This script configures Cursor IDE to allow AI agents full autonomy

set -e

# ========================================
# AUTO-DETECT SCRIPT LOCATION (Portable)
# ========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_GLOBAL_DIR="$(dirname "$SCRIPT_DIR")"

# Derived paths
CONFIG_DIR="$CURSOR_GLOBAL_DIR/config"
CHANGELOGS_DIR="$CURSOR_GLOBAL_DIR/changelogs"
SCRIPTS_DIR="$CURSOR_GLOBAL_DIR/scripts"


echo "🚀 Configuring Cursor IDE for Full AI Autonomy..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine Cursor config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    # Windows
    CURSOR_CONFIG_DIR="$APPDATA/Cursor/User"
else
    echo -e "${YELLOW}⚠${NC} Unknown OS type, using macOS path as default"
    CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
fi

mkdir -p "$CURSOR_CONFIG_DIR"

echo -e "${BLUE}📁 Configuring Cursor settings directory...${NC}"
echo "Directory: $CURSOR_CONFIG_DIR"

# Backup existing settings if they exist
if [ -f "$CURSOR_CONFIG_DIR/settings.json" ]; then
    echo -e "${YELLOW}📋 Backing up existing settings...${NC}"
    cp "$CURSOR_CONFIG_DIR/settings.json" "$CURSOR_CONFIG_DIR/settings.json.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Use settings.json from config directory
SETTINGS_SOURCE="$CONFIG_DIR/settings.json"
if [ -f "$SETTINGS_SOURCE" ]; then
    echo -e "${BLUE}⚙️  Applying AI-optimized settings from config...${NC}"
    cp "$SETTINGS_SOURCE" "$CURSOR_CONFIG_DIR/settings.json"
    echo -e "${GREEN}✅ Cursor settings configured for AI autonomy${NC}"
else
    echo -e "${RED}❌ Settings file not found at $SETTINGS_SOURCE${NC}"
    exit 1
fi

# Run comprehensive MCP server setup
echo -e "${BLUE}🚀 Setting up Model Context Protocol (MCP) servers...${NC}"
"$SCRIPTS_DIR/setup-mcp-servers.sh"

echo -e "${GREEN}✅ MCP servers installed and configured${NC}"

# Create AI autonomy permissions file
echo -e "${BLUE}🔐 Setting up AI autonomy permissions...${NC}"
cat > "$HOME/.cursor-ai-permissions" << 'EOF'
# Cursor AI Autonomy Permissions
# This file grants the AI agent full autonomy to:
# - Execute terminal commands
# - Modify system files
# - Install software packages
# - Configure development environment
# - Access file system
# - Run shell scripts
# - Install extensions
# - Configure system settings

AUTONOMY_LEVEL=full
TERMINAL_ACCESS=true
FILE_SYSTEM_ACCESS=true
PACKAGE_INSTALLATION=true
SYSTEM_CONFIGURATION=true
EXTENSION_MANAGEMENT=true
SHELL_SCRIPT_EXECUTION=true
AUTO_APPROVE_ACTIONS=true

# GitHub Push Security Gate
GITHUB_PUSH_GATE=true
GITHUB_PUSH_TOKEN="push to github"
REQUIRE_PUSH_TOKEN=true
EOF

echo -e "${GREEN}✅ AI autonomy permissions configured${NC}"

# Setup GitHub push security gate (optional)
if [ -f "$SCRIPTS_DIR/github-push-gate.sh" ]; then
    echo -e "${BLUE}🔒 Setting up GitHub push security gate...${NC}"
    chmod +x "$SCRIPTS_DIR/github-push-gate.sh"
    "$SCRIPTS_DIR/github-push-gate.sh" setup || {
        echo -e "${YELLOW}⚠${NC} GitHub push gate setup failed (non-critical)"
    }
    echo -e "${GREEN}✅ GitHub push security gate configured${NC}"
fi

# Final summary
echo ""
echo -e "${BLUE}🎉 Cursor IDE Full Autonomy Configuration Complete!${NC}"
echo ""
echo -e "${GREEN}✅ What's been configured:${NC}"
echo "   • Cursor IDE settings optimized for AI autonomy (YOLO mode)"
echo "   • Model Context Protocol (MCP) servers installed and configured"
echo "   • AI autonomy permissions file created"
echo "   • GitHub push security gate configured (optional)"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "   1. Restart Cursor IDE to apply new settings"
echo "   2. Verify MCP servers are running (use 'mcp-health' workflow)"
echo "   3. Start using autonomous AI features"
echo ""
echo -e "${BLUE}💡 The AI agent can now:${NC}"
echo "   • Execute terminal commands automatically"
echo "   • Install packages and software"
echo "   • Configure system settings"
echo "   • Create and modify files"
echo "   • Run shell scripts"
echo "   • Install extensions"
echo ""
echo -e "${BLUE}🔒 Security Features:${NC}"
echo "   • GitHub push gate requires exact token: 'push to github'"
echo "   • Settings backed up before changes"
echo ""
echo -e "${GREEN}🎯 Ready for autonomous execution!${NC}"
