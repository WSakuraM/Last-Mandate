extends Node2D
## 售卖摊柔和卡通外形。

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# 台面
	draw_rect(Rect2(0, 28, 70, 40), Color(0.72, 0.55, 0.38, 1), true, -1.0, true)
	draw_rect(Rect2(4, 20, 62, 14), Color(0.85, 0.7, 0.5, 1), true, -1.0, true)
	# 顶棚
	var roof := PackedVector2Array([Vector2(-4, 22), Vector2(35, 2), Vector2(74, 22)])
	draw_colored_polygon(roof, Color(0.78, 0.35, 0.32, 1))
	# 招牌布
	draw_rect(Rect2(12, 24, 46, 12), Color(0.95, 0.9, 0.8, 1), true, -1.0, true)
