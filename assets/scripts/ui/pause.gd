extends Control

@onready var anim: AnimationPlayer = $Animation
@onready var resume: Button = $Main/Container/CountinueButtonMargin/CountinueButton
@onready var settings: Button = $Main/Container/SettingsButtonMargin/SettingsButton
@onready var report: Button = $Main/Container/ReportBugButtonMargin/ReportBugButton
@onready var exit: Button = $Main/Container/ExitButtonMargin/ExitButton
@onready var version: Label = $Main/Container/GameVersionMargin/GameVersion


func _ready() -> void:
	_init_button()
	self.visible = false
	version.text = "v" + str(ProjectSettings.get_setting("application/config/version"))
	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				UIManager.remove_ui(self)
	)

	self.visible = true
	UIManager.blur.blur(true)
	anim.play("show")


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc") && abs(self.modulate.a) == 1.0:
		_close()


func _close() -> void:
	UIManager.add_ui(UIManager.MENUS.HUD)
	UIManager.blur.blur(false)
	anim.play("hide")


func _init_button() -> void:
	resume.pressed.connect(func() -> void: _close())

	settings.pressed.connect(
		func() -> void:
			UIManager.add_ui(UIManager.MENUS.OPTIONS)
			UIManager.remove_ui(self)
	)

	report.pressed.connect(func() -> void: Utils.open_url("https://www.youtube.com/watch?v=gAsNvXDsrGA"))

	exit.pressed.connect(
		func() -> void:
			if is_instance_valid(UIManager.blackout):
				UIManager.blackout.anim.animation_finished.connect(
					func(animation_name: String) -> void:
						if animation_name != "show":
							GameData.save()
							get_tree().change_scene_to_file("res://levels/menu.tscn")
							UIManager.blur.blur(false)
							UIManager.remove_ui(self),
					CONNECT_ONE_SHOT
				)
				UIManager.blackout.blackout(true)
	)

	resume.pressed.connect(UIManager.button_pressed)
	settings.pressed.connect(UIManager.button_pressed)
	report.pressed.connect(UIManager.button_pressed)
	exit.pressed.connect(UIManager.button_pressed)

	resume.mouse_entered.connect(UIManager.button_hovered)
	settings.mouse_entered.connect(UIManager.button_hovered)
	report.mouse_entered.connect(UIManager.button_hovered)
	exit.mouse_entered.connect(UIManager.button_hovered)

	resume.mouse_exited.connect(UIManager.button_exited)
	settings.mouse_exited.connect(UIManager.button_exited)
	report.mouse_exited.connect(UIManager.button_exited)
	exit.mouse_exited.connect(UIManager.button_exited)
