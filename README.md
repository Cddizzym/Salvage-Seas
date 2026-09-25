# Salvage Seas v0.04 — first-person seaside shop visual preview

The first-person shop now uses the purchased **Stylized Fantasy Interior** floor, walls, furniture, shelving, doorway, rug and light fittings. Its door opens onto an **outdoor seaside dock**, with a broad sea basin, two walkable quays, a small workshop, a physical boat to board, and a seaport town along the shore. The underlying prototype interactions and timers still work. This pass is for judging how the art feels together; lighting, boat materials and port placement need further art direction.

## Controls

- WASD: walk; mouse: look; E: interact with the item under the crosshair.
- Esc: close an interaction panel or release/capture the mouse.
- P: pause/resume all game timers (day, ship, worktable and customers).
- F5: save; F9: load. Saves are stored in Godot's user data directory.
- Walk through the shop doorway into the open-air waterfront. Follow the west quay to the boat, cross its gangway, and walk through the doorway in the shore-side house to return to the shop.

## Loop

In the dock, approach the salvage chart on the west quay and press E to dispatch the ship to one of three Homewater regions. It pulls away, spends 3:30 on a run and returns with two Salvaged Junk Bundles, using one recovery in that region. Wait for it to finish docking, cross the gangway, look at a bundle in its hold and press E to carry it. Walk back to the west-quay worktable and press E to place the bundle in the machine. The machine takes 20 seconds to produce one each of Crude Wood, Oxidized Copper and Crumbling Stone Plates. Repeat for the second bundle. The ship cannot depart again until its cargo is collected. If you step into the sea, you return to the walkway.

Return to the shop; look at one of the eight slots on the two central shelves, press E and select stock. Look at the counter and open the store. Customers wander in and buy stocked items at their base prices.

A day lasts 10 real minutes; night lasts 5. No customers visit at night. Open the store again each morning. At night, the counter allows you to sleep early. Rarity definitions span Junk, Common, Uncommon, Rare, Epic, Legendary and Divinity; only Junk items exist so far.

This build does not yet contain room purchases, debt collection, requests, sale-price negotiation, character animation or a visual star map. The dock chart presents only the starter tile's regions. The purchased **Cyberpunk Boat** FBX references external TGA images that were absent from the files supplied, so its geometry uses a temporary dark painted material. Its hull is modeled; walking and cargo use invisible prototype collision. The seaport FBX included its image data, and the interior textures came from the separate private repository.

## Licensed art

The public game source does not redistribute purchased model files or textures. During local development, the optimized Godot assets belong under `assets/licensed/` (excluded by `.gitignore`). The art-ready Windows preview packages these materials into the game data file, as allowed for incorporated project distribution by the applicable Fab license. The public GitHub Actions build uses a procedural fallback because it has no access to the private asset repository; use the separately packaged **art preview** to judge the appearance.

Sources: [Stylized Fantasy Interior](https://www.fab.com/listings/2b25339f-8302-4a14-9b29-e7b17af29308), [Cyberpunk Boat](https://www.fab.com/listings/bcc484b6-69d7-4c99-884d-a8f1e993b6ab), [Medieval Seaport Town](https://www.fab.com/listings/273fce98-9e97-4e11-a791-381018ab4153). The 600 MB town FBX was trimmed to a small shoreline cluster for playable performance. The original purchased files stay in the private `Salvage-Seas-Licensed-Assets` repository and the owner's source package.

## Build

Open `project.godot` in Godot 4.5.1 and run. With `assets/licensed/` present, you will see the art preview; without it, the prototype blockout still runs. A GitHub Actions workflow tests the old data loop and new first-person loop, then exports a fallback Windows ZIP. The art preview is separately exported from a local checkout containing the privately supplied optimized assets.

The earlier interface test is still in `scenes/main.tscn` for reference, but it is no longer the main scene. See [GAME_DESIGN.md](GAME_DESIGN.md) for the longer-term design.
