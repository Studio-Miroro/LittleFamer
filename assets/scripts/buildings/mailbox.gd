extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var build: BuildManager = get_tree().current_scene.build
@onready var collision: Area2D = $Collision
@onready var sprite: Sprite2D = $Sprite2D

const TEXTURES: Dictionary = {
	0: preload("res://assets/resources/buildings/mailbox/spring.png"),
	1: preload("res://assets/resources/buildings/mailbox/summer.png"),
	2: preload("res://assets/resources/buildings/mailbox/autumn.png"),
	3: preload("res://assets/resources/buildings/mailbox/winter.png")
}

var mouse_entered: bool = false


func _ready() -> void:
	if !is_instance_valid(cycle):
		printerr("WorldCycle node is NULL.")
		return

	if !TEXTURES.is_empty() && sprite:
		sprite.texture = TEXTURES[cycle.season_id]

	if collision:
		collision.mouse_entered.connect(_collision_mouse_entered)
		collision.mouse_exited.connect(_collision_mouse_exited)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		&& mouse_entered
		&& event.pressed
		&& !UIManager.blur.state
		&& event.button_index == MOUSE_BUTTON_LEFT
	):
		UIManager.remove_ui(UIManager.get_ui(UIManager.MENUS.HUD.get_state().get_node_name(0)))
		UIManager.add_ui(UIManager.MENUS.MAILBOX)

		if sprite.material:
			sprite.material.set_shader_parameter("highligth", false)

		if UIManager.cursor:
			UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)


func _collision_mouse_entered() -> void:
	if !UIManager.get_ui("HUD"):
		return

	self.mouse_entered = true

	if sprite.material:
		sprite.material.set_shader_parameter("highligth", true)

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _collision_mouse_exited() -> void:
	self.mouse_entered = false

	if !UIManager.get_ui("HUD"):
		return

	if sprite.material:
		sprite.material.set_shader_parameter("highligth", false)

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
