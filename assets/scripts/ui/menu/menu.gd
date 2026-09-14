extends MarginContainer

@onready var resume: Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ContinueMargin/ContinueButton
@onready var newgame: Button = $MenuContent/VContainer/ButtonsMargin/Buttons/NewGameMargin/NewGameButton
@onready var settings: Button = $MenuContent/VContainer/ButtonsMargin/Buttons/SettingsMargin/SettingsButton
@onready var credits: Button = $MenuContent/VContainer/ButtonsMargin/Buttons/CreditsMargin/CreditsButton
@onready var exit: Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ExitMargin/ExitButton
@onready var version: Label = $MenuContent/VContainer/FooterMargin/VBoxContainer/Version

var countinue_text: String = tr("menu.countinue")
var newgame_text: String = tr("menu.newgame")
var settings_text: String = tr("menu.settings")
var quit_text: String = tr("menu.quit")
var credits_text: String = tr("menu.credits")


func _ready() -> void:
	GameData.settings_load()
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
	UIManager.blackout.blackout(false)
	version.text = "v" + str(ProjectSettings.get_setting("application/config/version"))

	_init_buttons()


func _init_buttons() -> void:
	resume.text = countinue_text
	newgame.text = newgame_text
	settings.text = settings_text
	credits.text = credits_text
	exit.text = quit_text

	resume.mouse_entered.connect(UIManager.button_hovered.bind(resume.disabled))
	newgame.mouse_entered.connect(UIManager.button_hovered)
	settings.mouse_entered.connect(UIManager.button_hovered)
	credits.mouse_entered.connect(UIManager.button_hovered)
	exit.mouse_entered.connect(UIManager.button_hovered)
	resume.mouse_exited.connect(UIManager.button_exited)
	newgame.mouse_exited.connect(UIManager.button_exited)
	settings.mouse_exited.connect(UIManager.button_exited)
	credits.mouse_exited.connect(UIManager.button_exited)
	exit.mouse_exited.connect(UIManager.button_exited)

	resume.disabled = false if DirAccess.open("user://game/data") else true
	resume.pressed.connect(func() -> void: pass)  #! Изменить функционал после добавления загрузки данных

	newgame.pressed.connect(
		func() -> void:
			UIManager.blackout.anim.animation_finished.connect(
				func(_animation_scene: String) -> void: get_tree().change_scene_to_file("res://levels/farm.tscn"),
				CONNECT_ONE_SHOT
			)
			UIManager.blackout.blackout(true)
	)

	settings.pressed.connect(func() -> void: UIManager.add_ui(UIManager.MENUS.OPTIONS))

	credits.pressed.connect(func() -> void: UIManager.add_ui(UIManager.MENUS.CREDITS))

	exit.pressed.connect(func() -> void: get_tree().quit())

	resume.pressed.connect(UIManager.button_pressed)
	newgame.pressed.connect(UIManager.button_pressed)
	settings.pressed.connect(UIManager.button_pressed)
	credits.pressed.connect(UIManager.button_pressed)
