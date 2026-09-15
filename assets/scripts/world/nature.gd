class_name NatureManager extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var build: BuildManager = get_tree().current_scene.build
@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var shadow: ShadowManager = get_tree().current_scene.shadow

enum NatureType { TREE, BUSH, WEED, STONE, BOULDERS }

const TEXTURES: Dictionary = {
	NatureType.TREE:
	{
		WorldCycle.Season.SPRING:
		[
			preload("res://assets/resources/world/trees/spring/tree_1.png"),
			preload("res://assets/resources/world/trees/spring/tree_2.png"),
			preload("res://assets/resources/world/trees/spring/tree_3.png"),
			preload("res://assets/resources/world/trees/spring/tree_4.png"),
			preload("res://assets/resources/world/trees/spring/tree_5.png"),
			preload("res://assets/resources/world/trees/spring/tree_6.png")
		],
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/trees/summer/tree_1.png"),
			preload("res://assets/resources/world/trees/summer/tree_2.png"),
			preload("res://assets/resources/world/trees/summer/tree_3.png"),
			preload("res://assets/resources/world/trees/summer/tree_4.png"),
			preload("res://assets/resources/world/trees/summer/tree_5.png"),
			preload("res://assets/resources/world/trees/summer/tree_6.png")
		],
		WorldCycle.Season.AUTUMN:
		[
			preload("res://assets/resources/world/trees/autumn/tree_1.png"),
			preload("res://assets/resources/world/trees/autumn/tree_2.png"),
			preload("res://assets/resources/world/trees/autumn/tree_3.png"),
			preload("res://assets/resources/world/trees/autumn/tree_4.png"),
			preload("res://assets/resources/world/trees/autumn/tree_5.png"),
			preload("res://assets/resources/world/trees/autumn/tree_6.png")
		],
		WorldCycle.Season.WINTER:
		[
			preload("res://assets/resources/world/trees/winter/tree_1.png"),
			preload("res://assets/resources/world/trees/winter/tree_2.png"),
			preload("res://assets/resources/world/trees/winter/tree_3.png"),
			preload("res://assets/resources/world/trees/winter/tree_4.png"),
			preload("res://assets/resources/world/trees/winter/tree_5.png"),
			preload("res://assets/resources/world/trees/winter/tree_6.png")
		]
	},
	NatureType.BUSH:
	#! Что-то здесь будет
	{},
	NatureType.WEED:
	{
		WorldCycle.Season.SPRING:
		[
			preload("res://assets/resources/world/weeds/spring/weed_1.png"),
			preload("res://assets/resources/world/weeds/spring/weed_2.png"),
			preload("res://assets/resources/world/weeds/spring/weed_3.png"),
			preload("res://assets/resources/world/weeds/spring/weed_4.png"),
			preload("res://assets/resources/world/weeds/spring/weed_5.png"),
			preload("res://assets/resources/world/weeds/spring/weed_6.png"),
			preload("res://assets/resources/world/weeds/spring/weed_7.png"),
			preload("res://assets/resources/world/weeds/spring/weed_8.png")
		],
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/weeds/summer/weed_1.png"),
			preload("res://assets/resources/world/weeds/summer/weed_2.png"),
			preload("res://assets/resources/world/weeds/summer/weed_3.png"),
			preload("res://assets/resources/world/weeds/summer/weed_4.png"),
			preload("res://assets/resources/world/weeds/summer/weed_5.png"),
			preload("res://assets/resources/world/weeds/summer/weed_6.png"),
			preload("res://assets/resources/world/weeds/summer/weed_7.png"),
			preload("res://assets/resources/world/weeds/summer/weed_8.png")
		],
		WorldCycle.Season.AUTUMN:
		[
			preload("res://assets/resources/world/weeds/autumn/weed_1.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_2.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_3.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_4.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_5.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_6.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_7.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_8.png")
		],
		WorldCycle.Season.WINTER:
		[
			preload("res://assets/resources/world/weeds/winter/weed_1.png"),
			preload("res://assets/resources/world/weeds/winter/weed_2.png"),
			preload("res://assets/resources/world/weeds/winter/weed_3.png"),
			preload("res://assets/resources/world/weeds/winter/weed_4.png"),
			preload("res://assets/resources/world/weeds/winter/weed_5.png"),
			preload("res://assets/resources/world/weeds/winter/weed_6.png"),
			preload("res://assets/resources/world/weeds/winter/weed_7.png"),
			preload("res://assets/resources/world/weeds/winter/weed_8.png")
		]
	},
	NatureType.STONE:
	[
		preload("res://assets/resources/world/stones/stone_1.png"),
		preload("res://assets/resources/world/stones/stone_2.png"),
		preload("res://assets/resources/world/stones/stone_3.png"),
		preload("res://assets/resources/world/stones/stone_4.png"),
		preload("res://assets/resources/world/stones/stone_5.png"),
		preload("res://assets/resources/world/stones/stone_6.png"),
		preload("res://assets/resources/world/stones/stone_7.png"),
		preload("res://assets/resources/world/stones/stone_8.png")
	],
	NatureType.BOULDERS:
	[
		preload("res://assets/resources/world/boulders/big_stone_1.png"),
		preload("res://assets/resources/world/boulders/big_stone_2.png"),
		preload("res://assets/resources/world/boulders/big_stone_3.png"),
		preload("res://assets/resources/world/boulders/big_stone_4.png")
	]
}

