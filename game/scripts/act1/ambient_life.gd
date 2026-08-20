extends Node2D
## 府内活物与植被轻动：蝶、虫、蛙、猫、狗（装饰为主，可偶发旁白）。

enum Kind { BUTTERFLY, BUG, FROG, CAT, DOG, BIRD }

var _critters: Array[Dictionary] = []
var _sway_targets: Array[Node2D] = []
var _t: float = 0.0
var _bark_cd: float = 12.0

func _ready() -> void:
	z_index = 12
	_spawn_all()
	await get_tree().process_frame
	_collect_sway()
	WorldClock.season_changed.connect(func(_s): queue_redraw())
	WorldClock.weather_changed.connect(func(_w): queue_redraw())

func _collect_sway() -> void:
	_sway_targets.clear()
	for n in get_tree().get_nodes_in_group("sway_plant"):
		if n is Node2D:
			_sway_targets.append(n as Node2D)
	for path in ["../Bush1/Visual", "../Bush2/Visual", "../Plots/Plot1/Visual", "../Plots/Plot2/Visual", "../Plots/Plot3/Visual"]:
		var v := get_node_or_null(path)
		if v is Node2D:
			_sway_targets.append(v as Node2D)

func _spawn_all() -> void:
	_critters.clear()
	_add(Kind.BUTTERFLY, Vector2(420, 300))
	_add(Kind.BUTTERFLY, Vector2(700, 340))
	_add(Kind.BUTTERFLY, Vector2(560, 260))
	_add(Kind.BUG, Vector2(480, 400))
	_add(Kind.BUG, Vector2(640, 430))
	_add(Kind.FROG, Vector2(900, 470))
	_add(Kind.FROG, Vector2(860, 500))
	_add(Kind.CAT, Vector2(320, 360))
	_add(Kind.DOG, Vector2(240, 480))
	_add(Kind.BIRD, Vector2(200, 120))
	_add(Kind.BIRD, Vector2(1000, 100))

func _add(kind: Kind, origin: Vector2) -> void:
	_critters.append({
		"kind": kind,
		"origin": origin,
		"pos": origin,
		"phase": randf() * TAU,
		"speed": randf_range(0.6, 1.4),
		"dir": 1.0 if randf() > 0.5 else -1.0,
	})

func _process(delta: float) -> void:
	_t += delta
	_bark_cd -= delta
	var wind := 1.0
	match WorldClock.weather:
		WorldClock.Weather.WIND:
			wind = 2.2
		WorldClock.Weather.RAIN:
			wind = 1.4
		WorldClock.Weather.SNOW:
			wind = 0.7
		_:
			wind = 1.0
	if WorldClock.disaster == "storm":
		wind = 2.8
	for i in _sway_targets.size():
		var n := _sway_targets[i]
		if not is_instance_valid(n):
			continue
		var amp := 0.04 * wind
		n.rotation = sin(_t * (1.5 + float(i) * 0.17) * wind) * amp
	for c in _critters:
		_move_critter(c, delta, wind)
	if _bark_cd <= 0.0 and WorldClock.weather == WorldClock.Weather.CLEAR and not Dialogue.is_busy():
		if randf() < 0.08:
			GameState.toast("院里小狗晃了晃尾巴")
			_bark_cd = 25.0
		else:
			_bark_cd = 8.0
	queue_redraw()

