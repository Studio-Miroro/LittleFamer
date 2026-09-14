extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var build: BuildManager = get_tree().current_scene.build
@onready var collision: Area2D = $Collision
@onready var sprite: Sprite2D = $Sprite2D

const TEXTURES: Dictionary = {
	0: preload("res://assets/resources/buildings/storage/spring/sprite.png"),
	1: preload("res://assets/resources/buildings/storage/summer/sprite.png"),
	2: preload("res://assets/resources/buildings/storage/autumn/sprite.png"),
	3: preload("res://assets/resources/buildings/storage/winter/sprite.png")
}


func _ready() -> void:
	if !is_instance_valid(cycle):
		printerr("WorldCycle node is NULL.")
		return

	if !is_instance_valid(build):
		printerr("BuildManager node is NULL.")
		return

	if !TEXTURES.is_empty() && sprite:
		sprite.texture = TEXTURES[cycle.season_id]

	if collision:
		collision.input_pickable = true
		collision.input_event.connect(
			func(_viewport: Node, event: InputEvent, _index: int) -> void:
				if (
					!build.buildings.has("Grid")
					&& event is InputEventMouseButton
					&& event.button_index == MOUSE_BUTTON_LEFT
					&& !UIManager.blur.state
					&& event.pressed
				):
					UIManager.remove_ui(UIManager.get_ui(UIManager.MENUS.HUD.get_state().get_node_name(0)))
					UIManager.add_ui(UIManager.MENUS.INVENTORY)
					UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
					sprite.material.set_shader_parameter("highligth", false)
		)

		collision.mouse_entered.connect(_collision_mouse_entered)
		collision.mouse_exited.connect(_collision_mouse_exited)


func _collision_mouse_entered() -> void:
	if !UIManager.get_ui("HUD"):
		return

	if sprite.material:
		sprite.material.set_shader_parameter("highligth", true)
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _collision_mouse_exited() -> void:
	if !UIManager.get_ui("HUD"):
		return

	if sprite.material:
		sprite.material.set_shader_parameter("highligth", false)
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
