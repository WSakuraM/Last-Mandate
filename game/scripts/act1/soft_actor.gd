extends Node2D
## 柔和卡通角色剪影（非像素）。用层叠圆/椭圆模拟热门 2D 成品的可读剪影。

@export var body_color: Color = Color(0.45, 0.38, 0.55, 1)
@export var accent_color: Color = Color(0.85, 0.72, 0.55, 1)
@export var scale_factor: float = 1.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var s := scale_factor
	# 影子
	draw_ellipse(Vector2(0, 22 * s), Vector2(16 * s, 6 * s), Color(0, 0, 0, 0.18))
	# 身体
	draw_ellipse(Vector2(0, 6 * s), Vector2(14 * s, 16 * s), body_color)
	# 头
	draw_circle(Vector2(0, -14 * s), 12 * s, accent_color)
	# 简单五官点
	draw_circle(Vector2(-4 * s, -15 * s), 1.6 * s, Color(0.2, 0.15, 0.12, 1))
	draw_circle(Vector2(4 * s, -15 * s), 1.6 * s, Color(0.2, 0.15, 0.12, 1))

func draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	var n := 32
	for i in n:
		var a := TAU * float(i) / float(n)
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
