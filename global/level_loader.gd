extends Node


func _ready() -> void:
	pass


func load_levels() -> Array[Dictionary]:

	const BASE: String = "res://levels/"
	var levels: Array[Dictionary] = []

	# ファイルをすべて取得
	var files: PackedStringArray = DirAccess.get_files_at(BASE)

	for file in files:
		# 拡張子がJSONのファイルのみ抽出
		var ext: String = file.get_extension().to_lower()
		if ext == "json":
			levels.append(load_json(BASE + file))

	return levels


func load_json(path: String) -> Dictionary:

	# JSONは存在するか?
	if not FileAccess.file_exists(path):
		print(path, " is not found.")
		return {}

	# JSONが正常にロードできるか?
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line(), ".")
		return {}

	# 辞書型?
	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		print("Type Error:", typeof(data))
		return {}

	print("JSON loaded.")
	return data as Dictionary


func validate(dict: Dictionary) -> bool:

	if dict.is_empty():
		print("Empty.")
		return false

	if not dict.has("title"):
		print("\"title\" not found.")
		return false

	if not dict.has("description"):
		print("\"description\" not found.")
		return false

	if not dict.has("settings"):
		print("\"settings\" not found.")
		return false

	var settings = dict.get("settings")

	if not settings.has("expire"):
		print("\"settings.expire\" not found.")
		return false
	if not settings.has("randomize"):
		print("\"settings.randomize\" not found.")
		return false

	if not dict.has("lines"):
		print("\"lines\" not found.")
		return false

	var lines = dict.get("lines")
	if typeof(lines) != TYPE_ARRAY:
		print("lines type has to be ARRAY.")
		return false
	if lines.size() < 1:
		print("Empty.")
		return false

	for l in lines:
		if not l.has("prompt") or not l.has("input") or not l.has("output"):
			print("\"prompt\", \"input\" or \"output\" not found.")
			return false

	return true
