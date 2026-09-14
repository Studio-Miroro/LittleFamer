class_name ShadowManager extends CanvasGroup

const MODULATE: Color = Color(0, 0, 0)
const SELF_MODULATE: Color = Color(0, 0, 0, 0.2)
const OFFSET: int = 8


func _ready() -> void:
	self.z_index = 1
	self.modulate = MODULATE
	self.self_modulate = SELF_MODULATE


func add_shadow(texture: CompressedTexture2D, pos: Vector2i, offset: Vector2i = Vector2i(0, 0)) -> Node2D:
	if !texture:
		printerr("Texture is NULL.")
		return

	var parent: Node2D = Node2D.new()
	var sprite: Sprite2D = Sprite2D.new()

	sprite.texture = texture
	sprite.set_position(pos + offset)
	parent.add_child(sprite)
	self.add_child(parent)

	return parent


func remove_shadow(node: Node2D) -> void:
	if !node:
		return

	self.remove_child(node)
	node.queue_free()
