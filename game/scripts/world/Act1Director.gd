extends Node3D
# 第一幕导演：构建 3D 俯视信王府院落，驱动时间循环、夜召议题与终章跳转。

var _ended := false
var _env: Environment
var _night_council_cd := 0.0
var near_hall := false
var _hall_area: Area3D
var _intro_layer: CanvasLayer
const GOLD := Color(0.95, 0.8, 0.4)

func _ready():
	_setup_environment()
	_build_courtyard()
	_spawn_player()
	_spawn_camera()
	_setup_day_cycle()
	_setup_night_council_hall()
	var vignette: Node = load("res://scripts/world/RefugeeVignette.gd").new()
	add_child(vignette)
	ResourceManager.game_over.connect(_on_game_over)
	_show_intro()

func _setup_environment():
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	_env.background_color = Color(0.55, 0.5, 0.45)
	_env.ambient_light_color = Color(0.5, 0.45, 0.4)
	_env.ambient_light_energy = 0.8
	_env.fog_enabled = true
	_env.fog_light_color = Color(0.5, 0.46, 0.42)
	_env.fog_density = 0.012
	get_viewport().world_3d.environment = _env

func _build_courtyard():
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	ground.mesh = plane
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(0.35, 0.3, 0.25)
	gmat.roughness = 1.0
	ground.material_override = gmat
	add_child(ground)

	_wall(Vector3(0, 1, -30), Vector2(60, 1))
	_wall(Vector3(0, 1, 30), Vector2(60, 1))
	_wall(Vector3(-30, 1, 0), Vector2(1, 60))
	_wall(Vector3(30, 1, 0), Vector2(1, 60))

	var well := MeshInstance3D.new()
	var wcyl := CylinderMesh.new()
	wcyl.height = 2.0; wcyl.top_radius = 1.0; wcyl.bottom_radius = 1.0
	well.mesh = wcyl
	well.position = Vector3(-10, 1, 8)
	var wmat := StandardMaterial3D.new()
	wmat.albedo_color = Color(0.4, 0.4, 0.42)
	well.material_override = wmat
	add_child(well)

	var positions := [Vector3(-8, 0, -8), Vector3(0, 0, -8), Vector3(8, 0, -8),
	                  Vector3(-8, 0, 4), Vector3(0, 0, 4), Vector3(8, 0, 4)]
	for i in positions.size():
		var p: Node = load("res://scripts/world/CourtPlot.gd").new()
		p.plot_id = "plot_%d" % i
		p.position = positions[i]
		add_child(p)

	var sun := DirectionalLight3D.new()
	sun.position = Vector3(10, 30, 10)
	sun.rotation = Vector3(-1.0, 0, -0.6)
	sun.light_color = Color(1.0, 0.85, 0.6)
	sun.light_energy = 1.2
	add_child(sun)

func _wall(pos: Vector3, size: Vector2):
	var w := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 2.0, size.y)
	w.mesh = box
	w.position = pos
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.45, 0.4, 0.35)
	w.material_override = m
	add_child(w)

func _spawn_player():
	var player: Node = load("res://scripts/player/Player.gd").new()
	player.position = Vector3(0, 1, 0)
	player.add_to_group("player")
	add_child(player)

func _spawn_camera():
	var rig: Node = load("res://scripts/camera/TopDownCamera.gd").new()
	add_child(rig)

func _setup_day_cycle():
	var t := Timer.new()
	t.wait_time = 6.0
	t.timeout.connect(func():
		if IssueManager.night_council_active:
			return
		ResourceManager.tick_day()
		if ResourceManager.day % 7 == 0:
			_start_night_council()
	)
	add_child(t)
	t.start()

