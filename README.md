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

## Vertical-slice polish check

- Gold floor chevrons lead from spawn toward scrap. Collecting, full packs,
  deposits, named construction stages, launch countdown, and the next rocket
  have concise feedback. Effects reuse one local ring and one highlight; no
  external audio, models, images, or packages are required.
- Studio walking tests used normal Humanoid movement and server proximity checks,
  without injecting carry/progression state: seven deposits credited 82 scrap,
  exposed all five stages (1/2/3/7/8 visible rocket parts), completed one launch,
  and advanced the next rocket. Capacity reached 12 without exceeding it;
  deposit serials advanced once each and standing in the ring did not re-credit.
- Layouts checked: desktop, iPhone 7 landscape (667x375), and iPad (1024x768).
  The compact landscape HUD sits between touch controls, hides the decorative
  title, and preserves approved world-label placement;
  gameplay remains movement-only with standard Roblox touch controls.
- Source-derived baseline / observed polished runtime: generated world BaseParts
  63/69; world descendants 100/106; HUD descendants 11/14. One extra local pulse
  BasePart stays outside the server world. Counts stayed fixed across cycles.
  One bounded client heartbeat and fixed attribute/viewport listeners drive UI;
  decoration adds no listeners/tasks. Simulator checks are not hardware FPS tests.
- No repository-owned runtime errors observed. Historical Rojo connection warnings
  belong to the plugin; settings JSON and FoundationProvider warnings belong to
  Roblox Studio/Core UI. Asset 203785492 type warnings remain unknown-source:
  no matching repository or inspected object reference was found. Unrelated
  avatar/plugin content is unchanged.
