extends Node2D
## 鱼塘：水贴图切片 + 回退色块。

var _water: Texture2D

func _ready() -> void:
	_water = ModelSprites.tex("materials", "water_sheet.png")
	queue_redraw()

func _draw() -> void:
	if _water:
		## spritesheet 取左上角一格近似水面
		var cell := mini(128, int(_water.get_width() / 2))
		var src := Rect2(0, 0, cell, cell)
		draw_texture_rect_region(_water, Rect2(-70, -30, 140, 70), src, Color(0.85, 0.95, 1.0, 0.95))
		return
	StyleC.draw_outlined_ellipse(self, Vector2(0, 10), Vector2(70, 36), Color(0.35, 0.55, 0.7, 1), 2.0)
	StyleC.draw_outlined_ellipse(self, Vector2(0, 6), Vector2(58, 28), Color(0.42, 0.62, 0.78, 1), 1.5)
