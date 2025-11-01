extends Control

@export var play_button: Button
@export var previous_button: TextureButton
@export var next_button: TextureButton
@export var title: Label
@export var description: Label

var _levels: Array[Dictionary] = LevelLoader.load_levels()
var _cursor: int = 0

func _ready() -> void:
	play_button.pressed.connect(_play_button_pressed)
	previous_button.pressed.connect(_previous_button_pressed)
	next_button.pressed.connect(_next_button_pressed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		_previous_button_pressed()

	elif Input.is_action_just_pressed("down"):
		_next_button_pressed()

	elif Input.is_action_just_pressed("enter"):
		_play_button_pressed()


func _play_button_pressed() -> void:
	await get_tree().create_timer(0.2).timeout
	SignalManager.emit_on_level_selected(_levels[_cursor])


func _previous_button_pressed() -> void:
	if _cursor > 0:
		_cursor -= 1
	else:
		_cursor = _levels.size() - 1

	_update_icon()


func _next_button_pressed() -> void:
	if _cursor < _levels.size() - 1:
		_cursor += 1
	else:
		_cursor = 0

	_update_icon()
	

func _update_icon() -> void:
	var level: Dictionary = _levels[_cursor]
	title.text = level.get("title")
	description.text = level.get("description")
