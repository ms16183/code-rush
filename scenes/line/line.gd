extends RichTextLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_character_size_changed.connect(_character_size_changed)
	_character_size_changed()


func _character_size_changed() -> void:
	if GameManager.font_size > 0:
		add_theme_font_size_override("bold_font_size", GameManager.font_size)
		add_theme_font_size_override("bold_italics_font_size", GameManager.font_size)
		add_theme_font_size_override("italics_font_size", GameManager.font_size)
		add_theme_font_size_override("mono_font_size", GameManager.font_size)
		add_theme_font_size_override("normal_font_size", GameManager.font_size)
