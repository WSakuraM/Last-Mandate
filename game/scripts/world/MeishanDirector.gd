extends Node3D
# 煤山终章：第一人称雪夜，树/绳/灯/雪 + 独白 + 渐黑收束。

func _ready():
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.1, 0.16)
	env.ambient_light_color = Color(0.2, 0.25, 0.35)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.12, 0.18)
	env.fog_density = 0.02
	get_viewport().world_3d.environment = env

	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(80, 80)
	ground.mesh = pm
	ground.rotate_x(-PI / 2.0)
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.8, 0.82, 0.85)
	gm.roughness = 1.0
	ground.material_override = gm
	add_child(ground)

	var trunk := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.height = 8.0; tm.top_radius = 0.4; tm.bottom_radius = 0.6
	trunk.mesh = tm
	trunk.position = Vector3(0, 4, -3)
	add_child(trunk)
	var branch := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.height = 4.0; bm.top_radius = 0.15; bm.bottom_radius = 0.2
	branch.mesh = bm
	branch.position = Vector3(0, 7.5, -3)
	branch.rotation.z = PI / 2.2
	add_child(branch)

	var rope := MeshInstance3D.new()
	var rm := CylinderMesh.new()
	rm.height = 2.5; rm.top_radius = 0.04; rm.bottom_radius = 0.04
	rope.mesh = rm
	rope.position = Vector3(0, 9, -3)
	add_child(rope)
	var noose := MeshInstance3D.new()
	var nm := TorusMesh.new()
	nm.inner_radius = 0.25; nm.outer_radius = 0.35
	noose.mesh = nm
	noose.position = Vector3(0, 7.8, -3)
	noose.rotation.x = PI / 2.0
	add_child(noose)

	var lantern := MeshInstance3D.new()
	var lm2 := SphereMesh.new()
	lm2.radius = 0.3
	lantern.mesh = lm2
	lantern.position = Vector3(2, 0.5, 2)
	var lmat := StandardMaterial3D.new()
	lmat.emission_enabled = true
	lmat.emission = Color(1.0, 0.6, 0.2)
	lmat.emission_energy = 3.0
	lantern.material_override = lmat
	add_child(lantern)
	var ll := OmniLight3D.new()
	ll.position = Vector3(2, 0.8, 2)
	ll.light_color = Color(1.0, 0.6, 0.3)
	ll.light_energy = 4.0
	add_child(ll)

	var snow := GPUParticles3D.new()
	var pmat := ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(40, 20, 40)
	pmat.direction = Vector3(0, -1, 0)
	pmat.gravity = Vector3(0, -1, 0)
	pmat.initial_velocity_min = 1.0
	pmat.initial_velocity_max = 3.0
	pmat.color = Color(1, 1, 1, 0.85)
	snow.process_material = pmat
	snow.amount = 400
	snow.emitting = true
	add_child(snow)

	var ui := CanvasLayer.new()
	add_child(ui)
	var lab := Label.new()
	lab.text = "（煤山，夜雪。）\n\n「诸臣误朕……」\n「勿伤我百姓。」"
	lab.position = Vector2(48, 48)
	lab.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	lab.add_theme_font_size_override("font_size", 30)
	ui.add_child(lab)

	var t := Timer.new()
	t.wait_time = 12.0
	t.one_shot = true
	t.timeout.connect(_fade.bind(ui))
	add_child(t)
	t.start()

func _fade(ui: CanvasLayer):
	var black := ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(black)
	var t := 0.0
	while t < 1.0:
		t += get_process_delta_time() * 0.3
		black.color.a = min(t, 1.0)
		await get_tree().process_frame
	var end := Label.new()
	end.text = "1644 · 崇祯十七年 · 煤山"
	end.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	end.add_theme_font_size_override("font_size", 26)
	end.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	ui.add_child(end)

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
