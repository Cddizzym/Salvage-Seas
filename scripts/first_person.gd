extends Node3D

const DAY_SECONDS := 600.0
const NIGHT_SECONDS := 300.0
const SALVAGE_SECONDS := 210.0
const UNPACK_SECONDS := 20.0
const SAVE_PATH := "user://salvage_seas_first_person.json"
const ITEMS := {
	"bundle": {"name": "Salvaged Junk Bundle", "price": 4, "color": Color("#777369")},
	"wood": {"name": "Crude Wood", "price": 3, "color": Color("#8d603c")},
	"copper": {"name": "Oxidized Copper", "price": 5, "color": Color("#73a49b")},
	"stone": {"name": "Crumbling Stone Plates", "price": 4, "color": Color("#aaa69a")}
}
const RARITIES := ["Junk", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Divinity"]

var day := 1
var phase := "day"
var elapsed := 0.0
var paused := false
var money := 0
var room := "shop"
var shop_open := false
var stock := {"bundle": 0, "wood": 0, "copper": 0, "stone": 0}
var shelves := ["", "", "", "", "", "", "", ""]
var regions := {"Shore Wrecks": 3, "Drowned Market": 3, "Broken Jetty": 3}
var ship_region := ""
var ship_left := 0.0
var machine_left := 0.0
var customer_left := 0.0
var next_customer := 10.0
var customer_target := -1
var menu_open := false
var active_interaction := ""

var player: CharacterBody3D
var camera: Camera3D
var world: Node3D
var ceiling_light: OmniLight3D
var customer: Node3D
var ui: CanvasLayer
var clock_label: Label
var hint_label: Label
var notice_label: Label
var center_label: Label
var overlay: PanelContainer
var overlay_body: VBoxContainer
var shelf_anchors: Array[Node3D] = []
var shelf_goods: Array[Node3D] = []
var note_left := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	make_player()
	make_ui()
	build_room("shop")
	notice("Walk around the shop. The dock door leads to your ship and workshop.")

func material(hex: String, rough := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.roughness = rough
	return m

func box(parent: Node3D, pos: Vector3, size: Vector3, surface: Material, collision := false) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh_node.mesh = shape
	mesh_node.material_override = surface
	mesh_node.position = pos
	parent.add_child(mesh_node)
	if collision:
		var static_body := StaticBody3D.new()
		var hit := CollisionShape3D.new()
		var hit_shape := BoxShape3D.new()
		hit_shape.size = size
		hit.shape = hit_shape
		static_body.add_child(hit)
		mesh_node.add_child(static_body)
	return mesh_node

func make_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	add_child(player)
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.55
	collider.shape = capsule
	collider.position.y = 0.78
	player.add_child(collider)
	camera = Camera3D.new()
	camera.position.y = 1.56
	camera.fov = 75.0
	camera.current = true
	player.add_child(camera)

func build_room(destination: String) -> void:
	room = destination
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	world = Node3D.new()
	world.name = "Room"
	add_child(world)
	shelf_anchors.clear()
	shelf_goods.clear()
	customer = null
	var timber := material("#765134")
	var timber_light := material("#a97a45")
	var timber_dark := material("#422e26")
	var plaster := material("#dfd5b7")
	var brass := material("#cf9e4c", 0.45)
	var sea := material("#344e52")
	var rug := material("#8f3f37")
	var metal := material("#526267", 0.3)

	box(world, Vector3(0, -0.13, 0), Vector3(12.0, 0.25, 10.0), timber, true)
	for i in range(12):
		box(world, Vector3(-5.5 + i, 0.015, 0), Vector3(0.025, 0.012, 10.0), timber_dark)
	box(world, Vector3(0, 2.1, -5), Vector3(12, 4.2, 0.24), plaster, true)
	box(world, Vector3(-6, 2.1, 0), Vector3(0.24, 4.2, 10), plaster, true)
	box(world, Vector3(6, 2.1, 0), Vector3(0.24, 4.2, 10), plaster, true)
	# A doorway is left in the south wall rather than painting an unusable door onto it.
	box(world, Vector3(-3.6, 2.1, 5), Vector3(4.8, 4.2, 0.24), plaster, true)
	box(world, Vector3(3.6, 2.1, 5), Vector3(4.8, 4.2, 0.24), plaster, true)
	box(world, Vector3(0, 3.75, 5), Vector3(2.4, 0.9, 0.24), timber_light, true)
	for x in [-5.85, 5.85]:
		box(world, Vector3(x, 2.1, 0), Vector3(0.16, 4.2, 9.7), timber_light)
	for z in [-4.85, 4.85]:
		box(world, Vector3(0, 2.1, z), Vector3(11.7, 4.2, 0.12), timber_light)
	box(world, Vector3(0, 4.15, 0), Vector3(12.0, 0.18, 10.0), timber_dark)
	box(world, Vector3(0, 0.018, 0.25), Vector3(3.3, 0.02, 3.7), rug)
	box(world, Vector3(0, 0.028, 0.25), Vector3(2.95, 0.023, 3.35), material("#b68455"))
	box(world, Vector3(0, 0.033, 0.25), Vector3(2.65, 0.025, 3.05), rug)

	# Tall windows with visible frames give the small shop a horizon and some warmth.
	for x in [-3.4, 0.0, 3.4]:
		box(world, Vector3(x, 2.45, -4.86), Vector3(2.2, 1.75, 0.08), sea)
		box(world, Vector3(x, 2.45, -4.79), Vector3(0.08, 1.75, 0.08), brass)
		box(world, Vector3(x, 2.45, -4.78), Vector3(2.2, 0.075, 0.08), brass)
		box(world, Vector3(x, 1.56, -4.72), Vector3(2.4, 0.09, 0.24), timber_light)
	ceiling_light = OmniLight3D.new()
	ceiling_light.position = Vector3(0, 3.35, 0.0)
	ceiling_light.light_color = Color("#ffd8a2")
	ceiling_light.light_energy = 2.1
	ceiling_light.omni_range = 14
	world.add_child(ceiling_light)
	box(world, Vector3(0, 3.65, 0), Vector3(0.9, 0.22, 0.9), brass)
	var ambience := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#344d54")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d7c8ab")
	env.ambient_light_energy = 0.55
	ambience.environment = env
	world.add_child(ambience)

	if room == "shop":
		build_shop(timber_dark, timber_light, brass)
		player.position = Vector3(0, 0.05, 3.5)
		player.rotation.y = 0.0
	else:
		build_dock(timber_dark, timber_light, brass, metal, sea)
		player.position = Vector3(0, 0.05, 3.5)
		player.rotation.y = 0.0
	camera.rotation.x = 0.0
	refresh_goods()
	refresh_customer()
	update_ui()

func tag(node: Node3D, kind: String) -> void:
	node.set_meta("interaction", kind)

func build_shop(wood: Material, trim: Material, brass: Material) -> void:
	# Counter at the front, two four-slot shelves in the centre, extra empty fixtures at the walls.
	var counter := box(world, Vector3(-3.8, 0.55, 3.3), Vector3(2.7, 1.1, 1.1), wood, true)
	var counter_top := box(world, Vector3(-3.8, 1.17, 3.3), Vector3(2.95, 0.16, 1.3), trim, true)
	tag(counter_top, "counter")
	tag(counter, "counter")
	box(world, Vector3(-3.8, 1.3, 3.3), Vector3(0.3, 0.17, 0.3), brass)
	for shelf_index in range(2):
		var shelf_x := -2.0 if shelf_index == 0 else 2.0
		var fixture := Node3D.new()
		fixture.position = Vector3(shelf_x, 0.0, -0.85)
		fixture.name = "Shelf%d" % (shelf_index + 1)
		world.add_child(fixture)
		box(fixture, Vector3(0, 0.50, 0), Vector3(2.05, 1.0, 1.25), wood, true)
		box(fixture, Vector3(0, 1.07, 0), Vector3(2.25, 0.14, 1.45), trim)
		for row in range(2):
			for col in range(2):
				var index := shelf_index * 4 + row * 2 + col
				var anchor := Node3D.new()
				anchor.position = Vector3(-0.52 + col * 1.04, 1.2, -0.34 + row * 0.68)
				fixture.add_child(anchor)
				shelf_anchors.append(anchor)
				var slot := box(anchor, Vector3.ZERO, Vector3(0.9, 0.018, 0.55), material("#cba16e"), true)
				tag(slot, "slot:%d" % index)
				box(anchor, Vector3(0, 0.015, 0.28), Vector3(0.88, 0.035, 0.03), brass)
	for x in [-4.7, 4.7]:
		box(world, Vector3(x, 0.82, -2.0), Vector3(0.45, 1.6, 2.35), wood, true)
		for y in [0.35, 0.9, 1.5]:
			box(world, Vector3(x, y, -2.0), Vector3(0.6, 0.12, 2.5), trim)
	var doorway := box(world, Vector3(0, 2.45, 4.79), Vector3(2.1, 0.13, 0.12), brass)
	tag(doorway, "dock_door")
	# Reachable doorway trigger; the player can also walk into it.
	var threshold := box(world, Vector3(0, 0.08, 4.72), Vector3(2.1, 0.15, 0.45), trim)
	tag(threshold, "dock_door")
	if shop_open and customer_left > 0:
		refresh_customer()

func build_dock(wood: Material, trim: Material, brass: Material, metal: Material, sea: Material) -> void:
	var chart := box(world, Vector3(-4.6, 1.25, -2.7), Vector3(1.4, 2.1, 2.3), wood, true)
	var chart_face := box(world, Vector3(-3.85, 1.3, -2.7), Vector3(0.05, 1.4, 1.6), sea, true)
	tag(chart_face, "chart")
	tag(chart, "chart")
	var table := box(world, Vector3(1.65, 0.58, -2.75), Vector3(2.7, 1.15, 1.5), wood, true)
	var tabletop := box(world, Vector3(1.65, 1.2, -2.75), Vector3(3.0, 0.16, 1.7), trim, true)
	tag(tabletop, "machine")
	tag(table, "machine")
	var processor := box(world, Vector3(1.65, 1.36, -2.75), Vector3(0.9, 0.2, 0.7), metal, true)
	tag(processor, "machine")
	for i in range(3):
		box(world, Vector3(3.7, 0.3 + i * 0.58, -3.4), Vector3(0.85, 0.55, 0.7), wood, true)
	var hatch := box(world, Vector3(-2.6, 0.12, 0.7), Vector3(2.0, 0.2, 3.7), sea)
	tag(hatch, "chart")
	box(world, Vector3(-1.48, 0.2, 0.7), Vector3(0.12, 0.35, 3.8), brass)
	box(world, Vector3(-3.72, 0.2, 0.7), Vector3(0.12, 0.35, 3.8), brass)
	var doorway := box(world, Vector3(0, 0.08, 4.72), Vector3(2.1, 0.15, 0.45), trim)
	tag(doorway, "shop_door")
	box(world, Vector3(0, 2.4, 4.8), Vector3(2.1, 0.13, 0.12), brass)
	box(world, Vector3(2.6, 1.35, 3.8), Vector3(2.0, 0.75, 0.12), sea)
	box(world, Vector3(2.6, 1.35, 3.73), Vector3(2.15, 0.85, 0.05), brass)

func refresh_goods() -> void:
	for existing in shelf_goods:
		if is_instance_valid(existing):
			existing.queue_free()
	shelf_goods.clear()
	if room != "shop":
		return
	for i in range(shelves.size()):
		if shelves[i] == "":
			continue
		var item_id: String = shelves[i]
		var anchor: Node3D = shelf_anchors[i]
		var product := Node3D.new()
		product.name = ITEMS[item_id].name
		anchor.add_child(product)
		shelf_goods.append(product)
		var tint: Color = ITEMS[item_id].color
		var surface := StandardMaterial3D.new()
		surface.albedo_color = tint
		if item_id == "wood":
			box(product, Vector3(0, 0.18, 0), Vector3(0.67, 0.31, 0.26), surface, true)
			box(product, Vector3(0, 0.32, 0.14), Vector3(0.55, 0.2, 0.18), surface)
		elif item_id == "copper":
			box(product, Vector3(0, 0.18, 0), Vector3(0.42, 0.33, 0.37), surface, true)
			box(product, Vector3(0, 0.38, 0), Vector3(0.31, 0.1, 0.31), surface)
		elif item_id == "stone":
			for j in range(3):
				box(product, Vector3(0, 0.1 + j * 0.1, 0), Vector3(0.6, 0.08, 0.42), surface, true)
		else:
			box(product, Vector3(0, 0.23, 0), Vector3(0.56, 0.43, 0.43), surface, true)
			box(product, Vector3(0, 0.47, 0), Vector3(0.63, 0.05, 0.46), material("#c3a270"))
		tag(product, "slot:%d" % i)
		for child in product.get_children():
			if child is MeshInstance3D:
				tag(child, "slot:%d" % i)

func refresh_customer() -> void:
	if is_instance_valid(customer):
		customer.queue_free()
	customer = null
	if room != "shop" or customer_left <= 0 or not shop_open or phase != "day":
		return
	customer = Node3D.new()
	customer.name = "BrowsingCustomer"
	world.add_child(customer)
	box(customer, Vector3(0, 0.8, 0), Vector3(0.47, 0.95, 0.29), material("#526d72"))
	box(customer, Vector3(0, 1.5, 0), Vector3(0.34, 0.35, 0.32), material("#c7a68b"))
	box(customer, Vector3(-0.13, 0.21, 0), Vector3(0.13, 0.45, 0.15), material("#353d3c"))
	box(customer, Vector3(0.13, 0.21, 0), Vector3(0.13, 0.45, 0.15), material("#353d3c"))

func make_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var canvas := Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(canvas)
	clock_label = Label.new()
	clock_label.position = Vector2(22, 17)
	clock_label.add_theme_font_size_override("font_size", 21)
	clock_label.add_theme_color_override("font_color", Color("#f1ddb4"))
	canvas.add_child(clock_label)
	center_label = Label.new()
	center_label.text = "+"
	center_label.set_anchors_preset(Control.PRESET_CENTER)
	center_label.position = Vector2(-8, -10)
	center_label.add_theme_font_size_override("font_size", 25)
	center_label.add_theme_color_override("font_color", Color("#f4e7d4"))
	canvas.add_child(center_label)
	hint_label = Label.new()
	hint_label.anchor_top = 1.0
	hint_label.anchor_bottom = 1.0
	hint_label.anchor_left = 0.5
	hint_label.anchor_right = 0.5
	hint_label.position = Vector2(-350, -104)
	hint_label.custom_minimum_size = Vector2(700, 35)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 18)
	hint_label.add_theme_color_override("font_color", Color("#f1e1ba"))
	canvas.add_child(hint_label)
	notice_label = Label.new()
	notice_label.anchor_top = 1.0
	notice_label.anchor_bottom = 1.0
	notice_label.anchor_left = 0.5
	notice_label.anchor_right = 0.5
	notice_label.position = Vector2(-480, -61)
	notice_label.custom_minimum_size = Vector2(960, 36)
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_label.add_theme_font_size_override("font_size", 15)
	notice_label.add_theme_color_override("font_color", Color("#d9ddcf"))
	canvas.add_child(notice_label)
	overlay = PanelContainer.new()
	overlay.anchor_left = 0.5
	overlay.anchor_right = 0.5
	overlay.anchor_top = 0.5
	overlay.anchor_bottom = 0.5
	overlay.position = Vector2(-280, -200)
	overlay.custom_minimum_size = Vector2(560, 400)
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("#182a2deb")
	skin.border_color = Color("#bf9c61")
	skin.set_border_width_all(3)
	skin.set_corner_radius_all(12)
	skin.set_content_margin_all(23)
	overlay.add_theme_stylebox_override("panel", skin)
	overlay_body = VBoxContainer.new()
	overlay_body.add_theme_constant_override("separation", 10)
	overlay.add_child(overlay_body)
	canvas.add_child(overlay)
	overlay.visible = false
	update_ui()

func label(text_value: String, size := 18, color := Color("#e9dfc7")) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func button(text_value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size.y = 39
	b.add_theme_font_size_override("font_size", 16)
	b.pressed.connect(callback)
	return b

func open_menu(kind: String) -> void:
	active_interaction = kind
	menu_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	center_label.visible = false
	for c in overlay_body.get_children():
		overlay_body.remove_child(c)
		c.queue_free()
	overlay.visible = true
	if kind == "chart":
		overlay_body.add_child(label("HOMEWATER  •  SALVAGE CHART", 25, Color("#f1d5a0")))
		overlay_body.add_child(label("Your starter ship cannot reach the other star-linked world tiles yet.", 15))
		if ship_left > 0:
			overlay_body.add_child(label("Ship at %s: %s remaining" % [ship_region, time_left(ship_left)], 17))
		for raw_name in regions.keys():
			var name := str(raw_name)
			var b := button("%s   •   %d recoveries left   •   3:30" % [name, regions[name]], launch_ship.bind(name))
			b.disabled = ship_left > 0 or regions[name] <= 0 or phase == "night"
			overlay_body.add_child(b)
	elif kind == "machine":
		overlay_body.add_child(label("DOCK WORKTABLE", 25, Color("#f1d5a0")))
		overlay_body.add_child(label("Salvaged Junk Bundles: %d" % stock.bundle))
		overlay_body.add_child(label("Unpack one bundle into Crude Wood, Oxidized Copper and Crumbling Stone Plates. Takes 20 seconds of game time.", 16))
		if machine_left > 0:
			overlay_body.add_child(label("Machine running: %s remaining" % time_left(machine_left)))
		var b := button("Unpack a Bundle", start_machine)
		b.disabled = machine_left > 0 or stock.bundle <= 0
		overlay_body.add_child(b)
	elif kind.begins_with("slot:"):
		var index := int(kind.trim_prefix("slot:"))
		overlay_body.add_child(label("SHELF %d  •  SLOT %d" % [int(index / 4) + 1, index % 4 + 1], 25, Color("#f1d5a0")))
		if shelves[index] != "":
			var item_id: String = shelves[index]
			overlay_body.add_child(label("%s  •  Junk  •  Base price £%d" % [ITEMS[item_id].name, ITEMS[item_id].price]))
			overlay_body.add_child(button("Return to Storage", return_from_shelf.bind(index)))
		else:
			overlay_body.add_child(label("Choose an item to stock at its base price:", 16))
			for raw_id in ITEMS.keys():
				var id := str(raw_id)
				var b := button("%s × %d  •  £%d" % [ITEMS[id].name, stock[id], ITEMS[id].price], stock_shelf.bind(index, id))
				b.disabled = stock[id] <= 0
				overlay_body.add_child(b)
	elif kind == "counter":
		overlay_body.add_child(label("SHOP COUNTER", 25, Color("#f1d5a0")))
		overlay_body.add_child(label("Money: £%d   •   Day %d" % [money, day]))
		overlay_body.add_child(label("Customers browse and buy stocked items at their base prices. The shop must be reopened each morning.", 16))
		if phase == "day":
			overlay_body.add_child(button("Close Shop" if shop_open else "Open Shop", toggle_shop))
		else:
			overlay_body.add_child(button("Sleep Until Morning", sleep))
	overlay_body.add_spacer(false)
	overlay_body.add_child(button("Back [Esc]", close_menu))

func close_menu() -> void:
	menu_open = false
	overlay.visible = false
	center_label.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func notice(value: String) -> void:
	notice_label.text = value
	note_left = 5.0

func launch_ship(region_name: String) -> void:
	if ship_left > 0 or regions[region_name] <= 0 or phase == "night": return
	ship_region = region_name
	ship_left = SALVAGE_SECONDS
	notice("Your ship departed for %s. Return in 3:30." % region_name)
	close_menu()

func start_machine() -> void:
	if machine_left > 0 or stock.bundle <= 0: return
	stock.bundle -= 1
	machine_left = UNPACK_SECONDS
	notice("The worktable is unpacking a Salvaged Junk Bundle.")
	close_menu()

func stock_shelf(index: int, id: String) -> void:
	if shelves[index] != "" or stock[id] <= 0: return
	stock[id] -= 1
	shelves[index] = id
	refresh_goods()
	notice("Stocked %s for £%d." % [ITEMS[id].name, ITEMS[id].price])
	close_menu()

func return_from_shelf(index: int) -> void:
	var id: String = shelves[index]
	if id == "": return
	stock[id] += 1
	shelves[index] = ""
	refresh_goods()
	notice("Returned %s to storage." % ITEMS[id].name)
	close_menu()

func toggle_shop() -> void:
	if phase != "day": return
	shop_open = not shop_open
	if shop_open:
		next_customer = min(next_customer, 6.0)
	notice("Shop open. Customers will browse the shelves." if shop_open else "Shop closed.")
	close_menu()

func sleep() -> void:
	if phase == "night":
		new_day()
	close_menu()

func new_day() -> void:
	phase = "day"
	elapsed = 0
	day += 1
	shop_open = false
	customer_left = 0
	next_customer = 10
	refresh_customer()
	save_game(false)
	notice("Day %d. Open the shop at the counter when ready." % day)

func time_left(seconds: float) -> String:
	var s := int(ceil(maxf(0.0, seconds)))
	return "%d:%02d" % [int(s / 60), s % 60]

func update_ui() -> void:
	if not is_instance_valid(clock_label): return
	var remaining := (DAY_SECONDS - elapsed) if phase == "day" else (NIGHT_SECONDS - elapsed)
	clock_label.text = "DAY %d   •   %s %s   •   £%d%s" % [day, phase.to_upper(), time_left(remaining), money, "   •   PAUSED" if paused else ""]
	if menu_open: return
	var target := look_target()
	var message_text := ""
	if target.begins_with("slot:"):
		var index := int(target.trim_prefix("slot:"))
		message_text = "[E] %s" % (ITEMS[shelves[index]].name if shelves[index] != "" else "Stock empty shelf slot")
	elif target == "counter": message_text = "[E] Shop counter"
	elif target == "chart": message_text = "[E] Homewater salvage chart"
	elif target == "machine": message_text = "[E] Unpacking worktable"
	elif target.ends_with("_door"): message_text = "[E] Enter %s" % ("Dock" if target == "dock_door" else "Shop")
	hint_label.text = message_text if message_text != "" else "WASD move  •  Mouse look  •  E interact  •  P pause  •  F5 save  •  F9 load  •  Esc release mouse"

func look_target() -> String:
	if not is_instance_valid(camera) or menu_open: return ""
	var state := get_world_3d().direct_space_state
	var start := camera.global_position
	var end := start - camera.global_transform.basis.z * 3.6
	var query := PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [player.get_rid()]
	var result := state.intersect_ray(query)
	if result.is_empty(): return ""
	var hit: Node = result.collider
	while hit != null and hit != world:
		if hit.has_meta("interaction"):
			return str(hit.get_meta("interaction"))
		hit = hit.get_parent()
	return ""

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * 0.0024)
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0024, -1.35, 1.35)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if menu_open: close_menu()
				else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
			KEY_P:
				paused = not paused
				notice("Time paused: customers, ship and machine are stopped." if paused else "Time resumed.")
			KEY_F5: save_game()
			KEY_F9: load_game()
			KEY_E:
				if not menu_open:
					var target := look_target()
					if target == "dock_door": build_room("dock")
					elif target == "shop_door": build_room("shop")
					elif target != "": open_menu(target)
	if event is InputEventMouseButton and event.pressed and not menu_open and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or menu_open: return
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input.y -= 1
	if Input.is_key_pressed(KEY_S): input.y += 1
	if Input.is_key_pressed(KEY_A): input.x -= 1
	if Input.is_key_pressed(KEY_D): input.x += 1
	input = input.normalized()
	var direction := (player.global_transform.basis * Vector3(input.x, 0, input.y)).normalized()
	player.velocity.x = direction.x * 3.4
	player.velocity.z = direction.z * 3.4
	player.velocity.y -= 18.0 * delta
	player.move_and_slide()
	if player.position.z > 4.85 and absf(player.position.x) < 1.15:
		build_room("dock" if room == "shop" else "shop")

