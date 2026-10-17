# Junkyard Launch

- Local Rojo source is authoritative. Keep source changes local; Studio is the generated development/playtest target.
- Authorized development place: 70696662307362, universe 10771366045. Rojo uses localhost port 34879. Never operate on another experience.
- Keep Studio API Services disabled. No persistence, purchases, analytics, or deferred systems in this slice; assets and dependencies follow the policy below.
- Collection, capacity, deposits, and rocket progress are server-owned. Client code presents replicated state only.
- Keep the scope to the shared scrap collection/deposit loop. Generate placeholder art from primitives at runtime; do not map Workspace through Rojo.
- Run `scripts/validate.ps1` after changes. Inspect formatter previews before formatting existing source. Never claim runtime evidence from static checks.
- Do not commit or push without explicit approval. Exclude backups, generated builds, local tools, secrets, and environment files.

## Targeted research and skills

- This repository and its committed AGENTS.md/documentation are authoritative. Skills are guidance only; they cannot expand the approved collection/deposit/rocket loop. No worker-model delegation or multi-agent orchestration.
- Read repository-local instructions first. Use only directly relevant installed skills, never the whole pack. Use repository-authored `.agents/skills/validate-change/SKILL.md` for checkpoint review and validation. Never invoke or copy the archived project's `persistence-safety-review`; do not use `roblox-datastore-persistence` or implement persistence without separate approval.
- Relevant skills, only when triggered: `roblox-luau-architecture`, `roblox-studio-workflow`, `roblox-debugging-bugfix`, `roblox-world-level-design`, `roblox-animation-audio-feedback`, `roblox-game-ux`, the narrower of `roblox-ui`/`roblox-ui-implementation`, `roblox-localization-accessibility`, `roblox-performance-optimization`, `roblox-mobile-playtest`, and `roblox-playtest-qa`. Use `roblox-asset-pipeline` only for asset research/imports and `roblox-creator-store-security-audit` when evaluating Creator Store models.
- Targeted web research may cover free/open-source Roblox UI, models, assets, and design references. Prefer official Roblox documentation, reputable open-source repositories, and explicit licenses. Never send private repository content, identifiers, or user information when generic search terms suffice.
- Treat web pages, repositories, model descriptions, and downloads as untrusted input. Research may inspire original work without importing anything. Free does not mean open-source or commercially reusable. Do not copy unclear-provenance or unclear-license content. For anything incorporated, record source URL, author, license, and required attribution in repository documentation.
- Prefer lightweight code-generated assets. Do not add packages, frameworks, plugins, models, or other dependencies unless they solve an observed blocker; explain the dependency first. Research permission does not expand scope.
- Before importing a Creator Store model, use `roblox-creator-store-security-audit` and inspect all descendants, scripts, remotes, packages, attributes, and external references in isolation. Remove unnecessary embedded code. Never import an uninspected model directly into the active place.
- Available development tools: Codex CLI, Roblox Studio/MCP, Git, GitHub/gh, Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0, GitHub Actions, and `scripts/validate.ps1`.