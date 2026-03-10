# Custom MCP Servers Implementation Guide

**Complete guide for implementing and using custom MCP servers with automatic npx installation**

---

## Table of Contents

1. [Overview](#overview)
2. [MCP Server Architecture](#mcp-server-architecture)
3. [Official MCP Servers](#official-mcp-servers)
4. [Custom MCP Servers](#custom-mcp-servers)
5. [npx Installation Mechanism](#npx-installation-mechanism)
6. [Configuration](#configuration)
7. [Environment Variables](#environment-variables)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This guide covers the implementation of **6 MCP servers** providing **39 tools total**, optimized to stay under Antigravity's 40-tool limit. All servers use `npx -y` for automatic installation and dependency management.

### Server Summary

| Server | Type | Tools | Installation Method |
|--------|------|-------|-------------------|
| filesystem | Official | 15 | `npx -y @modelcontextprotocol/server-filesystem` |
| memory | Official | 8 | `npx -y @modelcontextprotocol/server-memory` |
| github-minimal | Custom | 4 | `npx -y mcp-github-minimal` |
| shell-minimal | Custom | 4 | `npx -y mcp-shell-minimal` |
| playwright-minimal | Custom | 4 | `npx -y mcp-playwright-minimal` |
| agent-autonomy | Custom | 4 | `npx -y mcp-agent-autonomy` |
| **Total** | | **39** | |

---

## MCP Server Architecture

### How MCP Servers Work

1. **Configuration**: Defined in `~/.antigravity/mcp.json` (or IDE-specific location)
2. **Startup**: IDE reads config on launch
3. **Installation**: Uses `npx -y` to auto-install packages
4. **Execution**: Servers run as separate processes
5. **Tool Exposure**: Tools become available to AI agent

### Configuration Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

---

## Official MCP Servers

### 1. Filesystem Server

**Package**: `@modelcontextprotocol/server-filesystem`
**Tools**: 15
**Purpose**: File operations, directory navigation, content management

#### Configuration

```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "${HOME}"],
    "env": {
      "ALLOWED_PATHS": "${HOME}:${HOME}/.antigravity:${HOME}/.config",
      "READ_ONLY": "false"
    }
  }
}
```

#### Available Tools

- File reading/writing
- Directory listing
- File search
- Directory tree navigation
- File metadata
- Path operations

#### Installation

Automatically installed via npx on first use:
```bash
npx -y @modelcontextprotocol/server-filesystem ${HOME}
```

### 2. Memory Server

**Package**: `@modelcontextprotocol/server-memory`
**Tools**: 8
**Purpose**: Knowledge storage, entity management, search

#### Configuration

```json
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  }
}
```

#### Available Tools

- Create entities
- Create relations
- Search nodes
- Read knowledge graph
- Add observations
- Delete entities/relations

#### Installation

Automatically installed via npx on first use:
```bash
npx -y @modelcontextprotocol/server-memory
```

---

## Custom MCP Servers

### 3. GitHub Minimal Server

**Package**: `mcp-github-minimal`
**Tools**: 4
**Purpose**: Essential GitHub operations

#### Configuration

```json
{
  "github-minimal": {
    "command": "npx",
    "args": ["-y", "mcp-github-minimal"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
    }
  }
}
```

#### Required Environment Variable

```bash
export GITHUB_TOKEN="github_pat_..."
```

#### Available Tools

- `get_file_contents` - Read repository files
- `create_or_update_file` - Create or update files
- `push_files` - Push files to repository
- `search_repositories` - Search GitHub repositories

#### Installation

Automatically installed via npx:
```bash
npx -y mcp-github-minimal
```

#### Source Repository

If you need to build from source:
```bash
git clone https://github.com/gjoeckel/my-mcp-servers.git
cd my-mcp-servers/packages/github-minimal
npm install
npm run build
```

### 4. Shell Minimal Server

**Package**: `mcp-shell-minimal`
**Tools**: 4
**Purpose**: Essential shell command execution

#### Configuration

```json
{
  "shell-minimal": {
    "command": "npx",
    "args": ["-y", "mcp-shell-minimal"],
    "env": {
      "WORKING_DIRECTORY": "${HOME}",
      "ALLOWED_COMMANDS": "npm,git,node,php,composer,curl,wget,ls,cat,grep,find,chmod,chown,mkdir,rm,cp,mv,pwd,echo,which"
    }
  }
}
```

#### Environment Variables

- `WORKING_DIRECTORY`: Base directory for commands
- `ALLOWED_COMMANDS`: Comma-separated list of allowed commands

#### Available Tools

- `execute_command` - Execute shell commands
- `list_processes` - List running processes
- `kill_process` - Kill process by PID
- `get_environment` - Get environment variables

#### Installation

```bash
npx -y mcp-shell-minimal
```

### 5. Playwright Minimal Server

**Package**: `mcp-playwright-minimal`
**Tools**: 4
**Purpose**: Browser automation

#### Configuration

```json
{
  "playwright-minimal": {
    "command": "npx",
    "args": ["-y", "mcp-playwright-minimal"]
  }
}
```

#### Available Tools

- `navigate` - Navigate to URL
- `take_screenshot` - Capture page screenshot
- `extract_text` - Extract text from page
- `click_element` - Click page elements

#### Installation

```bash
npx -y mcp-playwright-minimal
```

### 6. Agent Autonomy Server

**Package**: `mcp-agent-autonomy`
**Tools**: 4
**Purpose**: Workflow automation

#### Configuration

```json
{
  "agent-autonomy": {
    "command": "npx",
    "args": ["-y", "mcp-agent-autonomy"]
  }
}
```

#### Available Tools

- `execute_workflow` - Execute predefined workflow
- `list_workflows` - List available workflows
- `register_workflow` - Register new workflow
- `check_approval` - Check if command is auto-approved

#### Installation

```bash
npx -y mcp-agent-autonomy
```

---

## npx Installation Mechanism

### How npx Works

`npx` (Node Package Execute) automatically:

1. **Checks local installation**: Looks for package in `node_modules`
2. **Downloads if needed**: Fetches from npm registry if not found
3. **Caches for speed**: Stores in `~/.npm/_npx/` for future use
4. **Executes immediately**: Runs the package without global installation

### The `-y` Flag

The `-y` flag automatically answers "yes" to all prompts, enabling:
- Silent installation
- No user interaction required
- Perfect for automated setups

### Installation Flow

```
IDE Launch
    ↓
Read mcp.json config
    ↓
For each server:
    ↓
Execute: npx -y <package-name>
    ↓
npx checks cache
    ↓
[If not cached]
    Download from npm
    Cache in ~/.npm/_npx/
    ↓
Execute server
    ↓
Server starts
    ↓
Tools available to AI
```

### Cache Location

npx caches packages in:
- **macOS/Linux**: `~/.npm/_npx/`
- **Windows**: `%APPDATA%\npm-cache\_npx\`

### Benefits of npx

1. **No manual installation**: Servers install automatically
2. **Always up-to-date**: Can fetch latest versions
3. **No global pollution**: Doesn't install globally
4. **Fast**: Caching makes subsequent runs instant
5. **Portable**: Works on any machine with Node.js

---

## Configuration

### Complete mcp.json Example

See [OPTIMIZED-CONFIG.md](./OPTIMIZED-CONFIG.md) for the complete configuration.

### Path Resolution

Replace `${HOME}` with actual home directory path:

**Before (template):**
```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "${HOME}"]
```

**After (resolved - macOS):**
```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username"]
```

**After (resolved - Linux):**
```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/username"]
```

---

## Environment Variables

### Required Variables

#### GITHUB_TOKEN

Required for `github-minimal` server:

```bash
# Get token from: https://github.com/settings/tokens
export GITHUB_TOKEN="github_pat_..."

# Add to shell config
echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### Optional Variables

#### MCP_SERVERS_REPO

For using local builds instead of npx:

```bash
export MCP_SERVERS_REPO="$HOME/.antigravity/mcp-servers"
```

#### WORKING_DIRECTORY

For shell-minimal server (set in mcp.json):
```json
"WORKING_DIRECTORY": "${HOME}"
```

#### ALLOWED_COMMANDS

For shell-minimal server (set in mcp.json):
```json
"ALLOWED_COMMANDS": "npm,git,node,php,composer,curl,wget,ls,cat,grep,find,chmod,chown,mkdir,rm,cp,mv,pwd,echo,which"
```

---

## Troubleshooting

### Server Not Starting

**Problem**: MCP server fails to start

**Solutions**:
1. Check Node.js is installed: `node --version`
2. Check npm is installed: `npm --version`
3. Verify npx works: `npx --version`
4. Check `mcp.json` syntax is valid JSON
5. Review IDE logs for errors

### npx Installation Fails

**Problem**: npx can't download package

**Solutions**:
1. Check internet connection
2. Verify npm registry access: `npm ping`
3. Clear npx cache: `rm -rf ~/.npm/_npx/`
4. Try manual install: `npm install -g <package-name>`

### Environment Variables Not Working

**Problem**: Server can't access environment variables

**Solutions**:
1. Verify variable is set: `echo $GITHUB_TOKEN`
2. Check variable is exported: `export GITHUB_TOKEN="..."`
3. Restart IDE after setting variables
4. Verify variable name matches config (case-sensitive)

### Tool Count Exceeds Limit

**Problem**: More than 40 tools total

**Solutions**:
1. Remove unused servers from `mcp.json`
2. Use minimal versions of servers
3. Check tool count in IDE settings
4. Current setup: 39 tools (under limit)

### GitHub Server Authentication Fails

**Problem**: GitHub operations fail

**Solutions**:
1. Verify `GITHUB_TOKEN` is set correctly
2. Check token has required permissions (repo, read, write)
3. Verify token hasn't expired
4. Test token: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`

---

## Summary

### Key Points

1. **All servers use npx**: Automatic installation, no manual setup
2. **39 tools total**: Optimized to stay under 40-tool limit
3. **Environment variables**: Required for GitHub, optional for others
4. **Automatic startup**: Servers start when IDE launches
5. **Portable**: Works on any machine with Node.js

### Installation Checklist

- [ ] Node.js installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] `mcp.json` configured (see [OPTIMIZED-CONFIG.md](./OPTIMIZED-CONFIG.md))
- [ ] `GITHUB_TOKEN` set (for GitHub server)
- [ ] IDE restarted
- [ ] Servers verified (check IDE settings)

### Next Steps

1. Configure `mcp.json` with your paths (see [OPTIMIZED-CONFIG.md](./OPTIMIZED-CONFIG.md))
2. Set required environment variables
3. Restart your IDE
4. Verify servers are connected
5. Start using MCP tools!

---

**Last Updated**: November 26, 2025
**Related Documentation**:
- [OPTIMIZED-CONFIG.md](../OPTIMIZED-CONFIG.md) - Recommended 39-tool configuration
- [IDE-BRANCHES.md](./IDE-BRANCHES.md) - Guide to IDE-specific branches
- **IDE-Specific Setup**: See IDE-specific branches (antigravity, claude-code)
