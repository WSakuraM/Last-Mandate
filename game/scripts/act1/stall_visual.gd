extends Node2D
## 售卖摊：Great Farm Stall，压扁贴地。

var _stall: Texture2D

func _ready() -> void:
	_stall = ModelSprites.tex("props", "stall.png")
	queue_redraw()

func _draw() -> void:
	if _stall:
		ModelSprites.draw_grounded(self, _stall, Vector2(35, 70), 82.0)
		return
	draw_rect(Rect2(0, 28, 70, 40), Color(0.72, 0.55, 0.38, 1), true, -1.0, true)
	var roof := PackedVector2Array([Vector2(-4, 22), Vector2(35, 2), Vector2(74, 22)])
	draw_colored_polygon(roof, Color(0.78, 0.35, 0.32, 1))
