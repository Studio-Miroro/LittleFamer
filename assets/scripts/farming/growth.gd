extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var plant = $".."
@onready var timer = $"../Timer"

var crops:Object = Crops.new()
var level:int

func _ready():
	if crops.crops.has("atlas"):
		if typeof(crops.crops["atlas"]) == TYPE_OBJECT\
		and texture is CompressedTexture2D:
			texture = texture
		else:
			data.debug("Atlas is not a CompressedTexture2D.", "error")
	else:
		data.debug("No atlas of crops.", "error")

func _process(_delta):
	if plant.plantID != 0:
		if level == crops.crops[plant.plantID]["growth_level"]\
		and plant.condition != plant.phases.GROWED:
			plant_increased()
	else:
		data.debug("Invalid variable index: " + str(plant.plantID), "error")
		remove_child(plant)
		queue_free()
		
func rect(id):
	if crops.crops[id].has("X")\
	and crops.crops[id].has("Y"):
		region_rect.position.x = crops.crops[id]['X']
		region_rect.position.y = crops.crops[id]['Y']
	else:
		data.debug("The X and Y coordinates cannot be determined.", "error")

func _on_timer_timeout() -> void:
	if level < crops.crops[plant.plantID]["growth_level"]:
		region_rect.position.x += 16
		level += 1
	else:
		plant_increased()

func plant_increased():
	plant.condition = plant.phases.GROWED
	timer.stop()
