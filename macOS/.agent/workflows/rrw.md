---
description: Read-Request-Wait Protocol: 1) Repeat understanding 2) Request info 3) Wait for auth
---

# RRW Protocol Workflow

Standardized communication protocol for AI interactions to ensure alignment and authorization.

// turbo-all
1. **Activate Protocol**: Run the RRW script to visually confirm activation.
   `bash scripts/run-workflow.sh rrw-protocol`

2. **Repeat Understanding**: Paraphrase the user's request to ensure complete alignment.

3. **Request Info**: Ask for any missing information, file paths, or clarifications required to complete the task accurately.

4. **Wait for Authorization**: explicitly state that you are waiting for the user's "GO" or authorization before proceeding with tool calls or edits.

**DO NOT** execute any other tools or make any code changes until the user provides authorization.