const SHADOWS: Dictionary = {
	NatureType.TREE:
	[
		preload("res://assets/resources/world/trees/shadow_1.png"),
		preload("res://assets/resources/world/trees/shadow_2.png"),
		preload("res://assets/resources/world/trees/shadow_3.png"),
		preload("res://assets/resources/world/trees/shadow_4.png"),
		preload("res://assets/resources/world/trees/shadow_5.png"),
		preload("res://assets/resources/world/trees/shadow_6.png")
	],
	NatureType.BUSH: {},
	NatureType.WEED:
	{
		WorldCycle.Season.SPRING:
		[
			preload("res://assets/resources/world/weeds/spring/shadow_1.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_2.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_3.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_4.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_5.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_6.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_7.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_8.png")
		],
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/weeds/summer/shadow_1.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_2.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_3.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_4.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_5.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_6.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_7.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_8.png")
		],
		WorldCycle.Season.AUTUMN:
		[
			preload("res://assets/resources/world/weeds/autumn/shadow_1.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_2.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_3.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_4.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_5.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_6.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_7.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_8.png")
		],
		WorldCycle.Season.WINTER:
		[
			preload("res://assets/resources/world/weeds/winter/shadow_1.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_2.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_3.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_4.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_5.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_6.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_7.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_8.png")
		]
	},
	NatureType.STONE:
	[
		preload("res://assets/resources/world/stones/shadows/shadow_1.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_2.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_3.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_4.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_5.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_6.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_7.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_8.png")
	],
	NatureType.BOULDERS:
	[
		preload("res://assets/resources/world/boulders/big_stone_shadow_1.png"),
		preload("res://assets/resources/world/boulders/big_stone_shadow_2.png"),
		preload("res://assets/resources/world/boulders/big_stone_shadow_3.png"),
		preload("res://assets/resources/world/boulders/big_stone_shadow_4.png")
	]
}

const NOISE_COEFFICIENT: Array[float] = [0.03, 0.04, 0.07, 0.005]
const SHADER_SOURCE: Shader = preload("res://assets/shaders/wind.gdshader")
const MAX_TREE: int = 1200
const MAX_BUSH: int = 100
const MAX_WEED: int = 1000
const MAX_STONE: int = 600
const MAX_BOULDERS: int = 150

var tiles: Array[Vector2i] = []
var shader: ShaderMaterial = _setup_wind_shader()


func _ready() -> void:
	if !is_instance_valid(tilemap):
		printerr("TileMap is NULL.")
		return

	if !is_instance_valid(build):
		printerr("BuildManager is NULL.")
		return

	if !is_instance_valid(shadow):
		printerr("ShadowManager is NULL.")
		return


func spawn() -> void:
	self.tiles = _get_free_tiles()

	_create_tree()
	_create_weed()
	_create_stone()
	_create_boulders()


