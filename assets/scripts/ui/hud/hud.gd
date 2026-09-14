extends Control

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var build: BuildManager = get_tree().current_scene.build

@onready var anim: AnimationPlayer = $Animation
@onready var destroy: Button = $Main/Tools/Control/Margin/Margin/HBox/Destroy/Main/Button
@onready var farming: Button = $Main/Tools/Control/Margin/Margin/HBox/Farming/Main/Button
@onready var watering: Button = $Main/Tools/Control/Margin/Margin/HBox/Watering/Main/Button
@onready var harvest: Button = $Main/Tools/Control/Margin/Margin/HBox/Harvest/Main/Button
@onready var building: Button = $Main/Tools/Control/Margin/Margin/HBox/Build/Main/Button
@onready var destroy_icon: TextureRect = $Main/Tools/Control/Margin/Margin/HBox/Destroy/Main/Margin/Icon
@onready var farming_icon: TextureRect = $Main/Tools/Control/Margin/Margin/HBox/Farming/Main/Margin/Icon
@onready var watering_icon: TextureRect = $Main/Tools/Control/Margin/Margin/HBox/Watering/Main/Margin/Icon
@onready var harvest_texture: TextureRect = $Main/Tools/Control/Margin/Margin/HBox/Harvest/Main/Margin/Icon
@onready var build_icon: TextureRect = $Main/Tools/Control/Margin/Margin/HBox/Build/Main/Margin/Icon
@onready var balance: Label = $Main/Bars/Balance/Margin/HBoxContainer2/Label/Label
@onready var timedate: Label = $Main/Bars/Time/Margin/HBoxContainer2/Label/Label
@onready var debug: Label = $Main/Bars/Debug/Label

const ICONS: Dictionary = {
	0: preload("res://assets/resources/ui/interactive/hud/tools/trash.png"),
	1: preload("res://assets/resources/ui/interactive/hud/tools/hoe.png"),
	2: preload("res://assets/resources/ui/interactive/hud/tools/watering_can.png"),
	3: preload("res://assets/resources/ui/interactive/hud/tools/sickle.png"),
	4: preload("res://assets/resources/ui/interactive/hud/tools/hammer.png")
}

var debug_mode: bool = true


func _ready() -> void:
	if !is_instance_valid(build):
		printerr("BuildManager is NULL.")
		return

	if !is_instance_valid(cycle):
		printerr("World cycle is NULL.")
		return

	_init_button()
	_init_debug()

	_update_datetime(cycle.day, cycle.hours, cycle.minuts)
	cycle.datetime_changed.connect(_update_datetime)

	self.visible = true
	anim.animation_finished.connect(
		func(animation_name: StringName) -> void:
			if animation_name != "show":
				UIManager.remove_ui(self)
	)
	anim.play("show")


func _process(_delta: float) -> void:
	if debug_mode:
		debug.text = (
			"FPS: "
			+ str(Engine.get_frames_per_second())
			+ "\nRAM: %d MB" % (OS.get_static_memory_usage() / 1024 / 1024)
			+ "\nCPU: "
			+ str(Performance.get_monitor(Performance.TIME_PROCESS))
			+ "\nVulkan: "
			+ str(RenderingServer.get_video_adapter_api_version())
		)


func _init_debug() -> void:
	set_process(true if debug_mode else false)


func _update_datetime(days: int, hours: int, minuts: int) -> void:
	var time: String = str(hours) + ":" + str(minuts) + "0"
	var date: String = tr("hud.date") + ": " + str(days)
	self.timedate.text = time + "; " + date


func _init_button() -> void:
	destroy_icon.texture = ICONS[0] if ICONS[0] is CompressedTexture2D else null
	farming_icon.texture = ICONS[1] if ICONS[1] is CompressedTexture2D else null
	watering_icon.texture = ICONS[2] if ICONS[2] is CompressedTexture2D else null
	harvest_texture.texture = ICONS[3] if ICONS[3] is CompressedTexture2D else null
	build_icon.texture = ICONS[4] if ICONS[4] is CompressedTexture2D else null

	destroy.pressed.connect(
		func() -> void:
			build.grid_add(build.GridModes.DESTROY)
			close()
	)

	farming.pressed.connect(
		func() -> void:
			build.grid_add(build.GridModes.FARMING)
			close()
	)
	watering.pressed.connect(
		func() -> void:
			build.grid_add(build.GridModes.WATERING)
			close()
	)

	harvest.pressed.connect(
		func() -> void:
			build.grid_add(build.GridModes.HARVESTING)
			close()
	)

	building.pressed.connect(
		func() -> void:
			UIManager.add_ui(UIManager.MENUS.BUILD)
			close()
	)

	destroy.pressed.connect(UIManager.button_pressed)
	farming.pressed.connect(UIManager.button_pressed)
	watering.pressed.connect(UIManager.button_pressed)
	harvest.pressed.connect(UIManager.button_pressed)
	building.pressed.connect(UIManager.button_pressed)

	destroy.mouse_entered.connect(UIManager.button_hovered)
	farming.mouse_entered.connect(UIManager.button_hovered)
	watering.mouse_entered.connect(UIManager.button_hovered)
	harvest.mouse_entered.connect(UIManager.button_hovered)
	building.mouse_entered.connect(UIManager.button_hovered)

	destroy.mouse_exited.connect(UIManager.button_exited)
	farming.mouse_exited.connect(UIManager.button_exited)
	watering.mouse_exited.connect(UIManager.button_exited)
	harvest.mouse_exited.connect(UIManager.button_exited)
	building.mouse_exited.connect(UIManager.button_exited)


func close() -> void:
	anim.play("hide")
