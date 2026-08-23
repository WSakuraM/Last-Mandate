extends Node3D
# 煤山终章：雪夜独白 → 血诏脸谱（Ⅲ类回忆浮现）→ 回忆蒙太奇（8条）→ 渐黑收束。
# 气数触底或预演煤山时进入此场景。ESC 退出，E 跳过单条回忆。

const GOLD := Color(0.95, 0.8, 0.4)
var _ui: CanvasLayer
var _text_label: Label
var _ghost_card: Panel
var _ghost_label: Label
var _skip_requested := false

func _ready():
	_setup_environment()
	_setup_scene()
	_setup_ui()
	_run_sequence()

func _setup_environment():
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.1, 0.16)
	env.ambient_light_color = Color(0.2, 0.25, 0.35)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.12, 0.18)
	env.fog_density = 0.02
	get_viewport().world_3d.environment = env

func _setup_scene():
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

	# 歪脖树
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

	# 绳与套
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

	# 灯笼
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

	# 雪
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

func _setup_ui():
	_ui = CanvasLayer.new()
	add_child(_ui)

	# 独白文字（左上角）
	_text_label = Label.new()
	_text_label.position = Vector2(48, 48)
	_text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	_text_label.add_theme_font_size_override("font_size", 30)
	_ui.add_child(_text_label)

	# 幽灵卡片（居中，用于血诏脸谱 + 回忆蒙太奇）
	_ghost_card = Panel.new()
	_ghost_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_ghost_card.custom_minimum_size = Vector2(620, 130)
	_ghost_card.visible = false
	var ghost_style := StyleBoxFlat.new()
	ghost_style.bg_color = Color(0.05, 0.05, 0.08, 0.72)
	ghost_style.border_color = Color(0.4, 0.35, 0.3, 0.5)
	ghost_style.set_border_width_all(1)
	ghost_style.set_corner_radius_all(4)
	_ghost_card.add_theme_stylebox_override("panel", ghost_style)
	_ui.add_child(_ghost_card)

	_ghost_label = Label.new()
	_ghost_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ghost_label.offset_left = 16
	_ghost_label.offset_right = -16
	_ghost_label.offset_top = 12
	_ghost_label.offset_bottom = -12
	_ghost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ghost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ghost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ghost_label.add_theme_color_override("font_color", Color(0.82, 0.78, 0.7))
	_ghost_label.add_theme_font_size_override("font_size", 18)
	_ghost_card.add_child(_ghost_label)

func _run_sequence():
	# Phase 1：雪夜独白
	_show_monologue("（煤山，夜雪。）")
	await _wait_or_skip(3.0)
	_show_monologue("「诸臣误朕……」")
	await _wait_or_skip(3.0)
	_show_monologue("「勿伤我百姓。」")
	await _wait_or_skip(3.5)
	_clear_monologue()

	# Phase 2：血诏脸谱——Ⅲ类回忆浮现
	var faces: Array = IssueManager.draw_blood_edict_faces(3)
	if faces.size() > 0:
		_show_monologue("——你想起了他们——")
		await _wait_or_skip(2.0)
		_clear_monologue()
		for f in faces:
			_show_ghost(str(f.get("text", "")), str(f.get("pillar", "Ⅲ")))
			await _wait_or_skip(3.0)
			_hide_ghost()

	# Phase 3：回忆蒙太奇——8条回忆按序展现
	var montage: Array = IssueManager.draw_montage(8)
	if montage.size() > 0:
		_show_monologue("——一幕的回忆，终章的回声——")
		await _wait_or_skip(2.0)
		_clear_monologue()
		for m in montage:
			_show_ghost(str(m.get("text", "")), str(m.get("pillar", "Ⅰ")))
			await _wait_or_skip(2.5)
			_hide_ghost()

	# Phase 4：渐黑 + 终幕
	_fade_to_black()

func _show_monologue(text: String):
	_text_label.text = text

func _clear_monologue():
	_text_label.text = ""

func _show_ghost(text: String, pillar: String):
	_ghost_label.text = text
	# 按支柱着色：Ⅲ人民疾苦（暖红）/ Ⅱ朝堂国事（冷灰）/ Ⅰ信王个人（暗金）
	match pillar:
		"Ⅲ":
			_ghost_label.add_theme_color_override("font_color", Color(0.85, 0.6, 0.5))
		"Ⅱ":
			_ghost_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
		_:
			_ghost_label.add_theme_color_override("font_color", Color(0.82, 0.78, 0.6))
	_ghost_card.visible = true

func _hide_ghost():
	_ghost_card.visible = false

func _wait_or_skip(duration: float):
	_skip_requested = false
	var elapsed := 0.0
	while elapsed < duration and not _skip_requested:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

func _fade_to_black():
	var black := ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(black)
	var t := 0.0
	while t < 1.5:
		t += get_process_delta_time() * 0.4
		black.color.a = min(t, 1.0)
		await get_tree().process_frame
	var end := Label.new()
	end.text = "1644 · 崇祯十七年 · 煤山"
	end.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	end.add_theme_font_size_override("font_size", 26)
	end.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_ui.add_child(end)

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	if Input.is_key_pressed(KEY_E):
		_skip_requested = true