func add_nature_node(
	type: NatureType,
	size: Vector2i,
	pos: Vector2i,
	offset: Vector2i = Vector2i(0, 0),
	collision_size: Vector2i = Vector2i(0, 0),
	collision_pos: Vector2i = Vector2i(0, 0)
) -> Node2D:
	# ------------------------------------------------------
	# Тут нужно пояснение: здесь проверка на соостветствие
	# размеров массивов для корректной выборки спрайта тени.
	#
	# Из-за того что спрайты могут храниться в словарях и в
	# обычном массиве, из-за того что система смены сезонов,
	# принято решение сделать такой способ проверки на размер.
	#
	# Уродливое решение? Да, но я ничего лучшего не придумал,
	# зато работает, но позже нужно это переделать...
	#
	# P.S. №1 Эта проверка чисто защита от дураков и от меня,
	# ибо работает даже без этой проверки, но я параноик.
	# ------------------------------------------------------

	if TEXTURES[type] is Dictionary && SHADOWS[type] is Dictionary:
		if !(TEXTURES[type][cycle.season_id].size() == SHADOWS[type][cycle.season_id].size()):
			printerr("The sizes of the two arrays do not match.")
			return null

	if TEXTURES[type] is Dictionary && SHADOWS[type] is Array[CompressedTexture2D]:
		if !(TEXTURES[type][cycle.season_id].size() == SHADOWS[type].size()):
			printerr("The sizes of the two arrays do not match.")
			return null

	if TEXTURES[type] is Array[CompressedTexture2D] && SHADOWS[type] is Array[CompressedTexture2D]:
		if !(TEXTURES[type][cycle.season_id].size() == SHADOWS[type].size()):
			printerr("The sizes of the two arrays do not match.")
			return null

	if size.x < 1 || size.y < 1:
		printerr("Uncorrected node size: Vector(", size.x, ",", size.y, ")")
		return null

	var node_cells: Array[Vector2i] = []
	if size.x > 1 && size.y > 1:
		for x in size.x:
			for y in size.y:
				node_cells.append(pos + Vector2i(x, y))

		if !node_cells.is_empty():
			for i in node_cells:
				if (
					tilemap.get_cell_source_id(tilemap.Layers.ROAD, i) != -1
					|| tilemap.get_cell_source_id(tilemap.Layers.NATURE, i) != -1
					|| tilemap.get_cell_source_id(tilemap.Layers.BUILDING, i) != -1
				):
					return null

			for j in node_cells:
				self.tiles.erase(j)
				tilemap.set_cell(tilemap.Layers.NATURE, j, tilemap.SourcesAtlas.GROUND, tilemap.NODE_COLLISION)

	else:
		node_cells.append(pos)
		tilemap.set_cell(tilemap.Layers.NATURE, pos, tilemap.SourcesAtlas.GROUND, tilemap.NODE_COLLISION)

	var parent: Node2D = Node2D.new()
	var area: Area2D = Area2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var sprite: Sprite2D = Sprite2D.new()
	var random: int = (
		randi() % TEXTURES[type][cycle.season_id].size()
		if TEXTURES[type] is Dictionary
		else randi() % TEXTURES[type].size()
	)
	var random_texture: CompressedTexture2D = (
		TEXTURES[type][cycle.season_id][random] if TEXTURES[type] is Dictionary else TEXTURES[type][random]
	)

	sprite.texture = random_texture
	sprite.position.x += offset.x
	sprite.position.y += offset.y

	var shadow_node: Node2D = shadow.add_shadow(
		SHADOWS[type][cycle.season_id][random] if SHADOWS[type] is Dictionary else SHADOWS[type][random],
		tilemap.map_to_local(pos),
		offset
	)

	if type not in [NatureType.STONE, NatureType.BOULDERS]:
		var coefficient: float = fmod(randf(), NOISE_COEFFICIENT[cycle.season_id])

		sprite.material = self.shader
		sprite.material = sprite.material.duplicate()
		sprite.material.set_shader_parameter("amplitude", coefficient)

		if shadow_node:
			shadow_node.material = self.shader
			shadow_node.material = shadow_node.material.duplicate()
			shadow_node.material.set_shader_parameter("amplitude", coefficient)

	if collision_size.x == 0 && collision_size.y == 0:
		rectangle.size = random_texture.get_size()
	else:
		rectangle.size = collision_size

	collision.shape = rectangle
	collision.position = collision_pos
	area.position.x += offset.x
	area.position.y += offset.y
	area.input_pickable = true
	area.input_event.connect(
		func(_viewport: Node, event: InputEvent, _index: int) -> void:
			if (
				build.buildings.has(build.GRID.get_state().get_node_name(0))
				&& build.buildings[build.GRID.get_state().get_node_name(0)].mode == BuildManager.GridModes.DESTROY
			):
				if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
					match type:
						NatureType.TREE:
							Inventory.add_item(1, randi_range(1, 5))
							SoundManager.play_sound("farming/tree_destroy")

						NatureType.BUSH:
							SoundManager.play_sound("farming/weed_destroy")
						NatureType.WEED:
							SoundManager.play_sound("farming/weed_destroy")

						NatureType.STONE:
							Inventory.add_item(3, randi_range(1, 5))
							SoundManager.play_sound("farming/stone_destroy")

						NatureType.BOULDERS:
							Inventory.add_item(3, randi_range(10, 20))
							SoundManager.play_sound("farming/stone_destroy")

					for i in node_cells:
						tilemap.erase_cell(tilemap.Layers.NATURE, i)

					shadow_node.queue_free()
					parent.queue_free()
	)

	area.add_child(collision)

	parent.set_meta("type", type)
	parent.set_meta("shadow", shadow_node)
	parent.set_meta("relative_cells", node_cells)
	parent.z_index = tilemap.Layers.NATURE
	parent.set_position(tilemap.map_to_local(pos))
	parent.add_child(sprite)
	parent.add_child(area)

	return parent


