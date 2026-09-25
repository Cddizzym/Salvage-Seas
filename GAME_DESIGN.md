# Salvage Seas — Shopkeeping Game Concept

Status: initial design proposal, 25 September 2026. This document records the requested direction and proposes a small first playable scope; it does not describe implemented features.

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

Start with discrete activity periods rather than a demanding real-time clock. Exact day length, activity costs, and the balance between sailing and shop time remain playtest decisions.

## Proposed systems

### Shop and customers

Begin with one room, a counter, and a few fixed display slots. Customers choose goods based on interest, budget, and asking price. The player sets prices and completes transactions. Introduce simple counteroffers once basic sales are enjoyable; deeper haggling and customer relationships can follow.

Readable feedback should explain why an item sold or was rejected. Stocking and pricing should matter more than repeatedly clicking through identical dialogue.

### Salvage and inventory

Use short trips to a small salvage area. Recovered objects include saleable goods, damaged goods, and raw materials. Cargo capacity limits what comes home. A simple hold/release winch-tension interaction is a candidate inherited from the earlier concept, subject to inspecting the implementation.

Keep one shared item definition system for cargo, storage, displays, recipes, and requests. Transfers must never duplicate or lose items.

### Workshop and machines

Start with a restoration bench. Later purchases could add a dismantler, furnace, woodworking station, or specialist apparatus. Machines consume specified inputs and time to create outputs. Additional capacity, speed, and recipes give money useful purposes beyond debt.

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

Proposed scope: one shop, one short salvage location, about eight item types, one restoration machine, basic pricing and customers, one request template, one debt instalment, and save/load.

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

- How directly the player controls shop interactions and haggling.
- Whether salvage uses free sailing or compact selectable expeditions initially.
- Engine choice after inspecting the existing prototype.
- Debt tone and failure severity.
- Visual style and how much of the previous setting to carry forward.
