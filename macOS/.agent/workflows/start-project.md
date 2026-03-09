---
description: Select project folders using macOS folder picker
---

# Start Project Workflow

This workflow allows you to select the **Development** and **Resources** folders for your project using a macOS folder picker.

1.  **Launch Picker**: The macOS folder picker will appear twice.
2.  **Select Folders**: Select your primary development folder (source code) and your resources folder (docs, context, rules).
3.  **Update Config**: The script will automatically update `config/project-paths.json` with your selections.

// turbo
bash scripts/start-project.sh
