extends Node3D
# 第一幕导演：构建 3D 俯视信王府院落，并驱动时间循环与终章跳转。

var _ended := false

func _ready():
	_setup_environment()
	_build_courtyard()
	_spawn_player()
	_spawn_camera()
	_setup_day_cycle()
	ResourceManager.game_over.connect(_on_game_over)

func _setup_environment():
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.5, 0.45)
	env.ambient_light_color = Color(0.5, 0.45, 0.4)
	env.ambient_light_energy = 0.8
	env.fog_enabled = true
	env.fog_color = Color(0.5, 0.46, 0.42)
	env.fog_density = 0.012
	get_viewport().world_environment = env

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
		var p := load("res://scripts/world/CourtPlot.gd").new()
		p.plot_id = "plot_%d" % i
		p.position = positions[i]
		add_child(p)

	var sun := DirectionalLight3D.new()
	sun.position = Vector3(10, 30, 10)
	sun.rotation = Vector3(-1.0, 0, -0.6)
	sun.light_color = Color(1.0, 0.85, 0.6)
	sun.light_energy = 1.2
	add_child(sun)
	var amb := AmbientLight3D.new()
	amb.light_energy = 0.4
	add_child(amb)

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
	var player := load("res://scripts/player/Player.gd").new()
	player.position = Vector3(0, 1, 0)
	player.add_to_group("player")
	add_child(player)

func _spawn_camera():
	var rig := load("res://scripts/camera/TopDownCamera.gd").new()
	add_child(rig)

func _setup_day_cycle():
	var t := Timer.new()
	t.wait_time = 6.0
	t.timeout.connect(func(): ResourceManager.tick_day())
	add_child(t)
	t.start()

func _on_game_over():
	if _ended:
		return
	_ended = true
	get_tree().change_scene_to_file.call_deferred("res://scenes/world/Meishan.tscn")

func _process(_delta):
	if Input.is_key_pressed(KEY_M) and not _ended:
		_ended = true
		get_tree().change_scene_to_file.call_deferred("res://scenes/world/Meishan.tscn")
