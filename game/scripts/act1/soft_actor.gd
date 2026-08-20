extends Node2D
## 风格 C 赛璐璐角色：有 PNG 用贴图（立绘缩小贴地），否则按 look 画剪影。

@export var body_color: Color = Color(0.55, 0.42, 0.72, 1)
@export var accent_color: Color = Color(0.95, 0.85, 0.7, 1)
@export var hair_color: Color = Color(0.18, 0.14, 0.14, 1)
@export var scale_factor: float = 1.0
## 对应 assets/models/characters/{name}.png
@export var sprite_name: String = ""
## prince / aen / elder / lady / maiden / child / soldier / scholar / eunuch / weaver / ragged
@export var look: String = "default"
## 院落显示高度（立绘半身图需压小）
@export var sprite_max_h: float = 72.0

var _tex: Texture2D

func _ready() -> void:
	if sprite_name != "":
		_tex = AssetBank.load_texture("characters", sprite_name + ".png")
	queue_redraw()

func _draw() -> void:
	var s := scale_factor
	if _tex != null:
		StyleC.draw_outlined_ellipse(self, Vector2(0, 22 * s), Vector2(14 * s, 5 * s), Color(0, 0, 0, 0.18), 1.0)
		ModelSprites.draw_grounded(self, _tex, Vector2(0, 22 * s), sprite_max_h * s, Color.WHITE, ModelSprites.TOP_SQUASH)
		return
	_draw_silhouette(s)

func _draw_silhouette(s: float) -> void:
	## 影子
	StyleC.draw_outlined_ellipse(self, Vector2(0, 22 * s), Vector2(16 * s, 6 * s), Color(0, 0, 0, 0.2), 1.0)
	var body_w := 14.0
	var body_h := 16.0
	var head_y := -14.0
	var head_r := 12.0
	match look:
		"prince":
			body_w = 15.0
			StyleC.draw_outlined_ellipse(self, Vector2(0, 8 * s), Vector2(18 * s, 14 * s), body_color.darkened(0.08), 2.0)
		"lady", "maiden":
			body_w = 16.0
			body_h = 18.0
			head_y = -15.0
		"elder":
			body_w = 15.0
			body_h = 15.0
			head_r = 11.0
		"child":
			body_w = 11.0
			body_h = 12.0
			head_y = -10.0
			head_r = 10.0
		"soldier":
			body_w = 15.0
			body_h = 17.0
		"eunuch":
			body_w = 14.0
			head_y = -13.0
		"scholar":
			body_w = 13.0
			body_h = 17.0
		"ragged":
			body_w = 13.0
			body_h = 14.0
		_:
			pass
	StyleC.draw_outlined_ellipse(self, Vector2(0, 6 * s), Vector2(body_w * s, body_h * s), body_color, 2.2)
	match look:
		"prince":
			draw_line(Vector2(-10 * s, 4 * s), Vector2(10 * s, 4 * s), Color(0.72, 0.55, 0.2, 1), 2.5 * s)
		"soldier":
			draw_rect(Rect2(-8 * s, 0, 16 * s, 10 * s), body_color.lightened(0.12), false, 1.5 * s)
		"scholar":
			draw_rect(Rect2(8 * s, 2 * s, 5 * s, 8 * s), Color(0.92, 0.88, 0.78, 1), true)
			draw_rect(Rect2(8 * s, 2 * s, 5 * s, 8 * s), StyleC.OUTLINE, false, 1.0)
		"weaver":
			draw_line(Vector2(-12 * s, 10 * s), Vector2(12 * s, 10 * s), Color(0.85, 0.7, 0.55, 1), 2.0 * s)
		"elder":
			draw_line(Vector2(14 * s, -6 * s), Vector2(16 * s, 20 * s), Color(0.45, 0.32, 0.2, 1), 2.2 * s)
		_:
			pass
	StyleC.draw_outlined_circle(self, Vector2(0, head_y * s), head_r * s, accent_color, 2.2)
	_draw_hair(s, head_y, head_r)
	var eye_y := (head_y - 1.0) * s
	draw_circle(Vector2(-4 * s, eye_y), 1.8 * s, StyleC.OUTLINE)
	draw_circle(Vector2(4 * s, eye_y), 1.8 * s, StyleC.OUTLINE)
	draw_circle(Vector2(-7 * s, (head_y + 2.0) * s), 2.2 * s, Color(1.0, 0.55, 0.55, 0.35))
	draw_circle(Vector2(7 * s, (head_y + 2.0) * s), 2.2 * s, Color(1.0, 0.55, 0.55, 0.35))

func _draw_hair(s: float, head_y: float, head_r: float) -> void:
	var hy := head_y * s
	var hr := head_r * s
	match look:
		"prince":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.55), Vector2(hr * 0.7, hr * 0.35), hair_color, 1.5)
			draw_rect(Rect2(-3 * s, hy - hr - 4 * s, 6 * s, 5 * s), Color(0.55, 0.42, 0.2, 1), true)
		"aen":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.4), Vector2(hr * 0.95, hr * 0.45), hair_color, 1.5)
		"elder":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.35), Vector2(hr * 0.9, hr * 0.4), Color(0.55, 0.52, 0.5, 1), 1.5)
		"lady":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.7), Vector2(hr * 0.85, hr * 0.5), hair_color, 1.5)
			draw_circle(Vector2(-hr * 0.7, hy), 3.5 * s, hair_color)
			draw_circle(Vector2(hr * 0.7, hy), 3.5 * s, hair_color)
		"maiden":
			StyleC.draw_outlined_circle(self, Vector2(-hr * 0.75, hy - 2 * s), 4.5 * s, hair_color, 1.2)
			StyleC.draw_outlined_circle(self, Vector2(hr * 0.75, hy - 2 * s), 4.5 * s, hair_color, 1.2)
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.45), Vector2(hr * 0.9, hr * 0.35), hair_color, 1.2)
		"child":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.35), Vector2(hr * 0.85, hr * 0.35), hair_color, 1.2)
		"soldier":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.35), Vector2(hr * 1.05, hr * 0.55), Color(0.4, 0.42, 0.38, 1), 1.8)
		"eunuch":
			draw_line(Vector2(-hr * 0.8, hy - 2 * s), Vector2(hr * 0.8, hy - 2 * s), Color(0.75, 0.2, 0.18, 1), 2.0 * s)
		"scholar":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.4), Vector2(hr * 0.9, hr * 0.4), hair_color, 1.5)
		"weaver":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.4), Vector2(hr * 0.95, hr * 0.4), hair_color, 1.5)
		"ragged":
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.3), Vector2(hr * 0.8, hr * 0.3), hair_color.lightened(0.15), 1.2)
		_:
			StyleC.draw_outlined_ellipse(self, Vector2(0, hy - hr * 0.4), Vector2(hr * 0.9, hr * 0.4), hair_color, 1.5)