func _create_tree() -> void:
	if MAX_TREE < 1:
		return

	var it: int = 0
	var position_id: int = -1
	while it < MAX_TREE:
		position_id = randi() % self.tiles.size()

		self.add_child(
			add_nature_node(
				NatureType.TREE,
				Vector2i(1, 1),
				self.tiles[position_id],
				Vector2i(0, -16),
				Vector2i(16, 16),
				Vector2i(0, 16)
			)
		)

		self.tiles.erase(tiles[position_id])
		it += 1


func _create_weed() -> void:
	if MAX_WEED < 1:
		return

	var it: int = 0
	var position_id: int = -1
	while it < MAX_WEED:
		position_id = randi() % self.tiles.size()
		self.add_child(add_nature_node(NatureType.WEED, Vector2i(1, 1), self.tiles[position_id]))
		self.tiles.erase(tiles[position_id])
		it += 1


func _create_stone() -> void:
	if MAX_STONE < 1:
		return

	var it: int = 0
	var position_id: int = -1
	while it < MAX_STONE:
		position_id = randi() % self.tiles.size()
		self.add_child(add_nature_node(NatureType.STONE, Vector2i(1, 1), self.tiles[position_id]))
		self.tiles.erase(tiles[position_id])
		it += 1


func _create_boulders() -> void:
	if MAX_BOULDERS < 1:
		return

	var it: int = 0
	var position_id: int = -1
	var node_size: Vector2i = Vector2i(2, 2)

	while it < MAX_BOULDERS:
		position_id = randi() % self.tiles.size()

		var nature_node: Node2D = add_nature_node(
			NatureType.BOULDERS, node_size, self.tiles[position_id], Vector2i(8, 8)
		)

		if nature_node:
			self.add_child(nature_node)

		it += 1


func _get_free_tiles() -> Array[Vector2i]:
	var map: Array[Vector2i] = tilemap.get_used_cells(tilemap.Layers.GROUND)
	var occupieds: Array[Vector2i] = []

	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.ROAD))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.BUILDING))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.COAST))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.FARMLAND))

	for vector in occupieds:
		map.erase(vector)

	return map


func _setup_wind_shader() -> ShaderMaterial:
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	var noise_texture: NoiseTexture2D = NoiseTexture2D.new()
	var noise: FastNoiseLite = FastNoiseLite.new()

	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_texture.noise = noise

	shader_material.shader = SHADER_SOURCE
	shader_material.set_shader_parameter("noise_texture", noise_texture)

	return shader_material
