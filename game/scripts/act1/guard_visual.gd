extends Node2D
## 护卫棚：谷仓剪影，压扁贴地。

var _barn: Texture2D

func _ready() -> void:
	_barn = ModelSprites.tex("props", "barn.png")
	queue_redraw()

func _draw() -> void:
	if _barn:
		ModelSprites.draw_grounded(self, _barn, Vector2(0, 36), 78.0)
		return
	StyleC.draw_outlined_ellipse(self, Vector2(0, 22), Vector2(30, 10), Color(0, 0, 0, 0.16), 1.0)
	draw_rect(Rect2(-26, -6, 52, 30), Color(0.42, 0.36, 0.3, 1))
