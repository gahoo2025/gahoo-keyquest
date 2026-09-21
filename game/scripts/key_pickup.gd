extends Area2D

## 敵が落とす鍵。プレイヤーが接触すると自動で回収される（player.gdの_collect_keyで処理）。

func _ready() -> void:
	add_to_group("keys")
