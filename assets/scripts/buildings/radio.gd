extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: Area2D = $Area2D


func _ready() -> void:
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
