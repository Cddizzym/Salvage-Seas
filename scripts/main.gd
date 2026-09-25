extends Control

const VERSION := "0.01"
const DAY_SECONDS := 600.0
const NIGHT_SECONDS := 300.0
const SALVAGE_SECONDS := 210.0
const UNPACK_SECONDS := 20.0
const SAVE_PATH := "user://salvage_seas_save.json"

const RARITIES := {
	"Junk": Color("#8d8b80"),
	"Common": Color("#d9d4c7"),
	"Uncommon": Color("#62b879"),
	"Rare": Color("#4f8ed8"),
	"Epic": Color("#a56bd3"),
	"Legendary": Color("#dd9b3d"),
	"Divinity": Color("#f4e59b")
}

const ITEMS := {
	"bundle": {"name": "Salvaged Junk Bundle", "rarity": "Junk", "value": 4},
	"wood": {"name": "Crude Wood", "rarity": "Junk", "value": 3},
	"copper": {"name": "Oxidized Copper", "rarity": "Junk", "value": 5},
	"stone": {"name": "Crumbling Stone Plates", "rarity": "Junk", "value": 4}
}

var day_number := 1
var phase := "day"
var phase_elapsed := 0.0
var game_paused := false
var coins := 0
var current_room := "dock"
var selected_item := ""
var shop_open := false

var inventory := {"bundle": 0, "wood": 0, "copper": 0, "stone": 0}
var shelves := ["", "", "", "", "", "", "", ""]

var ship_active := false
var ship_remaining := 0.0
var ship_region := ""
var salvage_regions := {"Shore Wrecks": 3, "Drowned Market": 3, "Broken Jetty": 3}

var machine_active := false
var machine_remaining := 0.0

var customer_active := false
var customer_progress := 0.0
var customer_spawn_remaining := 8.0
var customer_duration := 12.0

var top_time: Label
var top_coins: Label
var pause_button: Button
var content: VBoxContainer
var inventory_list: VBoxContainer
var room_drawer: VBoxContainer
var message_label: Label
var customer_marker: ColorRect
var customer_status: Label

func _ready() -> void:
	build_interface()
	show_room("dock")
	refresh_all()
	message("Welcome home. The dock, workshop and shop are yours—for now.")

