extends Node

var letters: Dictionary = {
	1: {"title": "Hello, World!", "description": "This is test text", "author": "Developer", "items": {}}
}


func _ready() -> void:
	letters.make_read_only()


func add_letter(letter_id: int) -> void:
	if !letters.has(letter_id):
		printerr("There is no such ID (" + str(letter_id) + ") in the letters container.")
		return

	var data: Dictionary = {"readed": false, "taked": false}
	PlayerControl.mailbox.merge(data)


func get_letter(letter_id: int) -> Dictionary:
	var data: Dictionary = {}

	if letters.has(letter_id):
		data.merge(letters[letter_id])

	return data


func remove_letter(letter_id: int) -> void:
	if !PlayerControl.mailbox.has(letter_id):
		printerr("There is no such ID (" + str(letter_id) + ") in the mailbox container.")
		return

	PlayerControl.mailbox.erase(letter_id)
