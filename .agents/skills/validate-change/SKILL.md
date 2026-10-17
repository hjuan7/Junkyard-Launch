---
name: validate-change
description: Review a scoped Junkyard Launch checkpoint and run its existing static validation entrypoint.
---

# Validate change

Read AGENTS.md first. Review only task-relevant changes (including untracked files when no committed baseline exists); exclude tools, builds, backups, and unrelated files. Preview formatter changes before formatting existing source. Run `scripts/validate.ps1` from this repository and report its actual result. Static validation is not runtime evidence: perform separately authorized focused Studio checks only against Junkyard Launch. Do not commit, push, change persistence, or add validation infrastructure.