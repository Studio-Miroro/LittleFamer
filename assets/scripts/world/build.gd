class_name BuildManager extends Node

@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var shadow: ShadowManager = get_tree().current_scene.shadow

enum GridModes { DESTROY, FARMING, FERTILIZER, WATERING, HARVESTING, BUILD, TERRAIN }

const MAX_DISTANCE: int = 250
const MAX_GRID_SIZE: Vector2i = Vector2i(16, 16)

const HOUSE_POSITION: Vector2i = Vector2i(19, 2)
const MAILBOX_POSITION: Vector2i = Vector2i(16, 2)
const STORAGE_POSITION: Vector2i = Vector2i(22, 2)

const HOUSE_SHADOW: CompressedTexture2D = preload("res://assets/resources/buildings/house/shadow.png")
const MAILBOX_SHADOW: CompressedTexture2D = preload("res://assets/resources/buildings/mailbox/shadow.png")
const STORAGE_SHADOW: CompressedTexture2D = preload("res://assets/resources/buildings/storage/shadow.png")

const HOUSE: PackedScene = preload("res://assets/nodes/buildings/house.tscn")
const MAILBOX: PackedScene = preload("res://assets/nodes/buildings/mailbox.tscn")
const STORAGE: PackedScene = preload("res://assets/nodes/buildings/storage.tscn")
const GRID: PackedScene = preload("res://assets/nodes/buildings/grid.tscn")

var buildings: Dictionary


func _ready():
	set_process_input(false)

	var house: Node2D = HOUSE.instantiate()
	var mailbox: Node2D = MAILBOX.instantiate()
	var storage: Node2D = STORAGE.instantiate()

	if (house && mailbox && storage) && (house is Node2D && mailbox is Node2D && storage is Node2D):
		buildings[HOUSE.get_state().get_node_name(0)] = house
		buildings[MAILBOX.get_state().get_node_name(0)] = mailbox
		buildings[STORAGE.get_state().get_node_name(0)] = storage

		house.set_position(tilemap.map_to_local(HOUSE_POSITION))
		mailbox.set_position(tilemap.map_to_local(MAILBOX_POSITION))
		storage.set_position(tilemap.map_to_local(STORAGE_POSITION))

		self.add_child(house)
		self.add_child(mailbox)
		self.add_child(storage)

		var house_sprite: Sprite2D = house.get_node("Sprite2D")
		var mailbox_sprite: Sprite2D = mailbox.get_node("Sprite2D")
		var storage_sprite: Sprite2D = storage.get_node("Sprite2D")

		if house_sprite && house_sprite is Sprite2D:
			shadow.add_shadow(HOUSE_SHADOW, house.position + house_sprite.position)

		if mailbox_sprite && house_sprite is Sprite2D:
			shadow.add_shadow(MAILBOX_SHADOW, mailbox.position + mailbox_sprite.position)

		if storage_sprite && house_sprite is Sprite2D:
			shadow.add_shadow(STORAGE_SHADOW, storage.position + storage_sprite.position)


func _input(event: InputEvent) -> void:
	if (
		((event is InputEventMouseButton) && (event.pressed) && ((event.button_index) == MOUSE_BUTTON_RIGHT))
		|| ((event.is_action_pressed("esc")) && (buildings.has(GRID.get_state().get_node_name(0))))
	):
		if buildings.has(GRID.get_state().get_node_name(0)):
			var grid: Node2D = buildings[GRID.get_state().get_node_name(0)]
			if grid:
				self.remove_child(grid)
				grid.queue_free()
				buildings.erase(GRID.get_state().get_node_name(0))
				UIManager.add_ui(UIManager.MENUS.HUD)
				set_process_input(false)


func grid_add(mode: BuildManager.GridModes, size: Vector2i = Vector2i(1, 1)) -> Node2D:
	var grid: Node2D = null

	if !(size.x > 0 && size.y > 0) || !(size.x <= MAX_GRID_SIZE.x && size.y <= MAX_GRID_SIZE.y):
		printerr("Incorrect grid size.")
		return

	if !(buildings.has(GRID.get_state().get_node_name(0))):
		var node = GRID.instantiate()
		buildings[node.name] = node
		node.size = size
		node.mode = mode
		self.add_child(node)
		grid = node
		set_process_input(true)

	return grid


func build_add(node: Node2D, shadow_texture: CompressedTexture2D, position: Vector2i) -> Node2D:
	var building: Node2D = null

	if !is_instance_valid(tilemap):
		printerr("TileMap is NULL.")
		return

	if !node:
		printerr("Node is NULL.")
		return

	node.set_position(tilemap.map_to_local(position))
	self.add_child(node, true)

	building = node
	buildings[node.name] = node

	var sprite: Node = building.get_node("Sprite2D")
	if sprite && sprite is Sprite2D:
		self.shadow.add_shadow(shadow_texture, building.position + sprite.position)

	return building
