extends Control

@onready var anim: AnimationPlayer = $Animation
@onready var close: Button = $Close

@onready var container: GridContainer = $Panel/HBox/Letters/Scroll/Grid
@onready var title: Label = $Panel/HBox/Content/Container/VBox/Title/Label
@onready var content: Label = $Panel/HBox/Content/Container/VBox/Description/Label
@onready var author: Label = $Panel/HBox/Content/Container/VBox/Author/Label
@onready var items_container: MarginContainer = $Panel/HBox/Content/Container/VBox/ItemsContainer
@onready var monies: RichTextLabel = $Panel/HBox/Content/Container/VBox/ItemsContainer/VBox/Money/Label
@onready var items: GridContainer = $Panel/HBox/Content/Container/VBox/ItemsContainer/VBox/Items/Grid
@onready var collect: Button = $Panel/HBox/Content/Container/VBox/ItemsContainer/VBox/Collect/Button
@onready var remove: Button = $Panel/HBox/Content/Container/VBox/ManipulationButtons/MailRemove

const LETTER_READED: CompressedTexture2D = preload("res://assets/resources/ui/interactive/mail/readed.png")
const LETTER_UNREAD: CompressedTexture2D = preload("res://assets/resources/ui/interactive/mail/unread.png")
const LETTER_ICON_SIZE: Vector2i = Vector2i(48, 48)
const LETTER_ITEM_SIZE: Vector2i = Vector2i(64, 64)
const LETTER_MARGIN: int = 8

var letter_index: int


func _ready() -> void:
	close.pressed.connect(_close)
	close.pressed.connect(UIManager.button_pressed)
	close.mouse_entered.connect(UIManager.button_hovered)
	close.mouse_exited.connect(UIManager.button_exited)
	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				UIManager.add_ui(UIManager.MENUS.HUD)
				UIManager.remove_ui(self)
	)

	remove.text = tr("mailbox.delete_letter.button")
	remove.pressed.connect(
		func() -> void:
			Letters.remove_letter(self.letter_index)
			update()
	)

	remove.pressed.connect(UIManager.button_pressed)
	remove.mouse_entered.connect(UIManager.button_hovered)
	remove.mouse_exited.connect(UIManager.button_exited)

	collect.text = tr("mailbox.collect_items.button")
	collect.pressed.connect(
		func() -> void:
			if Letters.letters.has(self.letter_index) && Letters.letters[self.letter_index].has("items"):
				var items_index: Array[int] = []
				var items_amount: Array[int] = []

				for id in Letters.letters[self.letter_index]["items"]:
					items_index.append(id)
					items_amount.append(Letters.letters[self.letter_index]["items"][id]["amount"])

				if !items_index.is_empty() && !items_amount.is_empty():
					for value in items_index.size():
						Inventory.add_item(items_index[value], items_amount[value])

				PlayerControl.mailbox[self.letter_index]["taked"] = true
				_update_letter_buttons()
	)

	collect.pressed.connect(UIManager.button_pressed)
	collect.mouse_entered.connect(UIManager.button_hovered)
	collect.mouse_exited.connect(UIManager.button_exited)

	UIManager.blur.blur(true)
	SoundManager.play_sound("ui/mailbox")
	anim.play("show")
	update()


func update() -> void:
	self.letter_index = 0

	title.visible = true
	title.text = tr("mail.empty.title") if PlayerControl.mailbox.is_empty() else tr("mail.title")

	content.visible = true
	content.text = tr("mail.empty.description") if PlayerControl.mailbox.is_empty() else tr("mail.description")

	author.visible = false
	items_container.visible = false
	collect.visible = false
	remove.visible = false

	# Мне не нравится такая система.
	# А вдруг будет много элементов?

	if !container.get_children().is_empty():
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()

	if !PlayerControl.mailbox.is_empty():
		for letter in PlayerControl.mailbox:
			var button: Control = _button_letter(letter)
			if button:
				container.add_child(button)


