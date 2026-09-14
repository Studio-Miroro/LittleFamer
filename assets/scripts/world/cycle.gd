class_name WorldCycle extends CanvasModulate

@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var nature: NatureManager = get_tree().current_scene.nature

enum Season { SPRING, SUMMER, AUTUMN, WINTER }
const GRADIENTS: Dictionary = {
	Season.SPRING: preload("res://assets/resources/world/gradients/summer.tres"),
	Season.SUMMER: preload("res://assets/resources/world/gradients/summer.tres"),
	Season.AUTUMN: preload("res://assets/resources/world/gradients/summer.tres"),
	Season.WINTER: preload("res://assets/resources/world/gradients/summer.tres")
}

const DAYLIGHT: Dictionary = {
	Season.SPRING: {"day_start": 5, "day_end": 17},
	Season.SUMMER: {"day_start": 4, "day_end": 18},
	Season.AUTUMN: {"day_start": 6, "day_end": 17},
	Season.WINTER: {"day_start": 8, "day_end": 18}
}

const CYCLE_SPEED: float = 4
const MAX_MINUTE: int = 6
const MAX_HOURS: int = 24
const MAX_DAYS: int = 7

var hours: int = 7
var minuts: int = 0
var day: int = 1

var season_id: Season = Season.SUMMER

signal datetime_changed(days: int, hours: int, minuts: int)


func _ready() -> void:
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = CYCLE_SPEED
	timer.timeout.connect(_timeout)
	self.add_child(timer)


func _timeout() -> void:
	# -------------------------------
	# Мне прям вообще не нравится
	# такой способ, но есть что есть.
	# -------------------------------

	if self.minuts + 1 < MAX_MINUTE:
		self.minuts += 1
	else:
		self.minuts = 0
		if self.hours + 1 > MAX_HOURS - 1:
			self.hours = 0

			if self.day + 1 < MAX_DAYS + 1:
				self.day += 1
			else:
				self.day = 1

				match self.season_id:
					#! Один из странных решений, но оно работает.
					Season.SPRING:
						self.season_id = Season.SUMMER
						tilemap.update_atlas(self.season_id)

					Season.SUMMER:
						self.season_id = Season.AUTUMN
						tilemap.update_atlas(self.season_id)

					Season.AUTUMN:
						self.season_id = Season.WINTER
						tilemap.update_atlas(self.season_id)

					Season.WINTER:
						self.season_id = Season.SPRING
						tilemap.update_atlas(self.season_id)

		else:
			self.hours += 1

	datetime_changed.emit(self.day, self.hours, self.minuts)
