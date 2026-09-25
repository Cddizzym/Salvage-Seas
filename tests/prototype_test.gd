extends SceneTree

func _initialize() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	assert(scene != null)
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame

	assert(game.DAY_SECONDS == 600.0)
	assert(game.NIGHT_SECONDS == 300.0)
	assert(game.SALVAGE_SECONDS == 210.0)
	assert(game.RARITIES.keys() == ["Junk", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Divinity"])

	game.start_salvage("Shore Wrecks")
	game.ship_remaining = 0.01
	game._process(0.02)
	assert(game.inventory.bundle == 2)
	assert(game.salvage_regions["Shore Wrecks"] == 2)

	game.start_unpacking()
	game.machine_remaining = 0.01
	game._process(0.02)
	assert(game.inventory.bundle == 1)
	assert(game.inventory.wood == 1)
	assert(game.inventory.copper == 1)
	assert(game.inventory.stone == 1)

	game.selected_item = "copper"
	game.shelf_clicked(0)
	game.shop_open = true
	game.customer_active = true
	game.customer_duration = 0.01
	game.customer_progress = 0.0
	game._process(0.02)
	assert(game.coins == 5)
	assert(game.shelves[0] == "")

	print("Salvage Seas prototype tests passed")
	quit(0)

