# Junkyard Launch

A session-only collection prototype: walk through scrap to magnetically collect it,
fill a 12-piece pack, then return to the green deposit ring. Every 12 deposited
pieces builds one of five visible rocket stages. A completed rocket departs after
four seconds and the next build starts; collection/deposit stays available.

Server code owns distance checks, capacity, scrap availability, deposits and shared
rocket progress. The client only displays replicated counters. There are no saved
rewards, external assets, runtime dependencies, or API Services requirements.

## Development (Windows PowerShell)

1. Keep Studio **Enable Studio Access to API Services disabled**.
2. Run `.\scripts\install-tools.ps1` (official Rojo 7.7.1, StyLua 2.6.0,
   Selene 0.32.0 releases; archive SHA-256 checks are pinned in the script).
3. Run `.\scripts\validate.ps1`.
4. Run `.\.tools\rojo\rojo.exe serve default.project.json --port 34879`.
5. In the official Rojo plugin, connect to localhost:34879 in **Junkyard Launch**,
   place **70696662307362**, universe **10771366045**. Review/sync, then Play.

Rojo maps source services only. The server generates the pad, scrap field, deposit
ring and rocket in Workspace at runtime. Standard Roblox desktop/touch movement
works; collection and deposit need no precision button input. The HUD uses safe
insets and a compact layout. `build/` and `.tools/` stay ignored; never commit place
backups (including `.rblx`). CI performs static checks only, never live game tests.
