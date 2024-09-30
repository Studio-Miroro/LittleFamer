extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var build:Control = get_node("/root/"+main+"/UI/Interactive/Crafting")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var node:PackedScene = load("res://assets/nodes/ui/interactive/inventory/slot.tscn")
@onready var anim:AnimationPlayer = $Animation

@onready var info:BoxContainer = $Panel/HBoxContainer/ItemInfo/VBoxContainer
@onready var scroll_info:ScrollContainer = $Panel/HBoxContainer/ItemInfo
@onready var slots:GridContainer = $Panel/HBoxContainer/Slots/GridContainer
@onready var scroll_slots:ScrollContainer = $Panel/HBoxContainer/Slots

@onready var icon:TextureRect = $Panel/HBoxContainer/ItemInfo/VBoxContainer/Icon/Icon
@onready var caption:Label = $Panel/HBoxContainer/ItemInfo/VBoxContainer/Caption/Caption
@onready var description:Label = $Panel/HBoxContainer/ItemInfo/VBoxContainer/Description/Description
@onready var specifications:Label = $Panel/HBoxContainer/ItemInfo/VBoxContainer/Specifications/Specifications
@onready var type:Label = $Panel/HBoxContainer/ItemInfo/VBoxContainer/Type/Type
@onready var button:Button = $Panel/HBoxContainer/ItemInfo/VBoxContainer/Button/Button
@onready var list:Label = $Panel/StorageItemList

var menu:bool = false
var inventory_items:Dictionary = {
	1:{"amount":20},
	2:{"amount":20},
	3:{"amount":20},
	12:{"amount":25},
	13:{"amount":25},
	14:{"amount":25},
	15:{"amount":25},
}

var item_index
var button_index:int
enum item_type {
	NOTHING,
	SEEDS,
}

func _ready():
	check_window()
	reset_data()
	check_inventory()

func inventory_update():
	#var items = Items.new()
	var remove_items = []
	for item in inventory_items:
		if inventory_items[item]["amount"] == 0:
			remove_items.append(item)
	
	if remove_items != []:
		for i in remove_items:
			inventory_items.erase(i)

func check_inventory():
	var max_slots = storage.object[storage.level]["slots"]
	while inventory_items.size() > max_slots:
		for item in inventory_items:
			inventory_items.erase(item)
			break
			data.debug("Due to inventory overflow, an item with the following ID was destroyed: " + str(item), "info")

func _process(_delta):
	if !blur.state:
		if Input.is_action_just_pressed("inventory"):
			window()
	else:
		if (Input.is_action_just_pressed("pause") && menu) or (Input.is_action_just_pressed("inventory") && menu):
			close()

func load_content(content:Dictionary) -> void:
	inventory_items = content

func open() -> void:
	menu = true
	pause.other_menu = true
	blur.blur(true)
	anim.play("open")
	create_all_items()
	update_string_capacity()
	inventory_update()

func close() -> void:
	menu = false
	pause.other_menu = false
	blur.blur(false)
	anim.play("close")
	remove_inventory_slots()

func get_data(index) -> void:
	if menu:
		var item = Items.new()
		self.item_index = index
		scroll_info.scroll_vertical = 0

		if item.content.has(int(index)):
			if item.content[int(index)].has("icon"):
				if typeof(item.content[int(index)]["icon"]) == TYPE_OBJECT:
					icon.visible = true
					icon.texture = item.content[int(index)]["icon"]
				else:
					icon.visible = false
					data.debug("[ID: "+str(index)+"] The key stores a non-Compressed 2D Texture.", "error")
			else:
				data.debug("[ID: "+str(index)+"] The object does not have the 'icon' key.", "error")
				icon.visible = false

			if item.content[int(index)].has("caption"):
				if typeof(item.content[int(index)]["caption"]) == TYPE_STRING:
					caption.visible = true
					caption.text = item.content[int(index)]["caption"]
				else:
					caption.visible = false
					data.debug("[ID: "+str(index)+"] The 'caption' key has a non-string type.", "error")
			else:
				data.debug("[ID: "+str(index)+"] The object does not have the 'caption' key.", "error")
				caption.visible = false

			if item.content[int(index)].has("description"):
				if typeof(item.content[int(index)]["description"]) == TYPE_STRING:
					description.visible = true
					description.text = item.content[int(index)]["description"]
				else:
					description.visible = false
					data.debug("[ID: "+str(index)+"] The 'description' key has a non-string type.", "error")
			else:
				description.visible = false
				data.debug("[ID: "+str(index)+"] The object does not have the 'description' key.", "error")

			if item.content[int(index)].has("specifications"):
				if item.content[int(index)].get("specifications") != {}:
					specifications.visible = true
					specifications.text = ""
					for i in item.content[int(index)]["specifications"]:
						get_specifications(int(index), i)
				else:
					specifications.visible = false
					data.debug("[ID: "+str(index)+"] The 'specifications' key is empty.", "error")
			else:
				specifications.visible = false

			if item.content[int(index)].has("type"):
				if typeof(item.content[int(index)]["type"]) == TYPE_STRING:
					var type_text = tr("item_type.inventory")
					type.visible = true
					type.text = "\n" + type_text + ": " + item.content[int(index)]["type"] + "\n"
					check_item_type(item.content[int(index)]["type"])
				else:
					type.visible = false
					data.debug("[ID: "+str(index)+"] The 'type' key has a non-string type.", "error")
			else:
				data.debug("The object does not have the 'type' key.", "error")
		else:
			data.debug("The object does not have the 'type' key.", "error")

