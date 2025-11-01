extends Window

@export var char_small_button: TextureButton
@export var char_medium_button: TextureButton
@export var volume_slider: HSlider
@export var exit_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	char_small_button.pressed.connect(_char_small_button_pressed)
	char_medium_button.pressed.connect(_char_medium_button_pressed)
	exit_button.pressed.connect(_exit_button_pressed)
	

func _char_small_button_pressed() -> void:
	GameManager.set_font_size(18)
	SignalManager.emit_on_character_size_changed()


func _char_medium_button_pressed() -> void:
	GameManager.set_font_size(25)
	SignalManager.emit_on_character_size_changed()


func _exit_button_pressed() -> void:
	hide()

