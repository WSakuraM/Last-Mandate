extends Node2D
## 井：泵机贴图（包内无井），压扁贴地。

var _pump: Texture2D

func _ready() -> void:
	_pump = ModelSprites.tex("props", "pump.png")
	queue_redraw()

func _draw() -> void:
	if _pump:
		ModelSprites.draw_grounded(self, _pump, Vector2(0, 28), 64.0)
		return
	StyleC.draw_outlined_circle(self, Vector2(0, 0), 20, Color(0.55, 0.55, 0.52, 1), 2.0)
	StyleC.draw_outlined_circle(self, Vector2(0, 0), 14, Color(0.35, 0.5, 0.62, 1), 1.5)
