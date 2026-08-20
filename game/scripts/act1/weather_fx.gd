extends CanvasLayer
## 天气与天灾画面层：雨雪粒子、风偏色、旱蝗遮罩。

var _tint: ColorRect
var _fx: Node2D
var _particles: Array[Dictionary] = []
var _wind_phase: float = 0.0
var _shake: float = 0.0

func _ready() -> void:
	layer = 8
	_tint = ColorRect.new()
	_tint.name = "Tint"
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tint.color = Color(1, 1, 1, 0)
	add_child(_tint)
	_fx = Node2D.new()
	_fx.name = "Fx"
	add_child(_fx)
	_fx.draw.connect(_draw_fx)
	WorldClock.weather_changed.connect(_on_changed)
	WorldClock.disaster_changed.connect(_on_disaster)
	WorldClock.season_changed.connect(_on_changed)
	_rebuild()

func _process(delta: float) -> void:
	_wind_phase += delta * (2.2 if WorldClock.weather == WorldClock.Weather.WIND else 1.0)
	_shake = maxf(0.0, _shake - delta)
	_update_particles(delta)
	_fx.queue_redraw()

func _on_changed(_v = null) -> void:
	_rebuild()

func _on_disaster(_k: String) -> void:
	_rebuild()
	if WorldClock.disaster in ["storm", "locust"]:
		_shake = 0.35

func _rebuild() -> void:
	_particles.clear()
	var base := Color(1, 1, 1, 0)
	match WorldClock.season:
		WorldClock.Season.SPRING:
			base = Color(0.85, 0.95, 0.78, 0.06)
		WorldClock.Season.SUMMER:
			base = Color(1.0, 0.95, 0.75, 0.08)
		WorldClock.Season.AUTUMN:
			base = Color(0.95, 0.82, 0.55, 0.1)
		WorldClock.Season.WINTER:
			base = Color(0.75, 0.85, 0.95, 0.12)
	match WorldClock.weather:
		WorldClock.Weather.RAIN, WorldClock.Weather.SNOW:
			base = base.lerp(Color(0.55, 0.62, 0.7, 0.18), 0.5)
		WorldClock.Weather.WIND:
			base = base.lerp(Color(0.9, 0.9, 0.85, 0.1), 0.4)
		_:
			pass
	match WorldClock.disaster:
		"drought":
			base = Color(0.92, 0.78, 0.55, 0.22)
		"locust":
			base = Color(0.72, 0.78, 0.42, 0.2)
		"storm", "flood":
			base = Color(0.45, 0.55, 0.65, 0.28)
		_:
			pass
	_tint.color = base
	var count := 0
	match WorldClock.weather:
		WorldClock.Weather.RAIN:
			count = 90 if WorldClock.disaster != "storm" else 140
		WorldClock.Weather.SNOW:
			count = 70
		WorldClock.Weather.WIND:
			count = 28
		_:
			count = 0
	if WorldClock.disaster == "locust":
		count = maxi(count, 50)
	for i in count:
		_particles.append(_spawn_one())

func _spawn_one() -> Dictionary:
	var kind := "rain"
	if WorldClock.disaster == "locust" and randf() < 0.55:
		kind = "locust"
	elif WorldClock.weather == WorldClock.Weather.SNOW:
		kind = "snow"
	elif WorldClock.weather == WorldClock.Weather.WIND:
		kind = "leaf"
	elif WorldClock.weather == WorldClock.Weather.RAIN:
		kind = "rain"
	return {
		"kind": kind,
		"pos": Vector2(randf() * 1280.0, randf() * 720.0),
		"spd": Vector2(randf_range(-20, 40), randf_range(120, 280)),
		"size": randf_range(1.5, 4.0),
	}

func _update_particles(delta: float) -> void:
	var wind := 80.0 if WorldClock.weather == WorldClock.Weather.WIND else 20.0
	if WorldClock.disaster == "storm":
		wind = 120.0
	for p in _particles:
		match String(p.kind):
			"rain":
				p.pos += Vector2(wind * 0.4, p.spd.y) * delta
			"snow":
				p.pos += Vector2(sin(_wind_phase + p.pos.y * 0.01) * 30.0 + wind * 0.2, p.spd.y * 0.35) * delta
			"leaf":
				p.pos += Vector2(wind + sin(_wind_phase + p.pos.x * 0.02) * 40.0, sin(_wind_phase * 2.0) * 20.0) * delta
			"locust":
				p.pos += Vector2(wind * 1.2 + sin(_wind_phase * 3.0 + p.pos.y) * 50.0, cos(_wind_phase * 2.0) * 30.0) * delta
		if p.pos.y > 740 or p.pos.x > 1320 or p.pos.x < -40:
			p.pos = Vector2(randf() * 1280.0, -10.0)

func _draw_fx() -> void:
	var ox := sin(_shake * 40.0) * 3.0 if _shake > 0.0 else 0.0
	for p in _particles:
		var pos: Vector2 = p.pos + Vector2(ox, 0)
		match String(p.kind):
			"rain":
				_fx.draw_line(pos, pos + Vector2(3, 12), Color(0.7, 0.8, 0.9, 0.45), 1.2)
			"snow":
				_fx.draw_circle(pos, p.size, Color(0.95, 0.97, 1.0, 0.7))
			"leaf":
				_fx.draw_circle(pos, p.size * 0.8, Color(0.75, 0.55, 0.25, 0.55))
			"locust":
				_fx.draw_circle(pos, 2.2, Color(0.35, 0.45, 0.2, 0.65))
				_fx.draw_circle(pos + Vector2(3, -1), 1.4, Color(0.4, 0.5, 0.22, 0.5))
