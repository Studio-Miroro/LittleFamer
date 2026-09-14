extends CanvasLayer

@onready var cursor: Cursor = $Cursor
@onready var blur: BlurEffect = $Blur
@onready var blackout: BlackoutEffect = $Blackout

const MENUS: Dictionary = {
	PAUSE = preload("res://assets/nodes/ui/menu/pause.tscn"),
	OPTIONS = preload("res://assets/nodes/ui/menu/settings.tscn"),
	CREDITS = preload("res://assets/nodes/ui/menu/credits.tscn"),
	HUD = preload("res://assets/nodes/ui/hud/hud.tscn"),
	BUILD = preload("res://assets/nodes/ui/windows/build_menu.tscn"),
	INVENTORY = preload("res://assets/nodes/ui/windows/inventory.tscn"),
	MAILBOX = preload("res://assets/nodes/ui/windows/mail.tscn")
}

var ui: Dictionary


func add_ui(object: PackedScene, only: bool = true) -> Control:
	var node: Control = object.instantiate()

	if only:
		if !ui.has(node.name):
			ui[node.name] = node
			self.add_child(node)
		else:
			node = null
	else:
		self.add_child(node, true)
		ui[node.name] = node

	return node


func remove_ui(node: Control) -> bool:
	var flag: bool = true

	if !node:
		flag = false

	if flag && ui.has(node.name):
		ui.erase(node.name)
		self.remove_child(node)
		node.queue_free()

	return flag


func get_ui(node_name: String) -> Control:
	var node: Control = null
	if ui.has(node_name):
		node = ui[node_name]

	return node


func button_pressed() -> void:
	SoundManager.play_sound("ui/click")
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)


func button_hovered(disabled: bool = false) -> void:
	if !disabled:
		SoundManager.play_sound("ui/hover")
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func button_exited() -> void:
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
