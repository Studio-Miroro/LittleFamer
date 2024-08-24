extends Control

@onready var main_scene = str(get_tree().root.get_child(1).name)

@onready var options:Control = get_node("/root/" + main_scene + "/User Interface/Windows/Options")
@onready var label:Label = $MarginContainer/Label
var page:PackedScene = load("res://assets/nodes/ui/windows/pause/options/sections/pages/graphic.tscn")

func set_text(text:String) -> void:
	label.text = text
	
func set_page(scene:PackedScene) -> void:
	self.page = scene

func _on_button_pressed() -> void:
	if options.menu:
		if (page != null and typeof(page) == TYPE_OBJECT):
			options.page(page)
