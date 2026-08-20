extends Node2D
## 用 CC0 草地砖铺满背景。

@export var tile_texture: Texture2D
@export var tile_scale: float = 3.0
@export var cols: int = 28
@export var rows: int = 16

func _ready() -> void:
	if tile_texture == null:
		tile_texture = preload("res://assets/tiles/grass.png")
	var sz := tile_texture.get_size() * tile_scale
	for y in rows:
		for x in cols:
			var s := Sprite2D.new()
			s.texture = tile_texture
			s.centered = false
			s.scale = Vector2(tile_scale, tile_scale)
			s.position = Vector2(x * sz.x, y * sz.y)
			s.z_index = -10
			# 轻微：略微调色贴近暖纸色
			s.modulate = Color(1.05, 1.0, 0.92, 1)
			add_child(s)
