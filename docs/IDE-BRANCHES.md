# IDE-Specific Branches Guide

**Overview of IDE-specific branches and how to use them**

---

## Branch Structure

This repository uses **branch-based organization** to provide IDE-specific documentation while keeping shared information in the main branch.

### Main Branch

The `main` branch contains:
- High-level repository overview
- Package information (IDE-agnostic)
- General MCP server implementation guide
- Optimized configuration (IDE-agnostic)
- Links to IDE-specific branches

### IDE-Specific Branches

Each IDE has its own branch with detailed, IDE-specific documentation:

| Branch | IDE | Documentation |
|--------|-----|---------------|
| `cursor` | Cursor IDE | Complete Cursor setup, YOLO mode, autonomous configuration |
| `antigravity` | Antigravity IDE | Antigravity-specific setup and configuration |
| `claude-code` | Claude Code IDE | Claude Desktop setup and configuration |

---

## Available Branches

### Antigravity Branch

**Branch**: [`antigravity`](https://github.com/gjoeckel/my-mcp-servers/tree/antigravity)

**Contents**:
- Complete Antigravity IDE setup guide
- YOLO mode configuration
- Autonomous operation setup
- Antigravity-specific workflows
- YOLO-FULL workflow documentation
**Best for**: Users setting up Cursor IDE with full autonomous capabilities

### Antigravity Branch

**Branch**: [`antigravity`](https://github.com/gjoeckel/my-mcp-servers/tree/antigravity)

**Contents**:
- Antigravity IDE setup guide
- Antigravity-specific configuration
- Antigravity workflows and features

**Best for**: Users setting up Antigravity IDE

### Claude Code Branch

**Branch**: [`claude-code`](https://github.com/gjoeckel/my-mcp-servers/tree/claude-code)

**Contents**:
- Claude Desktop setup guide
- Claude Code IDE configuration
- Claude-specific workflows

**Best for**: Users setting up Claude Desktop / Claude Code IDE

---

## How to Use

### For Users

1. **Start with Main Branch**
   - Read the main README for overview
   - Review [OPTIMIZED-CONFIG.md](../OPTIMIZED-CONFIG.md) for general configuration
   - Check [MCP-SERVERS-IMPLEMENTATION.md](./MCP-SERVERS-IMPLEMENTATION.md) for implementation details

2. **Switch to Your IDE Branch**
   ```bash
   git checkout cursor        # For Cursor IDE
   git checkout antigravity   # For Antigravity IDE
   git checkout claude-code   # For Claude Code IDE
   ```

3. **Follow IDE-Specific Guide**
   - Read the branch README
   - Follow IDE-specific setup instructions
   - Use IDE-specific configuration examples

### For Contributors

**Adding IDE-Specific Documentation**:

1. Checkout the appropriate branch:
   ```bash
   git checkout cursor  # or antigravity, claude-code
   ```

2. Add/update IDE-specific documentation

3. Commit and push:
   ```bash
   git add .
   git commit -m "Update Cursor IDE documentation"
   git push origin cursor
   ```

**Adding Shared Documentation**:

1. Work on `main` branch for IDE-agnostic content

2. Update shared guides:
   - OPTIMIZED-CONFIG.md
   - docs/MCP-SERVERS-IMPLEMENTATION.md

---

## Branch Comparison

| Feature | Main | Cursor | Antigravity | Claude Code |
|---------|------|--------|-------------|-------------|
| Package Info | ✅ | ✅ | ✅ | ✅ |
| General Config | ✅ | ✅ | ✅ | ✅ |
| IDE Setup | ❌ | ✅ | ✅ | ✅ |
| IDE Workflows | ❌ | ✅ | ✅ | ✅ |
| IDE Settings | ❌ | ✅ | ✅ | ✅ |
| Autonomous Mode | ❌ | ✅ | ❌ | ❌ |

---

## Creating New IDE Branches

To add support for a new IDE:

1. **Create Branch from Main**
   ```bash
   git checkout main
   git checkout -b new-ide-name
   ```

2. **Create README**
   - Copy structure from `cursor` branch README
   - Adapt for new IDE
   - Include setup instructions

3. **Add IDE-Specific Docs**
   - IDE setup guide
   - IDE configuration examples
   - IDE-specific troubleshooting

4. **Update Main Branch**
   - Add new branch to this guide
   - Add link in main README

---

## Best Practices

### For Documentation

- **Main Branch**: Keep IDE-agnostic, high-level information
- **IDE Branches**: Include all IDE-specific details
- **Cross-Reference**: Link between main and IDE branches

### For Configuration

- **Main Branch**: Provide template configurations
- **IDE Branches**: Provide IDE-specific resolved configurations
- **Examples**: Include working examples for each IDE

### For Troubleshooting

- **Main Branch**: General troubleshooting
- **IDE Branches**: IDE-specific troubleshooting
- **Common Issues**: Document in both places if applicable

---

## Quick Links

- [Main Branch README](../README.md)
- [Cursor Branch](https://github.com/gjoeckel/my-mcp-servers/tree/cursor)
- [Antigravity Branch](https://github.com/gjoeckel/my-mcp-servers/tree/antigravity)
- [Claude Code Branch](https://github.com/gjoeckel/my-mcp-servers/tree/claude-code)

---

**Last Updated**: November 26, 2025
