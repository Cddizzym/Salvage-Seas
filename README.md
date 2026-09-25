# Salvage Seas v0.01

A 2D shopkeeping and maritime salvage prototype built with Godot 4.5.1.

## Current playable loop

1. Open the World Map and select the unlocked Homewater tile.
2. Send the starter ship to one of three limited salvage regions. A run takes 3 minutes 30 seconds of unpaused game time.
3. Return to the Dock & Workshop and unpack Salvaged Junk Bundles at the 20-second unpacking table.
4. Select items in storage and stock the two 2×2 display shelves.
5. Open the shop. Customers wander to the shelves and buy one item at its base price.
6. Manage a 10-minute day and 5-minute customer-free night. The store must be opened manually each morning.

The room drawer currently contains the Dock & Workshop, Shop, and World Map. Room purchasing, additional world tiles, fluctuating values, debt, events, and advanced item sizes are later systems.

## Controls

The prototype is mouse driven. Use the Pause button to freeze the day clock, salvage vessel, workshop machine, and customers together. Save and Load use Godot's local user data folder.

## Items and rarities

The implemented starter items are Salvaged Junk Bundle, Crude Wood, Oxidized Copper, and Crumbling Stone Plates. All are Junk rarity. The complete rarity ladder is present in the data model: Junk, Common, Uncommon, Rare, Epic, Legendary, and Divinity.

## Development

Open the project in Godot 4.5.1 and run `scenes/main.tscn`. GitHub Actions checks the prototype loop and produces a Windows ZIP after pushes to `main`.

See [GAME_DESIGN.md](GAME_DESIGN.md) for the broader design direction.
