extends Control

@onready var blackout = get_node("/root/MainMenu/MainUI/Blackout")
@onready var sprite:TextureRect = $VBoxContainer/Sprite/ButtonSprite
@onready var caption:Label = $VBoxContainer/Label/Scroll/Label

func _on_button_pressed():
	blackout.blackout(true, 4)
	await get_tree().create_timer(1.25).timeout
	get_tree().quit()
