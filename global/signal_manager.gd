extends Node


signal on_level_selected(level: Dictionary)
signal on_level_completed(level: Dictionary, successd: bool, score: int, combo: int, expire: int)
signal on_level_backed()
signal on_character_size_changed()


func emit_on_level_selected(level: Dictionary) -> void:
	emit_signal("on_level_selected", level)


func emit_on_level_completed(level: Dictionary, successd: bool, score: int, combo: int, expire: float) -> void:
	emit_signal("on_level_completed", level, successd, score, combo, expire)


func emit_on_result_checked() -> void:
	emit_signal("on_level_backed")


func emit_on_character_size_changed() -> void:
	emit_signal("on_character_size_changed")