func reset_data() -> void:
	icon.visible = false
	caption.visible = false
	description.visible = false
	specifications.visible = false
	type.visible = false
	list.visible = false
	button.visible = false

func get_items() -> Dictionary:
	return inventory_items

func create_all_items() -> void:
	var items = Items.new()
	for item in inventory_items:
		if items.content.has(int(item)):
			if inventory_items[item].has("amount"):
				if inventory_items[item]["amount"] > 0:
					item_create(item)
	inventory_update()

func remove_inventory_slots() -> void:
	for item in slots.get_children():
		slots.remove_child(item)
		item.queue_free()

func item_create(id) -> void:
	var slot = node.instantiate()
	check_amount(id)
	if inventory_items.has(id):
		if inventory_items[id]["amount"] > 0:
			slots.add_child(slot)
			slot.set_data(id, inventory_items[id]["amount"])
		else:
			remove_item(id)
			data.debug("Invalid item index: " + str(id), "error")

func update_string_capacity() -> void:
	if has_node("/root/"+main+"/ConstructionManager"):
		if has_node("/root/"+main+"/ConstructionManager/Storage"):
			if storage.object[storage.level].has("slots"):
				var text = tr("storage.capacity")
				list.text = text + " " + str(get_all_items()) + "/" + str(storage.object[storage.level]["slots"])
				list.visible = true
			else:
				data.debug("The 'slots' element does not exist.", "error")
				list.visible = false
		else:
			data.debug("In the parent of 'ConstructionManager'  there is no child node 'Storage'", "error")
	else:
		data.debug("There is no parent of 'ConstructionManager' in the '"+main+"' scene", "error")

func get_all_items() -> int:
	var items = Items.new()
	if slots:
		var item:int = 0
		if inventory_items != {}:
			for i in inventory_items:
				if items.content.has(int(i)):
					item += 1
		return item
	else:
		data.debug("Cannot load parent.", "error")
		return 0

func add_item(id, amount:int = 0) -> void:
	if inventory_items.has(id):
		inventory_items[id]["amount"] += amount
	else:
		inventory_items[id] = {"amount": amount}
		
func subject_item(id, item_amount:int = 1) -> void:
	match typeof(id):
		TYPE_INT:
			if item_amount != 0:
				for key in inventory_items:
					if id == key:
						inventory_items[id]["amount"] -= item_amount 
						check_amount(id)
			else:
				pass # print_debug

		TYPE_DICTIONARY:
			var materials = BuildingMaterials.new()
			var resources_id = []
			var amounts = []

			for item in id:
				if id[item].has("amount"):
					if id[item]["amount"] > 0:
						resources_id.append(materials.resources[item])
						amounts.append(id[item]["amount"])

			for item_id in resources_id:
				if inventory_items.has(item_id):
					inventory_items[item_id]["amount"] -= amounts[item_id-1]
					check_amount(item_id)
		_:
			pass # print_debug

func remove_item(id) -> void:
	for key in inventory_items:
		if id == key:
			inventory_items.erase(key)

func get_item_amount(item_id) -> int:
	if inventory_items.has(item_id) and inventory_items[item_id].has("amount"):
		if inventory_items[item_id]["amount"] > 0:
			return inventory_items[item_id]["amount"]
	return 0

func check_item_amount(id) -> bool:
	if inventory_items.has(id):
		if inventory_items[id].has("amount"):
			if inventory_items[id]["amount"] > 0:
				return true
			else:
				remove_item(id)
				return false
	return false

func check_amount(index) -> void:
	var inventory = inventory_items[index]
	var items = Items.new()
	if inventory.has(index):
		if inventory.has("amount"):
			if inventory["amount"] > items.maximum:
				inventory["amount"] = items.maximum
			if inventory["amount"] <= 0:
				remove_item(index)
		else:
			push_warning("[ID: " + str(index) + "] The 'amount' element does not exist in the inventory dictionary (array).")
			inventory["amount"] = 1

func get_specifications(index, i) -> void:
	var items = Items.new()
	if typeof(items.content[index]["specifications"][i]) == TYPE_STRING and specifications.text is String:
		specifications.text = specifications.text + "\n• " + get_tip(i) + ": "+ items.content[index]["specifications"][i]
	else:
		data.debug("[ID: "+str(index)+"] The '"+ str(i) +"' element is not a string.", "error")


func get_tip(tip:String) -> String:
	match tip:
		"growth":
			return tr("growthtime_crop.inventory")
		"productivity":
			return tr("productivity_crop.inventory")
		"conditions":
			return tr("conditions_crop.inventory")
		_:
			return ""

func check_item_type(i_type:String) -> void:
	match i_type:
		"seeds":
			var plant_text = tr("plant_seeds.inventory_button")
			button_index = item_type.SEEDS
			button.text = plant_text
			button.visible = true
		_:
			button_index = item_type.NOTHING
			button.visible = false

func _on_button_pressed():
	var items = Items.new().content
	match button_index:
		item_type.SEEDS:
			close()
			if items.has(int(item_index)):
				if items[int(item_index)].has("crop"):
					grid.inventory_item = item_index
					grid.plantID = items[int(item_index)]["crop"]
					grid.mode = grid.modes.PLANTING
					grid.visible = true
				else:
					data.debug("The 'crop' key does not exist", "error")
			else:
				data.debug("The numerical ID (" + item_index + ") of this crop is missing in the main file crops.gd", "error")
		_:
			pass

func window() -> void:
	if menu:
		close()
	else:
		open()

func check_window() -> void:
	visible = menu

func _on_close_pressed():
	if menu:
		close()
