# Salvage Seas — Shopkeeping Game Concept

Status: updated 25 September 2026. The v0.01 interface prototype did not meet the desired feel. v0.02 introduced a first-person 3D shop; v0.03 fixes mouse look and replaces the tiny dock with a large open basin and manual ship unloading. The wider design remains in development.

## v0.03 dock and cargo handling

The dock is now mostly open water, flanked by narrow walkable quays. A small unpacking workshop occupies part of the west quay. The starter vessel moors next to that quay, accessible over a gangway. Dispatch it from the salvage chart; it visibly departs, spends 3 minutes 30 seconds on its trip, and visibly returns. Recoveries are loaded into its cargo hold, not teleported to storage. Walk aboard, pick up one Salvaged Junk Bundle, walk back over the gangway, and place it in the unpacking machine. Repeat for the second bundle. The 20-second machine timer produces the three starter materials. The ship cannot leave while uncollected cargo remains aboard.

## Visual and interaction correction

The reference is a compact, cosy shop with wood floors, shelves, counter, windows and customers occupying a real room. Although that reference uses an overhead view, the chosen direction for Salvage Seas is first-person. The player walks with WASD, looks with the mouse, and interacts with actual shelves, a dock chart, a worktable and a counter. The HUD is minimal, with contextual menus only when interacting. This is an early 3D blockout, not finished art; the reference's warmth and level of detail require a later visual pass.

## Confirmed direction

A 2D shopkeeping simulator inspired by the shop management appeal of Recettear, with maritime salvage as a supporting activity. The player recovers loot, gradually acquires machines that turn salvage into better merchandise, fulfils customer requests, and pays off a debt.

Development belongs in **Cddizzym/Salvage-Seas** (plural). The separate **Salvage-Sea** project is not the destination for this game. Similar concepts may be reused, but existing code and assets must be inspected before deciding what to carry over.

## Core promise

Run a small waterfront shop and workshop. A battered object hauled from a wreck can be sold immediately, dismantled for materials, or restored into a valuable product. The central decisions concern what to stock, what to make, what to charge, and how much money to reinvest before the next debt payment.

Salvage gives the shop interesting stock and a reason to venture out. The shop should remain the main source of progression and the main focus of play.

## Proposed daily loop

1. Review available stock, customer requests, machine jobs, and the next debt deadline.
2. Choose how to spend limited daily time: obtain salvage, process goods, or open the shop.
3. Stock displays and set prices.
4. Serve customers, make sales, and fulfil accepted orders.
5. Review revenue, expenses, and debt; save and advance to the next day.

The prototype uses a real-time clock. Day lasts 10 minutes and night lasts 5 minutes. Customers only visit during the day, and the player must manually open the store each morning. Night remains useful for workshop work, stocking and item management. Pausing freezes the clock, customers, ship and all machines.

## Confirmed world and home structure

The world map uses star-linked territory tiles. The starter vessel can initially salvage only within the player's Homewater tile. Selecting an unlocked world tile zooms into a local map containing several limited salvage regions. Each successful trip depletes its chosen region by one recovery; events may replenish regions in a later version.

The player's home uses a room system. The Dock & Workshop and Shop are unlocked initially; in v0.02, the player walks through a doorway between them. A compact room selector may be useful later when the building grows. Additional rooms will eventually be purchased. The starting dock contains a small workshop and the player's ship.

The shop is tile based. The first version provides two fixed display shelves, each containing a 2×2 arrangement of four 1×1 item slots. Items may use larger footprints later.

## Proposed systems

### Shop and customers

Begin with one room, a counter, and a few fixed display slots. Customers choose goods based on interest, budget, and asking price. The player sets prices and completes transactions. Introduce simple counteroffers once basic sales are enjoyable; deeper haggling and customer relationships can follow.

Readable feedback should explain why an item sold or was rejected. Stocking and pricing should matter more than repeatedly clicking through identical dialogue.

### Salvage and inventory

The first salvage trip is an automated 3 minute 30 second expedition to a selected Homewater salvage region. It returns two Salvaged Junk Bundles. Direct ship control, cargo limits and a hold/release winch interaction remain later candidates.

Keep one shared item definition system for cargo, storage, displays, recipes, and requests. Transfers must never duplicate or lose items.

### Workshop and machines

Start with an unpacking table. It consumes one Salvaged Junk Bundle over 20 seconds of unpaused game time and returns one each of Crude Wood, Oxidized Copper and Crumbling Stone Plates. Later purchases could add a restoration bench, dismantler, furnace, woodworking station, or specialist apparatus. Machines consume specified inputs and real time to create outputs. Additional capacity, speed, and recipes give money useful purposes beyond debt.

### Items, values and rarities

Every item has a base value. Early customers buy stocked items at that base value; events and market variation will modify values later. The complete rarity ladder is:

1. Junk
2. Common
3. Uncommon
4. Rare
5. Epic
6. Legendary
7. Divinity