func panel_style(color: Color, border := Color("#46565a"), width := 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.border_color = border
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func make_button(text_value: String, action: Callable, minimum := Vector2(150, 42)) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = minimum
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", panel_style(Color("#26383d")))
	button.add_theme_stylebox_override("hover", panel_style(Color("#365158"), Color("#91b5b4"), 2))
	button.add_theme_stylebox_override("pressed", panel_style(Color("#17282d")))
	button.pressed.connect(action)
	return button

func make_label(text_value: String, size := 18, color := Color("#d8dedb")) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#0d171a")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	var top := HBoxContainer.new()
	top.custom_minimum_size.y = 68
	top.add_theme_constant_override("separation", 18)
	top.add_theme_stylebox_override("panel", panel_style(Color("#152529"), Color("#6c7773"), 0))
	var top_panel := PanelContainer.new()
	top_panel.add_child(top)
	root.add_child(top_panel)

	var title := make_label("SALVAGE SEAS", 28, Color("#e8d9a9"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top_time = make_label("", 18)
	top.add_child(top_time)
	top_coins = make_label("", 18, Color("#e4bd64"))
	top.add_child(top_coins)
	pause_button = make_button("Pause", toggle_pause, Vector2(110, 40))
	top.add_child(pause_button)
	top.add_child(make_button("Save", save_game, Vector2(80, 40)))
	top.add_child(make_button("Load", load_game, Vector2(80, 40)))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	root.add_child(body)

	var rooms_panel := PanelContainer.new()
	rooms_panel.custom_minimum_size.x = 190
	rooms_panel.add_theme_stylebox_override("panel", panel_style(Color("#111f23"), Color("#304147"), 1))
	room_drawer = VBoxContainer.new()
	room_drawer.add_theme_constant_override("separation", 8)
	rooms_panel.add_child(room_drawer)
	body.add_child(rooms_panel)
	room_drawer.add_child(make_label("HOUSE ROOMS", 15, Color("#8ba4a5")))
	room_drawer.add_child(make_button("⚓  Dock & Workshop", func(): show_room("dock"), Vector2(165, 46)))
	room_drawer.add_child(make_button("▦  Shop", func(): show_room("shop"), Vector2(165, 46)))
	room_drawer.add_child(make_button("✦  World Map", func(): show_room("world"), Vector2(165, 46)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	room_drawer.add_child(spacer)
	room_drawer.add_child(make_label("Unlocked rooms\n• Dock\n• Shop\n\nMore rooms can be purchased later.", 13, Color("#819194")))

	var center_panel := PanelContainer.new()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.add_theme_stylebox_override("panel", panel_style(Color("#142125"), Color("#304147"), 1))
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	center_panel.add_child(content)
	body.add_child(center_panel)

	var inventory_panel := PanelContainer.new()
	inventory_panel.custom_minimum_size.x = 280
	inventory_panel.add_theme_stylebox_override("panel", panel_style(Color("#111f23"), Color("#304147"), 1))
	var inv_box := VBoxContainer.new()
	inv_box.add_theme_constant_override("separation", 8)
	inventory_panel.add_child(inv_box)
	body.add_child(inventory_panel)
	inv_box.add_child(make_label("STORAGE", 18, Color("#e8d9a9")))
	inv_box.add_child(make_label("Select an item, then click an empty shelf slot. Click a stocked slot to return it.", 13, Color("#9aabaa")))
	inventory_list = VBoxContainer.new()
	inventory_list.add_theme_constant_override("separation", 6)
	inv_box.add_child(inventory_list)

	var footer := PanelContainer.new()
	footer.custom_minimum_size.y = 52
	footer.add_theme_stylebox_override("panel", panel_style(Color("#101c20"), Color("#35464a"), 1))
	message_label = make_label("", 14, Color("#b8c9c5"))
	footer.add_child(message_label)
	root.add_child(footer)

func clear_content() -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	customer_marker = null
	customer_status = null

func show_room(room: String) -> void:
	current_room = room
	clear_content()
	if room == "dock":
		build_dock()
	elif room == "shop":
		build_shop()
	else:
		build_world_map()
	refresh_all()

func room_heading(name: String, subtitle: String) -> void:
	content.add_child(make_label(name, 30, Color("#e7d7a4")))
	content.add_child(make_label(subtitle, 14, Color("#91a7a7")))

func build_dock() -> void:
	room_heading("Dock & Workshop", "A salt-dark loading room built directly above your private berth.")
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	content.add_child(columns)

	var dock_card := PanelContainer.new()
	dock_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock_card.add_theme_stylebox_override("panel", panel_style(Color("#182a2e"), Color("#537077"), 2))
	var dock_box := VBoxContainer.new()
	dock_box.add_theme_constant_override("separation", 12)
	dock_card.add_child(dock_box)
	columns.add_child(dock_card)
	dock_box.add_child(make_label("PRIVATE DOCK", 22, Color("#a8ced0")))
	dock_box.add_child(make_label("Your starter salvage vessel can work only within the home tile.", 15))
	var ship_label := make_label(ship_status_text(), 17, Color("#d6c38c"))
	ship_label.name = "ShipStatus"
	dock_box.add_child(ship_label)
	var ship_bar := ProgressBar.new()
	ship_bar.name = "ShipProgress"
	ship_bar.max_value = SALVAGE_SECONDS
	ship_bar.value = SALVAGE_SECONDS - ship_remaining if ship_active else 0
	ship_bar.custom_minimum_size.y = 24
	dock_box.add_child(ship_bar)
	dock_box.add_child(make_button("Open World Map", func(): show_room("world")))

	var workshop_card := PanelContainer.new()
	workshop_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workshop_card.add_theme_stylebox_override("panel", panel_style(Color("#211f1b"), Color("#766b52"), 2))
	var work_box := VBoxContainer.new()
	work_box.add_theme_constant_override("separation", 12)
	workshop_card.add_child(work_box)
	columns.add_child(workshop_card)
	work_box.add_child(make_label("UNPACKING TABLE", 22, Color("#d8c59b")))
	work_box.add_child(make_label("Breaks one Salvaged Junk Bundle into Crude Wood, Oxidized Copper and Crumbling Stone Plates.", 15))
	var machine_label := make_label(machine_status_text(), 17, Color("#d6c38c"))
	machine_label.name = "MachineStatus"
	work_box.add_child(machine_label)
	var machine_bar := ProgressBar.new()
	machine_bar.name = "MachineProgress"
	machine_bar.max_value = UNPACK_SECONDS
	machine_bar.value = UNPACK_SECONDS - machine_remaining if machine_active else 0
	machine_bar.custom_minimum_size.y = 24
	work_box.add_child(machine_bar)
	var unpack := make_button("Unpack Bundle (20 sec)", start_unpacking)
	unpack.name = "UnpackButton"
	work_box.add_child(unpack)

func build_shop() -> void:
	room_heading("The Shop", "A narrow tiled room facing the harbour road. Open it when you are ready for customers.")
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 12)
	content.add_child(controls)
	var open_button := make_button("Close Store" if shop_open else "Open Store", toggle_shop, Vector2(180, 44))
	open_button.name = "OpenStoreButton"
	controls.add_child(open_button)
	customer_status = make_label(customer_text(), 16, Color("#a9c8bf"))
	customer_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(customer_status)
	if phase == "night":
		controls.add_child(make_button("Sleep Until Morning", begin_new_day, Vector2(190, 44)))

	var floor := PanelContainer.new()
	floor.name = "ShopFloor"
	floor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	floor.custom_minimum_size.y = 460
	floor.add_theme_stylebox_override("panel", tiled_floor_style())
	content.add_child(floor)
	var floor_box := VBoxContainer.new()
	floor_box.add_theme_constant_override("separation", 18)
	floor.add_child(floor_box)
	var aisle := Control.new()
	aisele_setup(aisle)
	floor_box.add_child(aisle)

	var shelf_row := HBoxContainer.new()
	shelf_row.alignment = BoxContainer.ALIGNMENT_CENTER
	shelf_row.add_theme_constant_override("separation", 38)
	floor_box.add_child(shelf_row)
	for shelf_index in range(2):
		var shelf_panel := PanelContainer.new()
		shelf_panel.add_theme_stylebox_override("panel", panel_style(Color("#352b22"), Color("#876d4e"), 3))
		var shelf_box := VBoxContainer.new()
		shelf_box.add_child(make_label("DISPLAY SHELF %d" % (shelf_index + 1), 16, Color("#d9bd83")))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 5)
		grid.add_theme_constant_override("v_separation", 5)
		shelf_box.add_child(grid)
		shelf_panel.add_child(shelf_box)
		shelf_row.add_child(shelf_panel)
		for local_slot in range(4):
			var slot_index := shelf_index * 4 + local_slot
			var item_id: String = shelves[slot_index]
			var slot_text := "Empty 1×1 Slot"
			if item_id != "":
				var item: Dictionary = ITEMS[item_id]
				slot_text = "%s\n£%d • %s" % [item.name, item.value, item.rarity]
			var slot := make_button(slot_text, func(index := slot_index): shelf_clicked(index), Vector2(190, 86))
			if item_id != "":
				slot.add_theme_color_override("font_color", RARITIES[ITEMS[item_id].rarity])
			grid.add_child(slot)

func aisele_setup(aisle: Control) -> void:
	aisle.custom_minimum_size = Vector2(0, 110)
	var road := ColorRect.new()
	road.position = Vector2(35, 46)
	road.size = Vector2(750, 12)
	road.color = Color("#536064")
	aisle.add_child(road)
	customer_marker = ColorRect.new()
	customer_marker.name = "CustomerMarker"
	customer_marker.size = Vector2(28, 42)
	customer_marker.color = Color("#a7c5b2")
	customer_marker.position = Vector2(35, 26)
	customer_marker.visible = customer_active
	aisle.add_child(customer_marker)
	var door := make_label("DOOR", 12, Color("#7f9999"))
	door.position = Vector2(8, 70)
	aisle.add_child(door)
	var counter := make_label("COUNTER", 12, Color("#7f9999"))
	counter.position = Vector2(735, 70)
	aisle.add_child(counter)

func tiled_floor_style() -> StyleBoxFlat:
	var style := panel_style(Color("#243033"), Color("#536266"), 2)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	return style

func build_world_map() -> void:
	room_heading("World Chart", "Salvage waters are arranged into star-linked tiles. Your starter ship is restricted to Homewater.")
	var map_area := Control.new()
	map_area.custom_minimum_size = Vector2(850, 580)
	map_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(map_area)
	var positions := [Vector2(330, 220), Vector2(330, 25), Vector2(555, 110), Vector2(555, 330), Vector2(330, 420), Vector2(105, 330), Vector2(105, 110)]
	var names := ["HOMEWATER\nYour Tile", "Northern Shoals\nLocked", "Glasswater\nLocked", "Ember Coast\nLocked", "Deep South\nLocked", "Grey Expanse\nLocked", "Old Current\nLocked"]
	for i in range(7):
		var tile := make_button(names[i], func(index := i): world_tile_clicked(index), Vector2(190, 100))
		tile.position = positions[i]
		if i > 0:
			tile.disabled = true
		map_area.add_child(tile)
	var hint := make_label("Click HOMEWATER to inspect its salvage regions.", 15, Color("#d5c181"))
	hint.position = Vector2(330, 340)
	map_area.add_child(hint)

func world_tile_clicked(index: int) -> void:
	if index == 0:
		build_homewater_map()

func build_homewater_map() -> void:
	clear_content()
	room_heading("Homewater Tile", "Your legal salvage territory. Each marked region has a limited number of recoveries.")
	content.add_child(make_button("← Back to World Chart", func(): show_room("world"), Vector2(190, 42)))
	var regions := HBoxContainer.new()
	regions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	regions.alignment = BoxContainer.ALIGNMENT_CENTER
	regions.add_theme_constant_override("separation", 18)
	content.add_child(regions)
	for raw_region_name in salvage_regions.keys():
		var region_name := str(raw_region_name)
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(250, 260)
		card.add_theme_stylebox_override("panel", panel_style(Color("#172a30"), Color("#4f747d"), 2))
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 13)
		card.add_child(box)
		regions.add_child(card)
		box.add_child(make_label(region_name.to_upper(), 19, Color("#aed0d2")))
		box.add_child(make_label("Junk salvage region\nRemaining recoveries: %d" % salvage_regions[region_name], 15))
		var send := make_button("Send Ship\n3 min 30 sec", start_salvage.bind(region_name), Vector2(210, 70))
		send.disabled = ship_active or salvage_regions[region_name] <= 0 or phase == "night"
		box.add_child(send)
	if ship_active:
		content.add_child(make_label(ship_status_text(), 17, Color("#d8c58d")))

func refresh_all(refresh_items := true) -> void:
	if not is_instance_valid(top_time):
		return
	top_time.text = "%s • Day %d • %s" % [phase.capitalize(), day_number, clock_text()]
	top_coins.text = "£%d" % coins
	pause_button.text = "Resume" if game_paused else "Pause"
	if refresh_items:
		refresh_inventory()
	if current_room == "dock":
		var ship_label := content.find_child("ShipStatus", true, false) as Label
		var ship_bar := content.find_child("ShipProgress", true, false) as ProgressBar
		var machine_label := content.find_child("MachineStatus", true, false) as Label
		var machine_bar := content.find_child("MachineProgress", true, false) as ProgressBar
		var unpack_button := content.find_child("UnpackButton", true, false) as Button
		if ship_label: ship_label.text = ship_status_text()
		if ship_bar: ship_bar.value = SALVAGE_SECONDS - ship_remaining if ship_active else 0
		if machine_label: machine_label.text = machine_status_text()
		if machine_bar: machine_bar.value = UNPACK_SECONDS - machine_remaining if machine_active else 0
		if unpack_button: unpack_button.disabled = machine_active or inventory.bundle <= 0
	if current_room == "shop" and customer_status:
		customer_status.text = customer_text()

func refresh_inventory() -> void:
	if not is_instance_valid(inventory_list):
		return
	for child in inventory_list.get_children():
		inventory_list.remove_child(child)
		child.queue_free()
	for raw_item_id in ITEMS.keys():
		var item_id := str(raw_item_id)
		var item: Dictionary = ITEMS[item_id]
		var prefix := "▶ " if selected_item == item_id else ""
		var button := make_button("%s%s × %d\n%s • Base £%d" % [prefix, item.name, inventory[item_id], item.rarity, item.value], select_item.bind(item_id), Vector2(240, 64))
		button.disabled = inventory[item_id] <= 0
		button.add_theme_color_override("font_color", RARITIES[item.rarity])
		inventory_list.add_child(button)
	var rarity_title := make_label("RARITIES", 14, Color("#81999a"))
	inventory_list.add_child(rarity_title)
	for rarity in RARITIES.keys():
		inventory_list.add_child(make_label("• " + rarity, 13, RARITIES[rarity]))

func select_item(item_id: String) -> void:
	selected_item = item_id if selected_item != item_id else ""
	refresh_all()

func shelf_clicked(index: int) -> void:
	if shelves[index] != "":
		var returned: String = shelves[index]
		inventory[returned] += 1
		shelves[index] = ""
		message("Returned %s to storage." % ITEMS[returned].name)
	elif selected_item != "" and inventory[selected_item] > 0:
		shelves[index] = selected_item
		inventory[selected_item] -= 1
		message("Stocked %s at its base price of £%d." % [ITEMS[selected_item].name, ITEMS[selected_item].value])
		if inventory[selected_item] <= 0:
			selected_item = ""
	else:
		message("Select an item from storage first.")
	show_room("shop")

func toggle_pause() -> void:
	game_paused = not game_paused
	message("Time paused. Ships, machines and customers are waiting." if game_paused else "Time resumed.")
	refresh_all()

func toggle_shop() -> void:
	if phase == "night":
		message("No customers come at night. Use the quiet hours or sleep.")
		return
	shop_open = not shop_open
	if shop_open:
		customer_spawn_remaining = min(customer_spawn_remaining, 8.0)
		message("The shop is open. Customers will wander in when something is stocked.")
	else:
		message("The shop is closed.")
	show_room("shop")

func start_salvage(region: String) -> void:
	if ship_active or salvage_regions[region] <= 0 or phase == "night":
		return
	ship_active = true
	ship_remaining = SALVAGE_SECONDS
	ship_region = region
	message("Your ship departed for %s. It will return in 3 minutes 30 seconds." % region)
	build_homewater_map()

func finish_salvage() -> void:
	ship_active = false
	salvage_regions[ship_region] = max(0, salvage_regions[ship_region] - 1)
	inventory.bundle += 2
	message("The ship returned from %s with 2 Salvaged Junk Bundles." % ship_region)
	ship_region = ""
	refresh_all()

func start_unpacking() -> void:
	if machine_active or inventory.bundle <= 0:
		return
	inventory.bundle -= 1
	machine_active = true
	machine_remaining = UNPACK_SECONDS
	message("The unpacking table is processing one Salvaged Junk Bundle.")
	refresh_all()

func finish_unpacking() -> void:
	machine_active = false
	inventory.wood += 1
	inventory.copper += 1
	inventory.stone += 1
	message("Bundle unpacked: 1 Crude Wood, 1 Oxidized Copper and 1 Crumbling Stone Plates.")
	refresh_all()

func spawn_customer() -> void:
	if not shop_open or phase != "day" or customer_active:
		return
	customer_active = true
	customer_progress = 0.0
	customer_duration = randf_range(10.0, 14.0)
	message("A customer has entered and is browsing the shelves.")

func finish_customer() -> void:
	customer_active = false
	var stocked: Array[int] = []
	for i in range(shelves.size()):
		if shelves[i] != "":
			stocked.append(i)
	if stocked.is_empty():
		message("The customer left because the shelves were empty.")
	else:
		var shelf_index: int = stocked.pick_random()
		var item_id: String = shelves[shelf_index]
		coins += ITEMS[item_id].value
		shelves[shelf_index] = ""
		message("Sold %s for its base price of £%d." % [ITEMS[item_id].name, ITEMS[item_id].value])
	customer_spawn_remaining = randf_range(18.0, 30.0)
	if current_room == "shop":
		show_room("shop")
	else:
		refresh_all()

func begin_night() -> void:
	phase = "night"
	phase_elapsed = 0.0
	shop_open = false
	if customer_active:
		customer_active = false
		customer_spawn_remaining = 8.0
	message("Night has fallen. Customers stop coming; you have five quiet minutes before morning.")
	if current_room == "shop":
		show_room("shop")

func begin_new_day() -> void:
	phase = "day"
	phase_elapsed = 0.0
	day_number += 1
	shop_open = false
	customer_active = false
	customer_spawn_remaining = 8.0
	message("Day %d begins. Press Open Store when you are ready." % day_number)
	save_game(false)
	show_room(current_room)

func clock_text() -> String:
	var total_minutes: int
	if phase == "day":
		total_minutes = 8 * 60 + int((phase_elapsed / DAY_SECONDS) * 12.0 * 60.0)
	else:
		total_minutes = 20 * 60 + int((phase_elapsed / NIGHT_SECONDS) * 5.0 * 60.0)
	return "%02d:%02d" % [int(total_minutes / 60) % 24, total_minutes % 60]

func ship_status_text() -> String:
	if not ship_active:
		return "Ship moored and ready."
	return "Salvaging %s • %s remaining" % [ship_region, duration_text(ship_remaining)]

func machine_status_text() -> String:
	if not machine_active:
		return "Table idle."
	return "Unpacking bundle • %s remaining" % duration_text(machine_remaining)

func customer_text() -> String:
	if phase == "night":
		return "Night: no customers."
	if not shop_open:
		return "Store closed."
	if customer_active:
		return "A customer is browsing…"
	return "Waiting for the next customer."

func duration_text(seconds: float) -> String:
	var whole: int = max(0, int(ceil(seconds)))
	return "%d:%02d" % [int(whole / 60), whole % 60]

func message(text_value: String) -> void:
	if is_instance_valid(message_label):
		message_label.text = text_value

func _process(delta: float) -> void:
	if game_paused:
		return
	phase_elapsed += delta
	if phase == "day" and phase_elapsed >= DAY_SECONDS:
		begin_night()
	elif phase == "night" and phase_elapsed >= NIGHT_SECONDS:
		begin_new_day()
	if ship_active:
		ship_remaining -= delta
		if ship_remaining <= 0.0:
			finish_salvage()
	if machine_active:
		machine_remaining -= delta
		if machine_remaining <= 0.0:
			finish_unpacking()
	if shop_open and phase == "day":
		if customer_active:
			customer_progress += delta
			if customer_progress >= customer_duration:
				finish_customer()
		else:
			customer_spawn_remaining -= delta
			if customer_spawn_remaining <= 0.0:
				spawn_customer()
	if current_room == "shop" and is_instance_valid(customer_marker):
		customer_marker.visible = customer_active
		if customer_active:
			var travel: float = clamp(customer_progress / customer_duration, 0.0, 1.0)
			customer_marker.position.x = lerp(35.0, 750.0, travel)
	refresh_all(false)

func save_game(show_message := true) -> void:
	var data := {
		"version": VERSION, "day_number": day_number, "phase": phase, "phase_elapsed": phase_elapsed,
		"coins": coins, "inventory": inventory, "shelves": shelves, "shop_open": shop_open,
		"ship_active": ship_active, "ship_remaining": ship_remaining, "ship_region": ship_region,
		"salvage_regions": salvage_regions, "machine_active": machine_active, "machine_remaining": machine_remaining,
		"customer_spawn_remaining": customer_spawn_remaining
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		if show_message: message("Game saved.")
	elif show_message:
		message("Could not save the game.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		message("No save file exists yet.")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		message("The save file could not be read.")
		return
	day_number = int(data.get("day_number", 1))
	phase = str(data.get("phase", "day"))
	phase_elapsed = float(data.get("phase_elapsed", 0.0))
	coins = int(data.get("coins", 0))
	inventory.merge(data.get("inventory", {}), true)
	var loaded_shelves: Array = data.get("shelves", [])
	for i in range(min(shelves.size(), loaded_shelves.size())):
		shelves[i] = str(loaded_shelves[i])
	shop_open = bool(data.get("shop_open", false))
	ship_active = bool(data.get("ship_active", false))
	ship_remaining = float(data.get("ship_remaining", 0.0))
	ship_region = str(data.get("ship_region", ""))
	salvage_regions.merge(data.get("salvage_regions", {}), true)
	machine_active = bool(data.get("machine_active", false))
	machine_remaining = float(data.get("machine_remaining", 0.0))
	customer_spawn_remaining = float(data.get("customer_spawn_remaining", 8.0))
	customer_active = false
	message("Game loaded.")
	show_room(current_room)
