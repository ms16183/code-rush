extends Control

@export var time: float = 3.0
@export var label: Label
@export var progress: TextureProgressBar

@onready var timer: Timer = Timer.new()

var _ticks: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	timer.wait_time = 0.01
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timeout)

	add_child(timer)


func _on_timeout() -> void:

	_ticks += timer.wait_time

	if _ticks >= time:
		GameManager.load_game()

	label.text = "%.1f" % (time - _ticks)
	progress.value = 1.0 - wrapf(_ticks, 0.00, 1.01)
