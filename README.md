# Salvage Seas v0.03 — first-person shop and dock prototype

The v0.01 interface-heavy test has been replaced as the starting scene by a walkable 3D shop and dock. v0.03 fixes mouse-look input and expands the dock into a broad open-water basin with side quays, a workshop, a moored ship and boarding gangway. This is a functional blockout, not final art. The shop follows the cosy compact-room reference but uses a true first-person viewpoint rather than Recettear's overhead camera.

## Controls

- WASD: walk; mouse: look; E: interact with the item under the crosshair.
- Esc: close an interaction panel or release/capture the mouse.
- P: pause/resume all game timers (day, ship, worktable and customers).
- F5: save; F9: load. Saves are stored in Godot's user data directory.
- Walk through the shop doorway to reach the west dock walkway. Follow that walkway to the ship, cross its gangway, and walk through the dock's southern entrance to return to the shop.

## Loop

In the dock, approach the salvage chart on the west quay and press E to dispatch the ship to one of three Homewater regions. It pulls away, spends 3:30 on a run and returns with two Salvaged Junk Bundles, using one recovery in that region. Wait for it to finish docking, cross the gangway, look at a bundle in its hold and press E to carry it. Walk back to the west-quay worktable and press E to place the bundle in the machine. The machine takes 20 seconds to produce one each of Crude Wood, Oxidized Copper and Crumbling Stone Plates. Repeat for the second bundle. The ship cannot depart again until its cargo is collected. If you step into the sea, you return to the walkway.

Return to the shop; look at one of the eight slots on the two central shelves, press E and select stock. Look at the counter and open the store. Customers wander in and buy stocked items at their base prices.

A day lasts 10 real minutes; night lasts 5. No customers visit at night. Open the store again each morning. At night, the counter allows you to sleep early. Rarity definitions span Junk, Common, Uncommon, Rare, Epic, Legendary and Divinity; only Junk items exist so far.

This build intentionally does not yet contain room purchases, debt collection, requests, sale-price negotiation, richer models, character animation, textures or a visual star map. The dock chart presents only the starter tile's regions. These are later development stages, not features hidden in this build.

## Build

Open `project.godot` in Godot 4.5.1 and run. A GitHub Actions workflow tests the old data loop and new first-person loop, then exports a Windows ZIP. The latest build can be found under the most recent successful **Windows build** run's Artifacts.

The earlier interface test is still in `scenes/main.tscn` for reference, but it is no longer the main scene. See [GAME_DESIGN.md](GAME_DESIGN.md) for the longer-term design.
