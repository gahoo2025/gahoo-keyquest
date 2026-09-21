extends Area2D
class_name Door

## ステージ末尾の扉。プレイヤーが触れた時点で鍵の所持数が足りていれば開いて次へ進める。
## 足りない場合は開かず、blockedシグナルでmain.gdにメッセージ表示を依頼する。

signal opened
signal blocked(required: int, have: int)

@export var required_keys: int = 2

var _opened: bool = false


func _ready() -> void:
	add_to_group("door")


func try_open(player: Player) -> void:
	if _opened:
		return
	if player.keys >= required_keys:
		_opened = true
		monitorable = false
		opened.emit()
	else:
		blocked.emit(required_keys, player.keys)


## タイトル画面からのプレイ開始・リスタート時に状態を初期化する
func reset() -> void:
	_opened = false
	monitorable = true
