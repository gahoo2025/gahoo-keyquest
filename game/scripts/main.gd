extends Node2D

## gahoo-keyquest ゲーム進行管理（実装計画 第1弾：ミニマム動作版）
## タイトル → プレイ（ステージ1のみ）→ クリア/ゲームオーバー → タイトル
## gamedev/gahoo-keyquest-plan-01.md 参照

enum State { TITLE, PLAYING, GAME_OVER, CLEAR }

const PLAYER_START_POSITION := Vector2(60, 380)
const MESSAGE_DURATION := 1.6

var state: State = State.TITLE
var _message_time_left: float = 0.0

@onready var player: Player = $Player
@onready var enemy_container: Node2D = $EnemyContainer
@onready var door: Door = $Door

@onready var hp_label: Label = $UI/HPLabel
@onready var keys_label: Label = $UI/KeysLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var message_label: Label = $UI/MessageLabel

@onready var title_screen: Control = $UI/TitleScreen
@onready var game_over_screen: Control = $UI/GameOverScreen
@onready var clear_screen: Control = $UI/ClearScreen

@onready var btn_left: Button = $UI/TouchControls/ButtonLeft
@onready var btn_right: Button = $UI/TouchControls/ButtonRight


func _ready() -> void:
	player.hp_changed.connect(_on_player_hp_changed)
	player.keys_changed.connect(_on_player_keys_changed)
	player.exp_changed.connect(_on_player_exp_changed)
	player.died.connect(_on_player_died)
	door.opened.connect(_on_door_opened)
	door.blocked.connect(_on_door_blocked)

	for enemy: Enemy in enemy_container.get_children():
		enemy.defeated.connect(_on_enemy_defeated)

	title_screen.get_node("PlayButton").pressed.connect(start_game)
	game_over_screen.get_node("RestartButton").pressed.connect(start_game)
	clear_screen.get_node("RestartButton").pressed.connect(start_game)

	_bind_touch_button(btn_left, func(pressed: bool) -> void: player.dpad_left = pressed)
	_bind_touch_button(btn_right, func(pressed: bool) -> void: player.dpad_right = pressed)

	keys_label.text = "鍵: 0/%d" % door.required_keys
	_set_screen(State.TITLE)


func _process(delta: float) -> void:
	if _message_time_left > 0.0:
		_message_time_left -= delta
		if _message_time_left <= 0.0:
			message_label.visible = false


func start_game() -> void:
	player.reset(PLAYER_START_POSITION)
	for enemy: Enemy in enemy_container.get_children():
		enemy.reset()
	for pickup in get_tree().get_nodes_in_group("keys"):
		pickup.queue_free()
	door.reset()
	_set_screen(State.PLAYING)


func _set_screen(new_state: State) -> void:
	state = new_state
	title_screen.visible = new_state == State.TITLE
	game_over_screen.visible = new_state == State.GAME_OVER
	clear_screen.visible = new_state == State.CLEAR
	var playing: bool = new_state == State.PLAYING
	player.set_active(playing)
	for enemy: Enemy in enemy_container.get_children():
		enemy.set_process(playing)
	message_label.visible = false


func _on_enemy_defeated(exp_reward: int, _drops_key: bool) -> void:
	player.gain_exp(exp_reward)


func _on_player_hp_changed(hp: int, max_hp: int) -> void:
	hp_label.text = "HP: %d/%d" % [hp, max_hp]


func _on_player_keys_changed(count: int) -> void:
	keys_label.text = "鍵: %d/%d" % [count, door.required_keys]


func _on_player_exp_changed(exp: int, exp_to_next: int, level: int) -> void:
	level_label.text = "Lv.%d (EXP %d/%d)" % [level, exp, exp_to_next]


func _on_player_died() -> void:
	_set_screen(State.GAME_OVER)


func _on_door_opened() -> void:
	_set_screen(State.CLEAR)


func _on_door_blocked(required: int, have: int) -> void:
	message_label.text = "鍵が足りない！（%d/%d）" % [have, required]
	message_label.visible = true
	_message_time_left = MESSAGE_DURATION


## Godotの Button は button_down/button_up をタッチ・マウス両方で発火するため、
## 個別に入力イベントを処理せずシンプルにタッチボタンを実装できる
func _bind_touch_button(button: Button, setter: Callable) -> void:
	button.button_down.connect(func() -> void: setter.call(true))
	button.button_up.connect(func() -> void: setter.call(false))
