extends Node2D
## 非像素柔和卡通地面（对标热门 2D 成品：干净色块、软边、非像素栅格）。

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# 暖纸色大底
	draw_rect(Rect2(0, 0, 1600, 900), Color(0.93, 0.89, 0.78, 1))
	# 柔和草地岛
	_draw_soft_ellipse(Vector2(640, 420), Vector2(520, 280), Color(0.62, 0.78, 0.48, 1))
	_draw_soft_ellipse(Vector2(640, 420), Vector2(480, 250), Color(0.68, 0.82, 0.52, 1))
	# 土路
	_draw_soft_ellipse(Vector2(640, 430), Vector2(460, 70), Color(0.78, 0.66, 0.48, 1))
	_draw_soft_ellipse(Vector2(640, 430), Vector2(420, 52), Color(0.84, 0.72, 0.54, 1))
	# 远处浅丘
	_draw_soft_ellipse(Vector2(200, 160), Vector2(180, 60), Color(0.72, 0.8, 0.58, 0.7))
	_draw_soft_ellipse(Vector2(1050, 140), Vector2(200, 70), Color(0.7, 0.78, 0.56, 0.65))

func _draw_soft_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	var n := 48
	for i in n:
		var a := TAU * float(i) / float(n)
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