func _move_critter(c: Dictionary, delta: float, wind: float) -> void:
	c.phase = float(c.phase) + delta * float(c.speed)
	var kind: int = int(c.kind)
	var origin: Vector2 = c.origin
	match kind:
		Kind.BUTTERFLY:
			if WorldClock.weather == WorldClock.Weather.RAIN or WorldClock.weather == WorldClock.Weather.SNOW:
				c.pos = origin + Vector2(sin(c.phase) * 8.0, 4.0)
			else:
				c.pos = origin + Vector2(sin(c.phase) * 55.0 * wind, cos(c.phase * 1.7) * 28.0)
		Kind.BUG:
			c.pos = origin + Vector2(sin(c.phase * 2.0) * 18.0, absf(cos(c.phase)) * 6.0)
		Kind.FROG:
			if WorldClock.weather == WorldClock.Weather.RAIN or WorldClock.disaster == "flood":
				var hop := int(c.phase * 2.0) % 2
				c.pos = origin + Vector2(sin(c.phase) * 30.0, -float(hop) * 10.0)
			else:
				c.pos = origin + Vector2(sin(c.phase * 0.5) * 12.0, 0)
		Kind.CAT:
			c.pos = origin + Vector2(sin(c.phase * 0.35) * 70.0 * c.dir, sin(c.phase * 0.7) * 8.0)
		Kind.DOG:
			c.pos = origin + Vector2(sin(c.phase * 0.28) * 90.0, cos(c.phase * 0.5) * 12.0)
		Kind.BIRD:
			if WorldClock.weather == WorldClock.Weather.WIND or WorldClock.disaster == "storm":
				c.pos = origin + Vector2(sin(c.phase) * 120.0, cos(c.phase * 0.8) * 40.0 - 20.0)
			else:
				c.pos = origin + Vector2(sin(c.phase * 0.6) * 40.0, sin(c.phase) * 10.0)

func _draw() -> void:
	for c in _critters:
		_draw_one(c)

func _draw_one(c: Dictionary) -> void:
	var p: Vector2 = c.pos
	## 羊：用 spritesheet 左上角一帧
	if int(c.kind) == Kind.DOG:
		var sheep := ModelSprites.tex("creatures", "sheep_idle.png")
		if sheep:
			var cell := mini(64, sheep.get_width() / 4)
			draw_texture_rect_region(sheep, Rect2(p.x - 16, p.y - 24, 32, 32), Rect2(0, 0, cell, cell))
			return
	match int(c.kind):
		Kind.BUTTERFLY:
			var wing := Color(0.95, 0.75, 0.35, 0.9)
			if WorldClock.season == WorldClock.Season.AUTUMN:
				wing = Color(0.9, 0.45, 0.25, 0.9)
			draw_circle(p + Vector2(-3, 0), 3.2, wing)
			draw_circle(p + Vector2(3, 0), 3.2, wing.lightened(0.1))
			draw_circle(p, 1.4, Color(0.2, 0.15, 0.1, 1))
		Kind.BUG:
			draw_circle(p, 1.6, Color(0.25, 0.35, 0.15, 0.85))
			draw_circle(p + Vector2(2, -1), 1.0, Color(0.3, 0.4, 0.18, 0.7))
		Kind.FROG:
			draw_circle(p, 5.0, Color(0.35, 0.62, 0.32, 1))
			draw_circle(p + Vector2(-2, -3), 1.6, Color(0.9, 0.95, 0.7, 1))
			draw_circle(p + Vector2(2, -3), 1.6, Color(0.9, 0.95, 0.7, 1))
		Kind.CAT:
			draw_circle(p, 7.0, Color(0.85, 0.7, 0.45, 1))
			draw_circle(p + Vector2(-4, -6), 2.5, Color(0.85, 0.7, 0.45, 1))
			draw_circle(p + Vector2(4, -6), 2.5, Color(0.85, 0.7, 0.45, 1))
			draw_circle(p + Vector2(8, 2), 2.0, Color(0.85, 0.7, 0.45, 1))
		Kind.DOG:
			draw_circle(p, 8.0, Color(0.55, 0.4, 0.28, 1))
			draw_circle(p + Vector2(9, -2), 4.0, Color(0.55, 0.4, 0.28, 1))
		Kind.BIRD:
			draw_circle(p, 3.0, Color(0.25, 0.25, 0.3, 1))
			draw_line(p + Vector2(-5, 0), p + Vector2(5, 0), Color(0.2, 0.2, 0.25, 0.8), 1.5)
