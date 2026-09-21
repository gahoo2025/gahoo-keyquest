extends Area2D
class_name Enemy

## 敵（実装計画 第1弾ではスライム1種類のみ）。
## その場を中心に一定範囲を左右に往復するだけの単純な動きで、プレイヤーには反応しない。
## 「向き」は移動方向で決まるため、プレイヤーに近づいている最中はプレイヤー側を
## 向いていることになり、逆に遠ざかっている最中は「気づいていない」状態になる。

signal defeated(exp_reward: int, drops_key: bool)

@export var hp: int = 8
@export var contact_damage: int = 3
@export var patrol_range: float = 60.0
@export var patrol_speed: float = 40.0
@export var exp_reward: int = 8
## 撃破時に鍵をドロップするか（実装計画第1弾では確率ではなく、
## シーン上でどの個体がドロップするかを固定してテストの再現性を確保している）
@export var drops_key: bool = false

const KEY_PICKUP_SCENE: PackedScene = preload("res://scenes/key_pickup.tscn")

var facing: int = 1
var _origin_x: float
var _max_hp: int
var _defeated: bool = false

@onready var visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("enemies")
	_origin_x = position.x
	_max_hp = hp


func _process(delta: float) -> void:
	if _defeated:
		return
	position.x += facing * patrol_speed * delta
	if position.x >= _origin_x + patrol_range:
		facing = -1
	elif position.x <= _origin_x - patrol_range:
		facing = 1
	visual.scale.x = float(facing)


func take_damage(amount: int) -> void:
	if _defeated:
		return
	hp -= amount
	if hp <= 0:
		_on_defeated()


func _on_defeated() -> void:
	_defeated = true
	monitorable = false
	visible = false
	defeated.emit(exp_reward, drops_key)
	if drops_key:
		var pickup: Area2D = KEY_PICKUP_SCENE.instantiate()
		pickup.position = position
		get_parent().add_child(pickup)


## タイトル画面からのプレイ開始・リスタート時に状態を初期化する
func reset() -> void:
	_defeated = false
	hp = _max_hp
	position.x = _origin_x
	facing = 1
	monitorable = true
	visible = true
	visual.scale.x = 1.0
