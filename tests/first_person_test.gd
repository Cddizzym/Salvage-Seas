extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene := load("res://scenes/first_person.tscn") as PackedScene
	assert(scene != null)
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	assert(game.room == "shop")
	assert(game.shelf_anchors.size() == 8)
	assert(game.RARITIES == ["Junk", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Divinity"])
	assert(game.DAY_SECONDS == 600.0 and game.NIGHT_SECONDS == 300.0)
	game.build_room("dock")
	assert(game.room == "dock")
	game.player.position = Vector3(-2.5, 0.05, -2.7)
	game.player.rotation.y = PI / 2.0
	game.camera.rotation.x = -0.12
	await physics_frame
	assert(game.look_target() == "chart")
	game.player.position = Vector3(1.65, 0.05, -0.4)
	game.player.rotation.y = 0
	game.camera.rotation.x = -0.21
	await physics_frame
	assert(game.look_target() == "machine")
	game.launch_ship("Shore Wrecks")
	assert(game.ship_left == 210.0)
	game.paused = true
	game._process(10.0)
	assert(game.ship_left == 210.0 and game.elapsed < 10.0)
	game.paused = false
	game.ship_left = 0.01
	game._process(0.02)
	assert(game.stock.bundle == 2)
	assert(game.regions["Shore Wrecks"] == 2)
	game.start_machine()
	game.machine_left = 0.01
	game._process(0.02)
	assert(game.stock.bundle == 1 and game.stock.wood == 1)
	assert(game.stock.copper == 1 and game.stock.stone == 1)
	game.build_room("shop")
	game.player.position = Vector3(-3.8, 0.05, 1.7)
	game.player.rotation.y = PI
	game.camera.rotation.x = -0.27
	await physics_frame
	assert(game.look_target() == "counter")
	game.stock_shelf(0, "copper")
	assert(game.stock.copper == 0 and game.shelves[0] == "copper")
	game.player.position = Vector3(-2.52, 0.05, 1.45)
	game.player.rotation.y = 0
	game.camera.rotation.x = -0.12
	await physics_frame
	assert(game.look_target().begins_with("slot:"))
	game.shop_open = true
	game.finish_customer()
	assert(game.money == 5 and game.shelves[0] == "")
	game.save_game(false)
	game.money = 0
	game.load_game()
	assert(game.money == 5)
	print("First-person shop loop passed")
	quit(0)
