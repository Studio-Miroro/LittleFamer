extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var collision: Area2D = $Collision
@onready var sprite: Sprite2D = $Sprite2D

const TEXTURES: Dictionary = {
	0: preload("res://assets/resources/buildings/house/spring.png"),
	1: preload("res://assets/resources/buildings/house/summer.png"),
	2: preload("res://assets/resources/buildings/house/autumn.png"),
	3: preload("res://assets/resources/buildings/house/winter.png")
}


func _ready() -> void:
	if !is_instance_valid(cycle):
		printerr("WorldCycle node is NULL.")
		return

	if !TEXTURES.is_empty() && sprite:
		sprite.texture = TEXTURES[cycle.season_id]

	if collision:
		collision.mouse_entered.connect(_collision_mouse_entered)
		collision.mouse_exited.connect(_collision_mouse_exited)


func _collision_mouse_entered() -> void:
	if !UIManager.get_ui("HUD"):
		return

	if sprite.material:
		sprite.material.set_shader_parameter("highligth", true)

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _collision_mouse_exited() -> void:
	if !UIManager.get_ui("HUD"):
		return

	if sprite.material:
		sprite.material.set_shader_parameter("highligth", false)

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
