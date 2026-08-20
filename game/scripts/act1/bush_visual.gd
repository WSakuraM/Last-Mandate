extends Node2D
## 灌木：Hand-Drawn 顶视，不压扁。

var _picked: bool = false
var _bush: Texture2D
var _bush_empty: Texture2D

func _ready() -> void:
	_bush = ModelSprites.tex("vegetation", "bush_forage.png")
	if _bush == null:
		_bush = ModelSprites.tex("vegetation", "bush_a.png")
	_bush_empty = ModelSprites.tex("vegetation", "bush_b.png")
	queue_redraw()

func set_picked(picked: bool) -> void:
	_picked = picked
	queue_redraw()

func _draw() -> void:
	var t := _bush_empty if _picked and _bush_empty else _bush
	if t:
		var mod := Color(0.75, 0.75, 0.7, 1) if _picked else Color.WHITE
		ModelSprites.draw_grounded(self, t, Vector2(0, 18), 48.0, mod, ModelSprites.TOP_SQUASH)
		return
	StyleC.draw_outlined_ellipse(self, Vector2(0, 18), Vector2(18, 6), Color(0, 0, 0, 0.18), 1.0)
	var leaf := StyleC.LEAF if not _picked else Color(0.55, 0.5, 0.4, 1)
	StyleC.draw_outlined_circle(self, Vector2(0, -4), 14, leaf, 2.0)
