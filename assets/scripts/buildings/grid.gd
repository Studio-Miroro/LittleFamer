extends Node2D

@onready var build: BuildManager = get_tree().current_scene.build
@onready var nature: NatureManager = get_tree().current_scene.nature
@onready var tilemap: TileMap = get_tree().current_scene.tilemap

const GRID_NORMAL: CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/grid/default.png")
const GRID_ERROR: CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/grid/error.png")

var mode: BuildManager.GridModes
var size: Vector2i = Vector2i(4, 4)
var layer_id: int = 0

var node: Dictionary = {}
var terrain: Array[int] = []


func _ready() -> void:
	if !is_instance_valid(build) || !is_instance_valid(tilemap) || !is_instance_valid(nature):
		printerr("BuildManager or TileMap or Nature is NULL: ", "\n\t", build, "\n\t", tilemap, "\n\t", nature)
		self.set_process(false)
		return

	update_grid()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		_action()


func _process(_delta: float) -> void:
	_movement()
	_collision_check()


func _movement() -> void:
	self.set_position(tilemap.map_to_local(tilemap.local_to_map(tilemap.get_global_mouse_position())))


func update_grid() -> void:
	if size.x > build.MAX_GRID_SIZE.x && size.y > build.MAX_GRID_SIZE.y:
		return

	if !self.get_children().is_empty():
		for child in self.get_children():
			self.remove_child(child)
			child.queue_free()

	for x in size.x:
		for y in size.y:
			var sprite: Sprite2D = Sprite2D.new()
			sprite.texture = GRID_ERROR
			sprite.set_position(Vector2i(x * 16, y * 16))
			self.add_child(sprite)


func _action() -> void:
	match mode:
		build.GridModes.DESTROY:
			for grid in self.get_children():
				if grid.texture == GRID_ERROR:
					return

				if tilemap.get_cell_source_id(self.layer_id, tilemap.local_to_map(grid.global_position)) != -1:
					tilemap.set_cells_terrain_connect(
						self.layer_id, [tilemap.local_to_map(grid.global_position)], 0, -1
					)

		build.GridModes.FARMING:
			var grid_positions: Array[Vector2i] = []

			for grid in self.get_children():
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& grid.texture != GRID_ERROR
				):
					grid_positions.append(tilemap.local_to_map(grid.global_position))

			if !grid_positions.is_empty():
				tilemap.set_cells_terrain_connect(tilemap.Layers.FARMLAND, grid_positions, 0, tilemap.Terrains.FARMING)
				SoundManager.play_sound("farming/farming")

		build.GridModes.FERTILIZER:
			pass

		build.GridModes.WATERING:
			var grid_positions: Array[Vector2i] = []

			for grid in self.get_children():
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& grid.texture != GRID_ERROR
				):
					grid_positions.append(tilemap.local_to_map(grid.global_position))

			if !grid_positions.is_empty():
				tilemap.set_cells_terrain_connect(tilemap.Layers.WATERING, grid_positions, 0, tilemap.Terrains.WATERING)

				SoundManager.play_sound("farming/watering")

		build.GridModes.HARVESTING:
			pass

		build.GridModes.BUILD:
			var grid_positions: Array[Vector2i] = []

			for grid in self.get_children():
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.BUILDING, tilemap.local_to_map(grid.global_position))
						!= -1
					)
					|| grid.texture == GRID_ERROR
				):
					grid_positions.clear()
					break

				grid_positions.append(tilemap.local_to_map(grid.global_position))

			if !grid_positions.is_empty():
				if !self.node.has("node"):
					printerr("Node for build is NULL.")
					return

				if build.build_add(
					self.node["node"].instantiate(), self.node["shadow"], tilemap.local_to_map(self.global_position)
				):
					for vector in grid_positions:
						tilemap.set_cell(
							tilemap.Layers.BUILDING, vector, tilemap.SourcesAtlas.GROUND, tilemap.NODE_COLLISION
						)
				else:
					printerr("Node is NULL.")

				SoundManager.play_sound("building/build")

		build.GridModes.TERRAIN:
			print("Hello, World!")


func _collision_check() -> void:
	if !is_instance_valid(build) && !is_instance_valid(tilemap):
		self.layer_id = -1
		return

	for grid in self.get_children():
		#! Мне все равно не нравится этот вариант перебора слоев...
		grid.texture = GRID_ERROR

		match mode:
			BuildManager.GridModes.DESTROY:
				if (
					tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(grid.global_position))
					!= -1
				):
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.WATERING
					return

				if (
					tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
					!= -1
				):
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.FARMLAND
					return

				if tilemap.get_cell_source_id(tilemap.Layers.NATURE, tilemap.local_to_map(grid.global_position)) != -1:
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.NATURE
					return

				if tilemap.get_cell_source_id(tilemap.Layers.ROAD, tilemap.local_to_map(grid.global_position)) != -1:
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.ROAD

			BuildManager.GridModes.FARMING:
				if (
					(tilemap.get_cell_source_id(tilemap.Layers.ROAD, tilemap.local_to_map(grid.global_position)) != -1)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap
						. get_cell_tile_data(tilemap.Layers.ROAD, tilemap.local_to_map(grid.global_position))
						. get_custom_data("can_place_dirt")
					)
				):
					grid.texture = GRID_NORMAL

			# 	BuildManager.GridModes.FERTILIZER:
			# 		self.layer_id = 1

			BuildManager.GridModes.WATERING:
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						!= -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(grid.global_position))
						== -1
					)
				):
					grid.texture = GRID_NORMAL

			# 	BuildManager.GridModes.HARVESTING:
			# 		self.layer_id = 1

			BuildManager.GridModes.BUILD:
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.BUILDING, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.NATURE, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.BORDERS, tilemap.local_to_map(grid.global_position))
						== -1
					)
				):
					grid.texture = GRID_NORMAL

			_:
				self.layer_id = -1
