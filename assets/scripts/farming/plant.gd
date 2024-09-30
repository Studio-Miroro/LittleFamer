extends Node2D

@onready var main_scene = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/" + main_scene)
@onready var pause:Control = get_node("/root/" + main_scene + "/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/" + main_scene + "/UI/Decorative/Blur")
@onready var tip:Control = get_node("/root/" + main_scene + "/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/" + main_scene + "/Tilemap")
@onready var grid:Node2D = get_node("/root/" + main_scene + "/Buildings/Grid")
@onready var collision:Area2D = get_node("/root/" + main_scene + "/Buildings/Grid/GridCollision")
@onready var sprite:Sprite2D = $Sprite2D
@onready var timer:Timer = $Timer

var crops:Object = Crops.new()
var plantID:int
var condition:int = phases.PLANTED
var fertilizer:int = fertilizers.NOTHING
var degree:int

enum phases {PLANTED,GROWING,INCREASED,DEAD}
enum fertilizers {NOTHING, COMPOST, HUMUS, MANURE}

func _process(_delta):
	if pause.paused:
		timer.set_paused(true)
	else:
		timer.set_paused(false)

func plant(id:int) -> void:
	plantID = id
	sprite.rect(id)
	
func set_fertilizer(type:int) -> void:
	match type:
		0:
			fertilizer = fertilizers.NOTHING
		1:
			fertilizer = fertilizers.COMPOST
		2:
			fertilizer = fertilizers.HUMUS
		3:
			fertilizer = fertilizers.MANURE
			
func check(id:int,pos:Vector2i) -> void:
	if !pause.paused:
		if collision.check_cell(pos, collision.farmland_layer)\
		and !collision.check_cell(pos, collision.watering_layer)\
		and condition != phases.DEAD:
			condition = phases.PLANTED
			await get_tree().create_timer(crops.crops["check_watering"]).timeout
			if degree < crops.crops[plantID]["mortality"]:
				degree += 1
			else:
				condition = phases.DEAD
			check(id,pos)

		elif collision.check_cell(pos, collision.farmland_layer)\
		and collision.check_cell(pos, collision.watering_layer)\
		and condition != phases.DEAD:
			condition = phases.GROWING
			set_fertilizer(randi_range(0,3))
			growth()

func growth() -> void:
	if condition == phases.GROWING:
		match fertilizer:
			fertilizers.NOTHING:
				timer.wait_time = randi_range(
					crops.crops[plantID]["growth_rate"] * 0.849,
					crops.crops[plantID]["growth_rate"]
				)
			fertilizers.COMPOST:
				timer.wait_time = randi_range(
					crops.crops[plantID]["growth_rate"] * 0.621,
					crops.crops[plantID]["growth_rate"] * 0.995
				)
			fertilizers.HUMUS:
				timer.wait_time = randi_range(
					crops.crops[plantID]["growth_rate"] * 0.431,
					crops.crops[plantID]["growth_rate"] * 0.894
				)
			fertilizers.MANURE:
				timer.wait_time = randi_range(
					crops.crops[plantID]["growth_rate"] * 0.332,
					crops.crops[plantID]["growth_rate"] * 0.792
				)
		timer.start()
	if condition == phases.INCREASED:
		timer.stop()

func get_data() -> Dictionary:
	return {
		"plantID": plantID,
		"degree": degree,
		"condition": condition,
		"fertilizer": fertilizer,
		"region_rect.x": sprite.region_rect.position.x,
		"region_rect.y": sprite.region_rect.position.y,
		"growth_level": sprite.level,
		"position": tilemap.local_to_map(global_position),
	}

func set_data(id:int, conditionID:int, degreeID:int, fertilizerID:int, region_rect_x:int, region_rect_y:int, level:int, pos:Vector2i) -> void:
	plantID = id
	condition = conditionID
	degree = degreeID
	fertilizer = fertilizerID
	sprite.region_rect.position.x = region_rect_x
	sprite.region_rect.position.y = region_rect_y
	sprite.level = level
	growth()
	check(plantID, pos)

func get_condition(condition_type:int) -> String:
	match condition_type:
		0:
			return tr("condition.planted")
		1:
			return tr("condition.thriving")
		2:
			return tr("condition.grown")
		3:
			return tr("condition.died")
		_:
			return ""

func get_fertilizer(fertilizer_type:int) -> String:
	match fertilizer_type:
		1:
			return tr("fertilizer.compost")
		2:
			return tr("fertilizer.humus")
		3:
			return tr("fertilizer.manure")
		_:
			return ""

func _on_collision_mouse_entered() -> void:
	if !blur.state\
	and grid.mode == grid.modes.NOTHING:
		if crops.crops.has(plantID):
			if crops.crops[plantID].has("caption"):
				if typeof(crops.crops[plantID]["caption"]) == TYPE_STRING:
					var plant_status = tr("plant_status")
					if fertilizer != fertilizers.NOTHING:
						var fertilized_plant = tr("fertilizer")
						tip.tooltip(
							crops.crops[plantID]["caption"] +"\n"+
							str(plant_status) + ": " + str(get_condition(condition)) +"\n"+
							str(fertilized_plant) + ": " + str(get_fertilizer(fertilizer))
						)
					else:
						tip.tooltip(
							crops.crops[plantID]["caption"] +"\n"+
							str(plant_status) + ": " + str(get_condition(condition))
						)
				else:
					data.debug("The 'caption' element is not a string type. Variant.type: " + str(typeof(crops.crops[plantID]["caption"])), "error")
			else:
				data.debug("The 'caption' element is missing.", "error")
		else:
			data.debug("Invalid ID: " + str(plantID), "error")
		
func _on_collision_mouse_exited() -> void:
	if !blur.state:
		tip.tooltip()

func check_node() -> bool:
	return true
