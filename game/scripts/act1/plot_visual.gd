extends Node2D
## 菜畦/药圃：顶视土盘 + 压扁等轴作物。

var stage: int = 0
var herb_tint: bool = false
var _crop: String = "cabbage"
var _tex_s1: Texture2D
var _tex_s2: Texture2D
var _tex_s3: Texture2D
var _dirt: Texture2D

func _ready() -> void:
	_dirt = ModelSprites.tex("materials", "dirt_tile.png")
	if _dirt == null:
		_dirt = ModelSprites.tex("materials", "dirt_iso.png")
	_load_crop()
	queue_redraw()

func set_crop(kind: String) -> void:
	_crop = kind
	_load_crop()
	queue_redraw()

func set_stage(s: int) -> void:
	stage = s
	queue_redraw()

func set_herb_tint(on: bool) -> void:
	herb_tint = on
	if on:
		_crop = "spinach"
	_load_crop()
	queue_redraw()

func _load_crop() -> void:
	_tex_s1 = ModelSprites.crop_tex(_crop, 1)
	_tex_s2 = ModelSprites.crop_tex(_crop, 2)
	if _tex_s2 == null:
		_tex_s2 = _tex_s1
	_tex_s3 = ModelSprites.crop_tex(_crop, 3)

func _draw() -> void:
	var foot := Vector2(24, 34)
	## 顶视土盘（Hand-Drawn tilled）
	if _dirt:
		ModelSprites.draw_tex_rect(self, _dirt, Rect2(2, 10, 44, 36), Color(1, 1, 1, 0.95))
	else:
		StyleC.draw_outlined_ellipse(self, Vector2(24, 28), Vector2(26, 16), StyleC.DIRT, 2.0)
	var tint := Color(0.75, 0.92, 0.7, 1) if herb_tint else Color.WHITE
	match stage:
		0:
			pass
		1:
			var t := _tex_s1 if _tex_s1 else _tex_s2
			if t:
				ModelSprites.draw_grounded(self, t, foot, 28.0, tint, ModelSprites.ISO_SQUASH)
			else:
				StyleC.draw_outlined_circle(self, Vector2(24, 18), 5, Color(0.55, 0.85, 0.45, 1), 1.5)
		2:
			var t2 := _tex_s3 if _tex_s3 else _tex_s2
			if t2:
				ModelSprites.draw_grounded(self, t2, foot, 42.0, tint, ModelSprites.ISO_SQUASH)
			else:
				StyleC.draw_outlined_circle(self, Vector2(24, 14), 12, StyleC.LEAF, 2.0)
