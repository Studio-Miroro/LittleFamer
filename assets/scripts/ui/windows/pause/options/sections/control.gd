extends Control

@onready var main_scene = str(get_tree().root.get_child(1).name)

@onready var options:Control = get_node("/root/" + main_scene + "/User Interface/Windows/Options")
@onready var label:Label = $MarginContainer/Label
var page:PackedScene = load("res://assets/nodes/buildings/animal stall.tscn")

func _on_button_pressed():
	if options.menu:
		if (page != null and typeof(page) == TYPE_OBJECT):
			options.page(page)
