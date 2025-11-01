extends Control

@export var score_label: Label
@export var combo_label: Label
@export var speed_label: Label
@export var class_label: Label
@export var back_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var score: int = GameManager.score
	var combo: int = GameManager.combo
	var successed: bool = GameManager.successed
	var speed: float = calc_speed()

	score_label.text = "SCORE: %03d" % score
	combo_label.text = "COMBO: %03d" % combo
	speed_label.text = "SPEED: %.1f CPS" % speed

	if not successed:
		class_label.text = "FAILED"
		class_label.add_theme_color_override("font_color", Color.html(("#808080")))
	elif speed > 6.0:
		class_label.text = "S"
		class_label.add_theme_color_override("font_color", Color.html(("#FFD700")))
	elif speed > 5.0:
		class_label.text = "A"
		class_label.add_theme_color_override("font_color", Color.html(("#C0C0C0")))
	elif speed > 4.0:
		class_label.text = "B"
		class_label.add_theme_color_override("font_color", Color.html(("#CD7F32")))
	elif speed > 3.0 :
		class_label.text = "C"
		class_label.add_theme_color_override("font_color", Color.html(("#808080")))
	else:
		class_label.text = "D"
		class_label.add_theme_color_override("font_color", Color.html(("#808080")))


	back_button.pressed.connect(_back_button_pressed)


func calc_speed() -> float:
	var e: float = GameManager.level.get("settings").get("expire") - GameManager.expire
	return GameManager.score / e


func _back_button_pressed() -> void:
	GameManager.load_main()
