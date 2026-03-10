---
description: Switch to using the Gemini API key for operations
---

# Gemini Key Workflow

This workflow switches the active operational context to use the **Google Gemini API**. It validates the existing key and performs a connectivity health check.

1.  **Switch & Validate**: Run the provider selection and health check script.
    `bash scripts/run-workflow.sh gemini-key`

2.  **Display Status**: Show the updated project startup context.
    `bash scripts/run-workflow.sh show-project-startup`

**Note**: This workflow updates `config/active-provider.json`. Agents will prioritize Gemini for task execution when this context is active.
