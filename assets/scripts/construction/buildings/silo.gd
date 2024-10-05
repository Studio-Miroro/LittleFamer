extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var pause:Control = get_node("/root/"+main+"/UI/Inveractive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var sprite:Sprite2D = $Sprite2D

var max_distance:int = 250
var level:int = 1
var object:Dictionary = {
	1: {
		"caption" = tr("silo.caption"),
		"description" = tr("silo.description"),
		"default" = load("res://assets/resources/buildings/silo/level_1/object_0.png"),
		"hover" = load("res://assets/resources/buildings/silo/level_1/object_1.png"),
	},
}

func _ready():
	update()

func update():
	if object.has(level):
		if object[level].has("default"):
			sprite.texture = object[level]["default"]
		else:
			data.debug("There is no key at index " + str(level), "error")
	else:
		data.debug("Index " + str(level) + " is not in the dictionary.", "error")

func _change_sprite(type:bool):
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < max_distance:
			if object.has(level):
				_check_sprite("hover")
				var level_text = tr("object.level")
				tip.tooltip(
					str(object[level]["caption"]) + "\n" +
					str(object[level]["description"]) + "\n" +
					str(level_text) + str(level)
					)
	else:
		_check_sprite("default")
		tip.tooltip("")

func _check_sprite(key:String):
	if object.has(level):
		if object[level].has(key):
			if object[level][key] is CompressedTexture2D:
				sprite.texture = object[level][key]
			else:
				data.debug("The specified sprite cannot be installed.", "error")
		else:
			data.debug("There is no key at index " + str(level), "error")
	else:
		data.debug("Index " + str(level) + " is not in the dictionary.", "error")

func get_data():
	if object.has(level):
		return {"level": level}

func load_data(obj_level:int) -> void:
	self.level = obj_level
	update()

func _on_collision_mouse_entered():
	if !blur.state:
		_change_sprite(true)

func _on_collision_mouse_exited():
	_change_sprite(false)
