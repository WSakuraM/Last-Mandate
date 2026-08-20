extends Node2D
## 菜畦柔和绘制。

var stage: int = 0 # 0 empty 1 planted 2 ready

func set_stage(s: int) -> void:
	stage = s
	queue_redraw()

func _draw() -> void:
	# 土床
	_ellipse(Vector2(24, 28), Vector2(26, 16), Color(0.62, 0.48, 0.32, 1))
	_ellipse(Vector2(24, 26), Vector2(22, 12), Color(0.7, 0.55, 0.38, 1))
	match stage:
		1:
			# 嫩芽
			draw_circle(Vector2(18, 18), 4, Color(0.55, 0.78, 0.4, 1))
			draw_circle(Vector2(28, 16), 3.5, Color(0.5, 0.74, 0.36, 1))
		2:
			# 成熟菜
			draw_circle(Vector2(24, 14), 10, Color(0.35, 0.65, 0.32, 1))
			draw_circle(Vector2(18, 12), 6, Color(0.42, 0.72, 0.38, 1))
			draw_circle(Vector2(30, 13), 6, Color(0.4, 0.7, 0.36, 1))

func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 28:
		var a := TAU * float(i) / 28.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