func _process(delta: float) -> void:
	if note_left > 0:
		note_left -= delta
		if note_left <= 0: notice_label.text = ""
	if not paused:
		elapsed += delta
		if phase == "day" and elapsed >= DAY_SECONDS:
			phase = "night"
			elapsed = 0
			shop_open = false
			customer_left = 0
			refresh_customer()
			notice("Nightfall. No more customers. Use the workshop, stock shelves, or sleep.")
		elif phase == "night" and elapsed >= NIGHT_SECONDS:
			new_day()
		if ship_left > 0:
			ship_left -= delta
			if ship_left <= 0:
				ship_left = 0
				regions[ship_region] = maxi(0, regions[ship_region] - 1)
				stock.bundle += 2
				notice("Ship returned from %s with 2 Junk Bundles." % ship_region)
				ship_region = ""
		if machine_left > 0:
			machine_left -= delta
			if machine_left <= 0:
				machine_left = 0
				stock.wood += 1
				stock.copper += 1
				stock.stone += 1
				notice("Bundle unpacked into wood, copper and stone.")
		if phase == "day" and shop_open:
			if customer_left > 0:
				customer_left -= delta
				if is_instance_valid(customer):
					var progress := 1.0 - customer_left / 15.0
					customer.position = Vector3(lerpf(0.0, 1.4, progress), 0, lerpf(4.4, -0.2, progress))
				if customer_left <= 0: finish_customer()
			else:
				next_customer -= delta
				if next_customer <= 0:
					customer_left = 15.0
					refresh_customer()
					notice("A customer has come in to browse.")
	update_ui()

