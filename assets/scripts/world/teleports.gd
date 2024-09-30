extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")
@onready var grid:Node2D = get_node("/root/"+main+ "/ConstructionManager/Grid")

var teleporting:bool

func _input(event) -> void:
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& teleporting\
	&& grid.mode == grid.modes.NOTHING:
		teleport()

func teleport() -> void:
	blackout.blackout(true)
	match main:
		"Farm":
			var path:String = "res://levels/village.tscn"
			data.gamesave()
			GameLoader.loading(false)
			blackout.change_scene(path)

		"Village":
			var path:String = "res://levels/farm.tscn"
			GameLoader.loading(true)
			data.file_save(data.paths.world, "nature")
			data.file_save(data.paths.player, "player")
			blackout.change_scene(path)

		_:
			data.debug("Unknown name of the game scene: "+str(main), "error")

func _on_area_2d_mouse_entered():
	teleporting = true

func _on_area_2d_mouse_exited():
	teleporting = false
