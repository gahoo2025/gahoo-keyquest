extends Area2D
class_name Player

## プレイヤー（冒険者）
## 操作方法：左右移動のみ（矢印キー・A/Dキー・画面下部のタッチボタン）。
## 専用の攻撃ボタンは無く、敵に接触した瞬間に自動でバンプ戦闘の判定が発生する。
## 判定ルールは gamedev/gahoo-keyquest-spec.md「1.1 バンプ戦闘の判定ルール」参照。

signal hp_changed(hp: int, max_hp: int)
signal keys_changed(count: int)
signal exp_changed(exp: int, exp_to_next: int, level: int)
signal died

const BASE_MAX_HP := 20
const BASE_ATTACK := 5
const EXP_BASE := 15
const BLINK_INTERVAL := 0.08

@export var move_speed: float = 160.0
@export var invincible_time: float = 0.6

var hp: int = BASE_MAX_HP
var max_hp: int = BASE_MAX_HP
var attack_power: int = BASE_ATTACK
var facing: int = 1
var keys: int = 0
var level: int = 1
var exp: int = 0
var exp_to_next: int = EXP_BASE

var invincible: bool = false
var _invincible_elapsed: float = 0.0
var _blink_elapsed: float = 0.0

# 画面下部のタッチボタン（左右のみ。上下移動は無いためD-padではなく2ボタン）から設定される
var dpad_left: bool = false
var dpad_right: bool = false

@onready var visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("player")
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	# ui_left/ui_rightは矢印キー（エンジン標準の割り当て）。WASDはプロジェクト設定を
	# 追加せずに済むよう、ここで直接キーコードを見て加算している
	var dir: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if Input.is_key_pressed(KEY_D):
		dir += 1.0
	if Input.is_key_pressed(KEY_A):
		dir -= 1.0
	if dpad_right:
		dir += 1.0
	if dpad_left:
		dir -= 1.0
	dir = clamp(dir, -1.0, 1.0)

	if dir != 0.0:
		position.x += dir * move_speed * delta
		facing = 1 if dir > 0.0 else -1
		visual.scale.x = float(facing)

	if invincible:
		_invincible_elapsed += delta
		_blink_elapsed += delta
		if _blink_elapsed >= BLINK_INTERVAL:
			_blink_elapsed = 0.0
			visual.visible = not visual.visible
		if _invincible_elapsed >= invincible_time:
			invincible = false
			visual.visible = true


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		_resolve_bump(area as Enemy)
	elif area.is_in_group("keys"):
		_collect_key(area)
	elif area.is_in_group("door"):
		(area as Door).try_open(self)


## バンプ戦闘の判定（向きは移動方向で決まる）：
## - お互い正面から向き合ってぶつかる：五分五分、両方がダメージを受ける
## - プレイヤーが敵の方を向いていて、敵はこちらに気づいていない（背中向き）：一撃撃破
## - プレイヤーが敵に背を向けている状態でぶつかられる：一方的に被弾
## - どちらも相手の方を向いていない（すれ違い）：何も起きない
func _resolve_bump(enemy: Enemy) -> void:
	if invincible:
		return
	var dx: float = enemy.position.x - position.x
	var dir_to_enemy: int = 1 if dx >= 0.0 else -1
	var dir_to_player: int = -dir_to_enemy
	var player_facing_enemy: bool = facing == dir_to_enemy
	var enemy_facing_player: bool = enemy.facing == dir_to_player

	if player_facing_enemy and enemy_facing_player:
		enemy.take_damage(attack_power)
		take_damage(enemy.contact_damage)
	elif player_facing_enemy and not enemy_facing_player:
		enemy.take_damage(enemy.hp)
	elif not player_facing_enemy and enemy_facing_player:
		take_damage(enemy.contact_damage)
	# それ以外（すれ違い）は何もしない


func take_damage(amount: int) -> void:
	if invincible:
		return
	hp = max(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	invincible = true
	_invincible_elapsed = 0.0
	_blink_elapsed = 0.0
	if hp <= 0:
		died.emit()


func gain_exp(amount: int) -> void:
	exp += amount
	while exp >= exp_to_next:
		exp -= exp_to_next
		level += 1
		max_hp += 5
		hp = max_hp
		attack_power += 2
		exp_to_next = EXP_BASE * level
	exp_changed.emit(exp, exp_to_next, level)
	hp_changed.emit(hp, max_hp)


func _collect_key(key_area: Node) -> void:
	key_area.queue_free()
	keys += 1
	keys_changed.emit(keys)


## タイトル画面からのプレイ開始・リスタート時に状態を初期化する
func reset(start_position: Vector2) -> void:
	position = start_position
	facing = 1
	visual.scale.x = 1.0
	max_hp = BASE_MAX_HP
	attack_power = BASE_ATTACK
	hp = max_hp
	keys = 0
	level = 1
	exp = 0
	exp_to_next = EXP_BASE
	invincible = false
	visual.visible = true
	hp_changed.emit(hp, max_hp)
	keys_changed.emit(keys)
	exp_changed.emit(exp, exp_to_next, level)


## ゲームの状態（タイトル/プレイ中/ゲームオーバー/クリア）に応じて入力受付・表示を切り替える
func set_active(active: bool) -> void:
	set_process(active)
	monitoring = active
	visible = active
	dpad_left = false
	dpad_right = false
