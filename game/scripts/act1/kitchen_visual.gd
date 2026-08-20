extends Node2D
## 灶口：桌子道具，压扁贴地。

var _table: Texture2D

func _ready() -> void:
	_table = ModelSprites.tex("props", "table.png")
	queue_redraw()

func _draw() -> void:
	if _table:
		ModelSprites.draw_grounded(self, _table, Vector2(0, 24), 62.0)
		draw_circle(Vector2(0, 8), 6, Color(0.95, 0.45, 0.2, 0.7))
		return
	StyleC.draw_outlined_ellipse(self, Vector2(0, 18), Vector2(28, 10), Color(0, 0, 0, 0.15), 1.0)
	draw_rect(Rect2(-22, -8, 44, 28), Color(0.45, 0.32, 0.22, 1))
