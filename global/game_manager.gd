extends Node


var _main_scene: PackedScene = load("res://scenes/main/main.tscn")
var _pre_scene: PackedScene = load("res://scenes/pre/pre.tscn")
var _game_scene: PackedScene = load("res://scenes/game/game.tscn")
var _result_scene: PackedScene = load("res://scenes/result/result.tscn")

var font_size: int = 0

var level: Dictionary = {}
var successed: bool = false
var score: int = 0
var combo: int = 0
var expire: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_level_selected.connect(load_pre)
	SignalManager.on_level_completed.connect(load_result)
	SignalManager.on_level_backed.connect(load_main)
	

func set_font_size(s: int) -> void:
	font_size = s


func get_font_size() -> int:
	return font_size


func load_main() -> void:
	get_tree().change_scene_to_packed(_main_scene)


func load_pre(p_level: Dictionary) -> void:
	level = p_level
	get_tree().change_scene_to_packed(_pre_scene)


func load_game() -> void:
	get_tree().change_scene_to_packed(_game_scene)


func load_result(p_level: Dictionary, p_successed: bool, p_score: int, p_combo: int, p_expire: float) -> void:
	level = p_level
	successed = p_successed
	score = p_score
	combo = p_combo
	expire = p_expire
	get_tree().change_scene_to_packed(_result_scene)
	
