extends Node2D
## 王府场景根：夜召染色。

func _ready() -> void:
	add_to_group("act1_world")

func begin_night_tint() -> void:
	var tint: ColorRect = $NightTint
	tint.visible = true
	tint.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(tint, "modulate:a", 1.0, 1.2)