func _setup_night_council_hall():
	# 夜召堂：简易低模屋 + 进入触发区
	var hall := Node3D.new()
	hall.name = "NightCouncilHall"
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(8, 5, 6)
	body.mesh = bm
	var bmat := StandardMaterial3D.new()
	bmat.albedo_color = Color(0.4, 0.32, 0.28)
	body.material_override = bmat
	body.position.y = 2.5
	hall.add_child(body)
	var roof := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(9.4, 0.6, 7.4)
	roof.mesh = rm
	var rmat := StandardMaterial3D.new()
	rmat.albedo_color = Color(0.3, 0.22, 0.2)
	roof.material_override = rmat
	roof.position.y = 5.3
	hall.add_child(roof)
	var lantern := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.3
	lantern.mesh = lm
	lantern.position = Vector3(0, 4.2, 3.2)
	var lmat := StandardMaterial3D.new()
	lmat.emission_enabled = true
	lmat.emission = Color(1.0, 0.6, 0.2)
	lmat.emission_energy = 2.0
	lantern.material_override = lmat
	hall.add_child(lantern)
	hall.position = Vector3(18, 0, -18)
	add_child(hall)

	_hall_area = Area3D.new()
	_hall_area.name = "EnterZone"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(11, 6, 9)
	col.shape = shape
	_hall_area.add_child(col)
	_hall_area.position = Vector3(18, 3, -18)
	_hall_area.body_entered.connect(_on_hall_entered)
	_hall_area.body_exited.connect(_on_hall_exited)
	add_child(_hall_area)

func _on_hall_entered(b):
	if b.is_in_group("player"):
		near_hall = true
		EventBus.interact_prompt.emit("进入夜召堂（按 E 召议）")

func _on_hall_exited(b):
	if b.is_in_group("player"):
		near_hall = false
		EventBus.interact_hide.emit()

func _start_night_council():
	if IssueManager.night_council_active or _ended:
		return
	var issue = IssueManager.draw_issue(["A1"])
	if issue.is_empty():
		return
	IssueManager.night_council_active = true
	EventBus.interact_hide.emit()
	# 压暗环境（烛光聚焦前奏）
	if _env:
		_env.ambient_light_energy = 0.22
		_env.background_color = Color(0.1, 0.09, 0.08)
	var panel: Node = load("res://scripts/ui/DecisionPanel.gd").new()
	get_tree().root.add_child(panel)
	panel.choice_made.connect(_on_issue_resolved)
	panel.present(issue)

func _on_issue_resolved(_res):
	IssueManager.night_council_active = false
	if _env:
		_env.ambient_light_energy = 0.8
		_env.background_color = Color(0.55, 0.5, 0.45)
	_night_council_cd = 3.0

func _on_game_over():
	if _ended:
		return
	_ended = true
	get_tree().change_scene_to_file.call_deferred("res://scenes/world/Meishan.tscn")

func _process(delta):
	if _intro_layer and (Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)):
		var l = _intro_layer
		_intro_layer = null
		if is_instance_valid(l):
			l.queue_free()
	if IssueManager.night_council_active:
		return
	if _night_council_cd > 0.0:
		_night_council_cd = max(0.0, _night_council_cd - delta)
	elif near_hall and Input.is_key_pressed(KEY_E):
		_start_night_council()
	if Input.is_key_pressed(KEY_M) and not _ended:
		_ended = true
		get_tree().change_scene_to_file.call_deferred("res://scenes/world/Meishan.tscn")

func _show_intro():
	var layer := CanvasLayer.new()
	add_child(layer)
	_intro_layer = layer
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vb.add_theme_constant_override("separation", 14)
	root.add_child(vb)

	var t1 := Label.new()
	t1.text = "第一幕 · 信王府"
	t1.add_theme_font_size_override("font_size", 40)
	t1.add_theme_color_override("font_color", GOLD)
	vb.add_child(t1)

	var t2 := Label.new()
	t2.text = "天启七年（1627）· 你还只是信王"
	t2.add_theme_font_size_override("font_size", 22)
	t2.add_theme_color_override("font_color", Color(0.8, 0.77, 0.72))
	vb.add_child(t2)

	var t3 := Label.new()
	t3.text = "WASD 行走 · 靠近菜圃按 E 照料 · 入夜召堂听议 · 按 M 预演终章"
	t3.add_theme_font_size_override("font_size", 16)
	t3.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(t3)

	var t := Timer.new()
	t.wait_time = 6.0
	t.one_shot = true
	t.timeout.connect(func():
		if is_instance_valid(_intro_layer):
			_intro_layer.queue_free()
			_intro_layer = null
	)
	add_child(t)
	t.start()
