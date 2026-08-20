extends Node2D
## 王府场景根：夜召染色、标签、天气活物、装饰道具挂接。

func _ready() -> void:
	add_to_group("act1_world")
	_fix_labels()
	_ensure_weather_and_life()
	_spawn_decor()

func _fix_labels() -> void:
	var yard := get_node_or_null("YardLabel") as Label
	if yard:
		yard.text = "信王府 · 内院"
	var gate := get_node_or_null("GateLabel") as Label
	if gate:
		gate.text = "府门方向 →"
	var study := get_node_or_null("StudyLabel") as Label
	if study:
		study.text = "书房 · 林生"

func _ensure_weather_and_life() -> void:
	if get_node_or_null("AmbientLife") == null:
		var life := Node2D.new()
		life.name = "AmbientLife"
		life.set_script(load("res://scripts/act1/ambient_life.gd"))
		add_child(life)
	if get_node_or_null("WeatherFx") == null:
		var fx := CanvasLayer.new()
		fx.name = "WeatherFx"
		fx.set_script(load("res://scripts/act1/weather_fx.gd"))
		add_child(fx)

func _spawn_decor() -> void:
	if get_node_or_null("DecorRoot") != null:
		return
	var root := Node2D.new()
	root.name = "DecorRoot"
	root.z_index = 4
	root.y_sort_enabled = true
	add_child(root)
	## 等轴道具略缩小，树用顶视不压扁
	_add_prop(root, "barn.png", Vector2(1100, 220), 100.0, true)
	_add_prop(root, "scarecrow.png", Vector2(200, 300), 58.0, true)
	_add_prop(root, "crate.png", Vector2(520, 500), 34.0, true)
	_add_prop(root, "bale.png", Vector2(150, 450), 40.0, true)
	_add_prop(root, "table.png", Vector2(780, 180), 48.0, true)
	_add_veg(root, "tree_lg.png", Vector2(80, 160), 92.0, false)
	_add_veg(root, "tree_md.png", Vector2(1180, 140), 82.0, false)
	_add_veg(root, "tree_sm.png", Vector2(980, 520), 64.0, false)
	_add_prop(root, "rock.png", Vector2(880, 560), 30.0, false)
	_add_prop(root, "bucket.png", Vector2(420, 200), 28.0, true)

func _add_prop(parent: Node2D, filename: String, pos: Vector2, max_h: float, iso: bool) -> void:
	var t := ModelSprites.tex("props", filename)
	if t == null:
		return
	var s := Sprite2D.new()
	s.texture = t
	s.position = pos
	var squash := ModelSprites.ISO_SQUASH if iso else ModelSprites.TOP_SQUASH
	var scale := max_h / maxf(t.get_size().y, 1.0)
	s.scale = Vector2(scale, scale * squash)
	s.centered = true
	## 脚底对齐 position.y，便于 y_sort
	s.offset = Vector2(0, -t.get_size().y * 0.5)
	s.z_as_relative = true
	parent.add_child(s)

func _add_veg(parent: Node2D, filename: String, pos: Vector2, max_h: float, iso: bool) -> void:
	var t := ModelSprites.tex("vegetation", filename)
	if t == null:
		return
	var s := Sprite2D.new()
	s.texture = t
	s.position = pos
	var squash := ModelSprites.ISO_SQUASH if iso else ModelSprites.TOP_SQUASH
	var scale := max_h / maxf(t.get_size().y, 1.0)
	s.scale = Vector2(scale, scale * squash)
	s.centered = true
	s.offset = Vector2(0, -t.get_size().y * 0.5)
	parent.add_child(s)

func begin_night_tint() -> void:
	var tint: ColorRect = $NightTint
	tint.visible = true
	tint.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(tint, "modulate:a", 1.0, 1.2)