func finish_customer() -> void:
	customer_left = 0
	next_customer = randf_range(12, 20)
	var occupied: Array[int] = []
	for i in range(shelves.size()):
		if shelves[i] != "": occupied.append(i)
	if not occupied.is_empty():
		var i: int = occupied.pick_random()
		var id: String = shelves[i]
		money += ITEMS[id].price
		shelves[i] = ""
		refresh_goods()
		notice("A customer bought %s for £%d." % [ITEMS[id].name, ITEMS[id].price])
	else: notice("The customer found nothing stocked and left.")
	refresh_customer()

func save_game(show_notice := true) -> void:
	var data := {"day": day, "phase": phase, "elapsed": elapsed, "money": money,
		"stock": stock, "shelves": shelves, "regions": regions,
		"ship_region": ship_region, "ship_left": ship_left, "machine_left": machine_left,
		"shop_open": shop_open, "next_customer": next_customer}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		if show_notice: notice("Game saved.")
	elif show_notice: notice("Save failed.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		notice("No save found.")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		notice("Save could not be read.")
		return
	day = maxi(1, int(data.get("day", 1)))
	phase = str(data.get("phase", "day"))
	elapsed = float(data.get("elapsed", 0))
	money = int(data.get("money", 0))
	for id in ITEMS.keys(): stock[id] = maxi(0, int(data.get("stock", {}).get(id, 0)))
	var saved_slots: Array = data.get("shelves", [])
	for i in range(shelves.size()):
		var id := str(saved_slots[i]) if i < saved_slots.size() else ""
		shelves[i] = id if ITEMS.has(id) else ""
	for id in regions.keys(): regions[id] = maxi(0, int(data.get("regions", {}).get(id, 3)))
	ship_region = str(data.get("ship_region", ""))
	ship_left = maxf(0, float(data.get("ship_left", 0))) if regions.has(ship_region) else 0
	machine_left = maxf(0, float(data.get("machine_left", 0)))
	shop_open = bool(data.get("shop_open", false)) and phase == "day"
	next_customer = float(data.get("next_customer", 10))
	customer_left = 0
	close_menu()
	build_room(room)
	notice("Game loaded.")
