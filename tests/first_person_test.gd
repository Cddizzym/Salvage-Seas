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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(45, -30)
	game._input(motion)
	assert(game.player.rotation.y < -0.05)
	assert(game.camera.rotation.x > 0.05)
	game.build_room("dock")
	assert(game.room == "dock")
	assert(game.salvage_ship != null and game.gangway.visible)
	game.player.position = Vector3(-12.3, 0.05, 10.5)
	game.player.rotation.y = PI / 2.0
	game.camera.rotation.x = -0.21
	await physics_frame
	assert(game.look_target() == "chart")
	game.player.position = Vector3(-13.2, 0.05, 7.0)
	game.player.rotation.y = 0
	game.camera.rotation.x = -0.21
	await physics_frame
	assert(game.look_target() == "machine")
	game.launch_ship("Shore Wrecks")
	assert(game.ship_left == 210.0)
	assert(not game.gangway.visible)
	game.paused = true
	game._process(10.0)
	assert(game.ship_left == 210.0 and game.elapsed < 10.0)
	game.paused = false
	game.ship_left = 0.01
	game._process(0.02)
	assert(game.ship_cargo == 2 and game.stock.bundle == 0)
	assert(game.regions["Shore Wrecks"] == 2)
	game.ship_outbound_left = 0
	game.ship_arrival_left = 0
	game.update_ship_scene()
	assert(game.gangway.visible)
	game.player.position = Vector3(-10.6, 0.05, -3.0)
	await physics_frame
	game._physics_process(0.1)
	assert(game.player.position.y > -0.2)
	game.player.position = Vector3(-9.35, 0.05, -3.0)
	await physics_frame
	game._physics_process(0.1)
	assert(game.player.position.y > -0.2)
	game.player.position = Vector3(-7.75, 0.05, -0.3)
	game.player.rotation.y = 0
	game.camera.rotation.x = -0.72
	await physics_frame
	assert(game.look_target() == "ship_cargo")
	game.pick_up_cargo()
	assert(game.ship_cargo == 1 and game.carrying_bundle)
	game.save_game(false)
	game.carrying_bundle = false
	game.load_game()
	assert(game.carrying_bundle and game.ship_cargo == 1)
	game.start_machine()
	assert(not game.carrying_bundle)
	game.machine_left = 0.01
	game._process(0.02)
	assert(game.stock.bundle == 0 and game.stock.wood == 1)
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
	game.ship_cargo = 0
	game.load_game()
	assert(game.money == 5 and game.ship_cargo == 1)
	print("First-person shop loop passed")
	quit(0)