The first four items—Salvaged Junk Bundle, Crude Wood, Oxidized Copper and Crumbling Stone Plates—are Junk rarity.

Illustrative chains, not final content:

| Salvage | Processing | Product |
| --- | --- | --- |
| Damaged lantern | Restore at bench | Restored lantern |
| Scrap metal | Smelt, then fabricate | Metal fittings |
| Waterlogged timber | Dry, then shape | Wooden household goods |
| Broken instrument | Repair with spare parts | Navigational instrument |

Processing should usually improve value, but its time and material costs must make immediate sales a reasonable choice when cash is tight.

### Requests and debt

Customer requests specify an item, quantity, reward, and deadline. Acceptance is optional, and required goods must be reserved or clearly marked to prevent accidental sales.

Debt has visible instalments and deadlines. Early payments should teach planning without requiring perfect play. Proposed first failure rule: a clearly explained retry from the start of the payment period. The final failure system, payment amounts, and narrative explanation remain undecided.

### Progression

Progress from selling rough finds to restoring valuable merchandise, fulfilling specialist orders, and expanding shop and workshop capacity. Ship upgrades support sourcing; shop upgrades support the main business.

A darker maritime atmosphere is a proposed continuation of the earlier project's aesthetic. Setting, story, characters, and final art direction remain open.

## First playable target

Implemented v0.03 scope: a physical shop, an enlarged walkable dock around an open basin, a moored/departing/returning ship, manual one-at-a-time cargo carrying, three starter salvage regions accessed through a chart, four starter items, one unpacking machine, fixed base-price sales, two shelves with four physical slots each, simple wandering customers, a real-time day/night cycle, global pause, and save/load. The full visual star map, requests, debt payments, room purchases, larger item footprints and a broader economy are not yet implemented. The old v0.01 interface remains in the repository for reference but is not the playable starting scene.

Completion criteria:

- Recover an object and bring it into storage.
- Process an eligible object into a more valuable product.
- Place that product on display and sell it for the shown price.
- Complete a customer request with the correct inventory and money changes.
- Reach a debt deadline and see a clear success or failure outcome.
- Reload a save without losing inventory, machine progress, money, or deadline state.

Use placeholder art first. Defer combat, a large ocean, elaborate NPC schedules, multiplayer, extensive automation, and large recipe trees.

## Incremental build order

1. Shop foundation: movement/interactions, inventory, displays, customers, sales.
2. Supply loop: a small salvage outing and transfer into shop storage.
3. Workshop: one machine and a few recipes.
4. Business pressure: requests, day progression, debt, and save/load.
5. Playtest balance, improve presentation, and package a downloadable Windows build.

Keep each milestone small and playable. Record changes and known issues in the repository. Preserve the preference for downloadable builds as development proceeds; no build is produced by this concept document.

## Technical and budget approach

Engine selection is pending. Inspect the earlier prototype's technology and reusable systems before choosing between reuse and a new implementation. Prioritise a small offline, single-player desktop game with modular systems and data-driven items and recipes.

No live AI integration is needed for customers or game logic. Use authored dialogue and normal game rules, so playing the game does not consume model credits.

Development recommendation: GPT-6 Sol at Standard speed for routine implementation and fixes. Consider Astra for a difficult architectural decision or a stubborn bug after focused attempts. This is a workflow recommendation, not a guarantee of delivery time or total cost.

As checked on 25 September 2026, official Standard credit rates per million tokens are Sol: 50 input / 5 cached input / 250 output; Astra: 250 / 25 / 1,250. Actual task costs and included plan usage vary. Fast mode consumes credits at 2.5 times Standard for these models. Prefer small, explicit tasks and avoid speculative rewrites or generating final art before the loop works.

Sources:
- https://learn.chatgpt.com/docs/models
- https://learn.chatgpt.com/docs/pricing

## Decisions for the next design discussion

### Seaside visual prototype (v0.04)

The playable layout now places the Stylized Fantasy Interior shop inside a shore-side house. Walking through the shop's dock door moves the player to the open-air west quay; returning through the exterior house entrance moves them back to the shop. Water occupies the middle of a broad basin, with side walkways, a small workshop, a gangway and the salvage boat. A trimmed section of the Medieval Seaport Town supplies shoreline buildings. The supplied Cyberpunk Boat geometry replaces the blockout hull visually; its separate TGA textures are still missing, so it currently has a temporary patinated finish. Both shop and dock continue to use simple collision proxies for gameplay. Purchased sources live privately; the public repo contains fallback geometry and setup documentation.

Next visual pass: inspect the art preview in motion, adjust scale and camera height, and obtain the boat texture maps if available. Once the style is approved, align lighting and materials across the fantasy interior, medieval harbor and futuristic boat.

- How directly the player controls shop interactions and haggling.
- Whether salvage uses free sailing or compact selectable expeditions initially.
- Engine choice after inspecting the existing prototype.
- Debt tone and failure severity.
- Visual style and how much of the previous setting to carry forward.
