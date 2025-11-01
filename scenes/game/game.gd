extends Control

@export var shake_animation: AnimationPlayer
@export var scroll: ScrollContainer
@export var vbox: VBoxContainer
@export var expire_bar: VSlider
@export var title_label: Label
@export var score_label: Label
@export var combo_label: Label

var rtls: PackedScene = preload("res://scenes/line/line.tscn")
var rtl: RichTextLabel = null

## レベル
var _level: Dictionary = {}
## レベル内の問題一覧
var _lines: Array = []
## 問題番号
var _cursor: int = 0
## 時間切れ
var _expire: float = 0.0
## ユーザ入力
var _user_input: String = ""
## コンボ
var _combo: int = 0
var _max_combo: int = _combo
## スコア
var _score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# レベルを取得
	_level = GameManager.level

	# 問題を取得
	_lines = _level.get("lines")

	# 問題を0番目に設定
	_cursor = 0

	# 設定に従い問題順序をランダムにする
	if _level.get("settings").get("randomize"):
		_lines.shuffle()

	# 始めの問題を作成する
	_made_line()
	# タイマーを開始する
	_set_slider()
	# タイトルを描画する
	title_label.text = _level.get("title")
	# 問題を描画する
	_draw_text()


func _set_slider() -> void:
	# 時間切れを設定する
	_expire = float(_level.get("settings").get("expire"))
	expire_bar.max_value = _expire
	expire_bar.value = _expire

	# タイマーを生成する
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)

	# カウントダウンする(awaitで非同期的に実行)
	while true:
		await timer.timeout
		_expire -= 1.0
		if _expire <= 0.0:
			SignalManager.emit_on_level_completed(_level, false, _score, _max_combo, _expire)

		expire_bar.value = _expire


## 新しい行を追加する
func _made_line() -> void:

	var new_line: RichTextLabel = rtls.instantiate() as RichTextLabel
	new_line.text = _lines[_cursor].get("prompt")

	# ボックスに問題を追加
	vbox.add_child(new_line)

	# 入力対象として設定
	rtl = new_line


## 入力が正しいときに表示する，コマンドの結果を表示する
func _made_output_line() -> void:

	var out_line: RichTextLabel = rtls.instantiate() as RichTextLabel
	out_line.text = _lines[_cursor].get("output") + "\n\n"

	# ボックスにコマンドの結果を追加
	vbox.add_child(out_line)


## キー入力を受け取る
##   BackSpace: 文字削除
##   Enter: 検証処理，出力表示+新しい問題の作成+ユーザ入力のリセット
##   その他: 文字入力
## 最後に表示を更新する
func _unhandled_key_input(event: InputEvent) -> void:
	# スルー
	if event is not InputEventKey:
		return
	if event.is_released():
		return


  # キー入力
	match event.keycode:
		# 削除(BackSpace)
		Key.KEY_BACKSPACE:
			_delete_user_input()
			_combo_reset()

		# 確定(Enter)
		Key.KEY_ENTER, Key.KEY_KP_ENTER:
			# 入力があっているか確認
			if _check_user_input():
				# あっていればコマンドの出力を表示
				_made_output_line()
				# スコアとして追加する
				_add_score()
				# ユーザの入力をリセットする
				_reset_user_input()

				# 問題がまだある場合
				if _cursor < _lines.size() - 1:
					# カーソルを進める
					_cursor += 1
					# 新しい問題を作成する
					_made_line()

				# 問題が全て完了していた場合
				else:
					SignalManager.emit_on_level_completed(_level, true, _score, _max_combo, _expire)
			# 入力があっていない場合
			else:
				_combo_reset()

		# 文字
		_:
			_add_user_input(event as InputEventKey)
			_combo_check()

	# シェイクアニメーション
	shake_animation.play("shake")
	# 描画処理
	_draw_text()
	_scroll_to_end()


## ユーザの入力を削除する
func _delete_user_input() -> void:
	if _user_input.length() > 0:
		_user_input = _user_input.substr(0, _user_input.length() - 1)


## ユーザの入力をASCIIとして受け取る
func _add_user_input(key: InputEventKey) -> void:
	if 0x20 <= key.unicode and key.unicode <= 0x7E:
		_user_input += char(key.unicode)


## 問題とユーザの入力が完全一致するか確認する
func _check_user_input() -> bool:
	return _lines[_cursor].get("input") == _user_input
	

## ユーザ入力をリセットする
func _reset_user_input() -> void:
	_user_input = ""


## スコアを追加する
func _add_score() -> void:
	_score += _user_input.length()


## コンボをチェックする
func _combo_check() -> void:
	var i = _user_input.length() - 1
	# ユーザの入力がお手本より長くなった瞬間
	# ユーザの入力とお手本が異なった瞬間
	if not (i < _lines[_cursor].get("input").length()) or _lines[_cursor].get("input")[i] != _user_input[i]:
		_combo_reset()
	else:
		_combo += 1	
		# 最高コンボ更新
		if _combo > _max_combo:
			_max_combo = _combo


func _combo_reset() -> void:
	_combo = 0
	
	
## RichTextLabelに入力を表示する
func _draw_text() -> void:

	var prompt: String = _lines[_cursor].get("prompt")
	var input: String = _lines[_cursor].get("input")

	var bb_text: String = ""

	# 入力された文字の装飾
	for i in range(_user_input.length()):

		# 入力長 > サンプル長は誤り
		# 文字が一致していない場合は当然誤り
		if not (i < input.length()) or input[i] != _user_input[i]:
			bb_text += bb_color("red", _user_input[i])
		else:
			bb_text += bb_color("green", _user_input[i])

	# 未入力文字の装飾
	bb_text += bb_bold(bb_color("gray", input.substr(_user_input.length(), input.length())))

	# 空白を可読文字にする
	bb_text = bb_text.replace(" ", "␣")

	# プロンプトを追加する
	bb_text = prompt + " " + bb_text

	# RichTextLabelに適用
	rtl.text = bb_text

	# スコアとコンボを表示する
	score_label.text = "SCORE: %03d" % _score
	combo_label.text = "COMBO: %03d" % _combo


## BBCodeで色を付ける
func bb_color(color: String, text: String) -> String:
	return "[color=%s]%s[/color]" % [color, text]


## BBCodeを太字にする
func bb_bold(text:String) -> String:
	return "[b]%s[/b]" % [text]


## スクロールを最下層まで移動
func _scroll_to_end() -> void:
	await scroll.get_v_scroll_bar().changed
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