func _button_letter(letter_id: int) -> Control:
	if !Letters.letters.has(letter_id):
		return null

	var data: Dictionary = Letters.get_letter(letter_id)
	var parent: Control = Control.new()
	var external_margin: MarginContainer = MarginContainer.new()
	var button: Button = Button.new()
	var internal_margin: MarginContainer = MarginContainer.new()
	var hbox: HBoxContainer = HBoxContainer.new()
	var sprite: TextureRect = TextureRect.new()
	var label: Label = Label.new()

	parent.set_custom_minimum_size(Vector2(0, LETTER_ICON_SIZE.y + (LETTER_MARGIN * 2)))
	parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL | Control.SIZE_FILL
	external_margin.set_anchors_preset(PRESET_TOP_WIDE)
	internal_margin.add_theme_constant_override("margin_top", LETTER_MARGIN)
	internal_margin.add_theme_constant_override("margin_right", LETTER_MARGIN)
	internal_margin.add_theme_constant_override("margin_bottom", LETTER_MARGIN)
	internal_margin.add_theme_constant_override("margin_left", LETTER_MARGIN)

	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	external_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	internal_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	sprite.texture = (
		LETTER_READED
		if (
			PlayerControl.mailbox[letter_id].has("readed")
			&& PlayerControl.mailbox[letter_id]["readed"] is bool
			&& PlayerControl.mailbox[letter_id]["readed"]
		)
		else LETTER_UNREAD
	)
	sprite.set_custom_minimum_size(LETTER_ICON_SIZE)
	label.text = data["title"]

	button.pressed.connect(
		func() -> void:
			self._read_letter(data, letter_id)
			if !PlayerControl.mailbox[self.letter_index]["readed"]:
				PlayerControl.mailbox[self.letter_index]["readed"] = true
				sprite.texture = LETTER_READED
			self._update_letter_buttons()
	)
	button.pressed.connect(UIManager.button_pressed)
	button.mouse_entered.connect(UIManager.button_hovered)
	button.mouse_exited.connect(UIManager.button_exited)

	parent.add_child(external_margin)
	external_margin.add_child(button)
	external_margin.add_child(internal_margin)
	internal_margin.add_child(hbox)
	hbox.add_child(sprite)
	hbox.add_child(label)

	return parent


func _read_letter(data: Dictionary, letter_id: int) -> void:
	if self.letter_index == letter_id:
		return

	# Нужен для обработки кнопки получения
	# и удаления из массива mailbox
	# класса PlayerControl
	self.letter_index = letter_id

	title.text = data["title"]
	content.text = data["description"]
	author.text = data["author"]

	if !items.get_children().is_empty():
		for child in items.get_children():
			items.remove_child(child)
			child.queue_free()

	if data.has("items") && !data["items"].is_empty():
		items_container.visible = true
		for item in data["items"]:
			var item_content: Dictionary = Items.get_item(int(item))
			if (
				data["items"][item].has("amount")
				&& data["items"][item]["amount"] is int
				&& data["items"][item]["amount"] > 0
				&& item_content.has("icon")
				&& item_content["icon"] is CompressedTexture2D
			):
				items.add_child(_create_button_item(item_content["icon"], data["items"][item]["amount"]))

	else:
		items_container.visible = false


func _create_button_item(texture: CompressedTexture2D, amount: int) -> Control:
	if !texture:
		printerr("Texture of the mailbox block is NULL.")
		return null

	var parent: Control = Control.new()
	var margin: MarginContainer = MarginContainer.new()
	var button: Button = Button.new()
	var sprite: TextureRect = TextureRect.new()
	var label: Label = Label.new()

	parent.set_custom_minimum_size(LETTER_ITEM_SIZE)
	button.set_custom_minimum_size(LETTER_ITEM_SIZE)

	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", LETTER_MARGIN / 2)
	margin.add_theme_constant_override("margin_right", LETTER_MARGIN / 2)
	margin.add_theme_constant_override("margin_bottom", LETTER_MARGIN / 2)
	margin.add_theme_constant_override("margin_left", LETTER_MARGIN / 2)

	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	label.text = "x" + str(amount) if amount > 0 else ""
	label.size_flags_vertical = SIZE_SHRINK_END
	label.size_flags_horizontal = SIZE_SHRINK_END
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	button.pressed.connect(UIManager.button_pressed)
	button.mouse_entered.connect(UIManager.button_hovered)
	button.mouse_exited.connect(UIManager.button_exited)

	parent.add_child(button)
	parent.add_child(margin)
	margin.add_child(sprite)
	margin.add_child(label)

	return parent


# Обновляет состояние кнопок письма:
#	-
#	-


func _update_letter_buttons() -> void:
	remove.visible = true
	collect.visible = (
		true
		if (
			Letters.letters[self.letter_index].has("items")
			&& !Letters.letters[self.letter_index]["items"].is_empty()
			&& !PlayerControl.mailbox[self.letter_index]["taked"]
		)
		else false
	)

	remove.disabled = (
		false
		if (
			(
				Letters.letters[self.letter_index].has("items")
				&& !Letters.letters[self.letter_index]["items"].is_empty()
				&& PlayerControl.mailbox[self.letter_index]["taked"]
			)
			|| (
				(
					!Letters.letters[self.letter_index].has("items")
					|| Letters.letters[self.letter_index]["items"].is_empty()
				)
				&& PlayerControl.mailbox[self.letter_index]["readed"]
			)
		)
		else true
	)


func _close() -> void:
	UIManager.blur.blur(false)
	anim.play("hide")
