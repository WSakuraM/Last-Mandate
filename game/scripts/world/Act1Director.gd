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
	var well_event: Node = load("res://scripts/world/WellEvent.gd").new()
	add_child(well_event)
	var chengen: Node = load("res://scripts/world/ChengEnNPC.gd").new()
	chengen.position = Vector3(18, 0, -14)
	add_child(chengen)
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
	gmat.albedo_color = Color(0.32, 0.27, 0.22)
	gmat.roughness = 1.0
	ground.material_override = gmat
	add_child(ground)

	# 夯土墙（土褐）+ 瓦顶（赭石暗）
	_wall(Vector3(0, 1, -30), Vector2(60, 1))
	_wall(Vector3(0, 1, 30), Vector2(60, 1))
	_wall(Vector3(-30, 1, 0), Vector2(1, 60))
	_wall(Vector3(30, 1, 0), Vector2(1, 60))

	# 四角弱暖灯（黄昏暗角感）
	for c in [Vector3(-26, 4, -26), Vector3(26, 4, -26), Vector3(-26, 4, 26), Vector3(26, 4, 26)]:
		var lamp := OmniLight3D.new()
		lamp.position = c
		lamp.light_color = Color(1.0, 0.7, 0.35)
		lamp.light_energy = 6.0
		lamp.omni_range = 16.0
		add_child(lamp)

	# 水井：井栏 + 辘轳
	var well := Node3D.new()
	well.name = "Well"
	var wcyl := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.height = 1.6; cyl.top_radius = 1.1; cyl.bottom_radius = 1.1
	wcyl.mesh = cyl
	wcyl.position = Vector3(0, 0.8, 0)
	var wmat := StandardMaterial3D.new()
	wmat.albedo_color = Color(0.38, 0.36, 0.34)
	wmat.roughness = 0.9
	wcyl.material_override = wmat
	well.add_child(wcyl)
	var frame := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(2.6, 0.3, 0.3)
	frame.mesh = fm
	frame.position = Vector3(0, 1.9, 0)
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.3, 0.22, 0.18)
	frame.material_override = fmat
	well.add_child(frame)
	well.position = Vector3(-10, 0, 8)
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
	sun.light_color = Color(1.0, 0.82, 0.55)
	sun.light_energy = 1.15
	add_child(sun)

func _wall(pos: Vector3, size: Vector2):
	# 夯土墙体
	var w := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 2.0, size.y)
	w.mesh = box
	w.position = pos
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.42, 0.37, 0.31)
	m.roughness = 1.0
	w.material_override = m
	add_child(w)
	# 瓦顶（沿墙走向的扁长盒，赭石暗色）
	var roof := MeshInstance3D.new()
	var rb := BoxMesh.new()
	var along := size.x if size.x > size.y else size.y
	var thick := size.x if size.x < size.y else size.y
	rb.size = Vector3(along + 1.0, 0.4, thick + 1.0)
	roof.mesh = rb
	roof.position = Vector3(pos.x, 2.2, pos.z)
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(0.28, 0.2, 0.18)
	rm.roughness = 0.95
	roof.material_override = rm
	add_child(roof)

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
		if IssueManager.night_council_active or _ended:
			return
		ResourceManager.tick_day()
		if _ended:
			return
		# 第一幕收束：信王时期走满跨度，触发入继事件（而非无限循环或被强制拖入煤山）
		if ResourceManager.total_day >= ResourceManager.ACT1_SPAN_DAYS:
			_start_act1_closure()
		elif ResourceManager.day % 7 == 0:
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
	# 真实暖色点光（灯笼照明）
	var lantern_light := OmniLight3D.new()
	lantern_light.position = Vector3(0, 4.2, 3.2)
	lantern_light.light_color = Color(1.0, 0.6, 0.2)
	lantern_light.light_energy = 8.0
	lantern_light.omni_range = 14.0
	hall.add_child(lantern_light)
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

# 第一幕收束：信王入继。锁住世界、压暗、弹出收束画面。
func _start_act1_closure():
	if _ended:
		return
	_ended = true
	IssueManager.night_council_active = true
	if _env:
		_env.ambient_light_energy = 0.15
		_env.background_color = Color(0.06, 0.05, 0.05)
	var closure: Node = load("res://scripts/ui/Act1Closure.gd").new()
	get_tree().root.add_child(closure)
	closure.show_closure()

func _process(delta):
	if _intro_layer and (Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)):
		var l = _intro_layer
		_intro_layer = null
		if is_instance_valid(l):
			l.queue_free()
		IssueManager.night_council_active = false
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
	IssueManager.night_council_active = true   # 开场字幕期间锁住世界输入
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
		IssueManager.night_council_active = false
	)
	add_child(t)
	t.start()
