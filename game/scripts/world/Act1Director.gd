extends Node3D
# 第一幕导演：构建 3D 俯视信王府院落，驱动时间循环、夜召议题与终章跳转。

var _ended := false
var _env: Environment
var _night_council_cd := 0.0
var near_hall := false
var _hall_area: Area3D
var _intro_layer: CanvasLayer
var _purse_tutorial_done := false
var _qiushui_done := false
var _qiushui_event: Node
var _narration_layer: CanvasLayer
# 区块三·支线实例与标志
var _shenliu: Node
var _zhoushi: Node
var _eunuch: Node
var _calamity: Node
var _accession: Node
var _brother: Node
var _shenliu_b1_done := false
var _shenliu_b2_done := false
var _shenliu_b3_done := false
var _zhoushi_done := false
var _eunuch_done := false
var _calamity_done := false
var _brother_b1_done := false
var _brother_b2_done := false
var _brother_b3_done := false
var _atmosphere: Node   # 氛围特效管理器（粒子系统）
var _sun: DirectionalLight3D
var _post: Node
var _last_season := -1
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
	var aen_seed: Node = load("res://scripts/world/AenSeedEvent.gd").new()
	add_child(aen_seed)
	_qiushui_event = load("res://scripts/world/QiuShuiLetterEvent.gd").new()
	add_child(_qiushui_event)
	# 区块三·支线实例
	_shenliu = load("res://scripts/world/ShenLiuStoryline.gd").new()
	add_child(_shenliu)
	_zhoushi = load("res://scripts/world/ZhouShiGarden.gd").new()
	add_child(_zhoushi)
	_eunuch = load("res://scripts/world/EunuchFruitEvent.gd").new()
	add_child(_eunuch)
	_calamity = load("res://scripts/world/CalamityEvent.gd").new()
	add_child(_calamity)
	_accession = load("res://scripts/world/AccessionEvent.gd").new()
	add_child(_accession)
	_brother = load("res://scripts/world/BrotherStoryline.gd").new()
	add_child(_brother)
	var chengen: Node = load("res://scripts/world/ChengEnNPC.gd").new()
	chengen.position = CourtyardLayout.CHENGEN
	add_child(chengen)
	# 氛围特效（粒子系统：灰尘/萤火虫/炊烟/雨雪）
	_atmosphere = load("res://scripts/world/AtmosphereManager.gd").new()
	add_child(_atmosphere)
	_post = load("res://scripts/world/StylizedPostProcess.gd").new()
	add_child(_post)
	add_child(load("res://scripts/world/ZoneSense.gd").new())
	_last_season = ResourceManager.season
	CourtyardVisuals.apply_season(self, _env, _last_season)
	ResourceManager.day_passed.connect(_on_day_passed)
	ResourceManager.game_over.connect(_on_game_over)
	EventBus.narration.connect(_on_narration)
	_show_intro()

func _setup_environment():
	_env = Environment.new()
	CourtyardVisuals.setup_warm_sky(_env)
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color(0.62, 0.58, 0.52)
	_env.ambient_light_energy = 0.62
	_env.fog_enabled = true
	_env.fog_light_color = Color(0.82, 0.86, 0.90)
	_env.fog_density = 0.0022
	_env.tonemap_mode = Environment.TONE_MAPPER_ACES
	_env.tonemap_exposure = 1.12
	_env.tonemap_white = 1.15
	_env.glow_enabled = false
	get_viewport().world_3d.environment = _env

func _build_courtyard():
	CourtyardVisuals.build_ground(self)

	# 夯土墙（土褐）+ 瓦顶；南墙在府门处开口
	_wall(Vector3(0, 1, -30), Vector2(60, 1))
	_wall(Vector3(-18, 1, 30), Vector2(24, 1))
	_wall(Vector3(18, 1, 30), Vector2(24, 1))
	_wall(Vector3(-30, 1, 0), Vector2(1, 60))
	_wall(Vector3(30, 1, 0), Vector2(1, 60))

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-52, 35, 0)
	sun.light_color = Color(1.0, 0.94, 0.82)
	sun.light_energy = 1.32
	sun.shadow_enabled = false
	add_child(sun)
	_sun = sun

	CourtyardProps.build_decorations(self)
	add_child(CourtyardProps.spawn_well(CourtyardLayout.WELL))

	var positions: Array[Vector3] = CourtyardLayout.plot_positions()
	for i: int in positions.size():
		var p: Node = load("res://scripts/world/CourtPlot.gd").new()
		p.plot_id = "plot_%d" % i
		p.position = positions[i]
		add_child(p)

	# 核心占位角色（规范资产，后续可换精模不改代码）
	var wubo: Node3D = preload("res://assets/models/characters/wubo.tscn").instantiate()
	wubo.position = CourtyardLayout.WUBO
	CourtyardProps.setup_character(wubo, 35.0)
	add_child(wubo)
	InteractMark.bind(wubo, "DLG_A1_WUBO_IDLE", 2.05)
	var qiushui: Node3D = preload("res://assets/models/characters/qiushui.tscn").instantiate()
	qiushui.position = CourtyardLayout.QIUSHUI
	CourtyardProps.setup_character(qiushui, -120.0)
	add_child(qiushui)
	InteractMark.bind(qiushui, "DLG_A1_QIUSHUI_IDLE", 1.98)
	var cook: Node3D = CourtyardProps.make_servant(CourtyardLayout.SERVANT_KITCHEN, Color(0.55, 0.42, 0.32), 25.0)
	add_child(cook)
	InteractMark.bind(cook, "DLG_A1_SERVANT_KITCHEN", 1.95)
	var herder: Node3D = CourtyardProps.make_servant(CourtyardLayout.SERVANT_PEN, Color(0.48, 0.44, 0.38), 70.0)
	add_child(herder)
	InteractMark.bind(herder, "DLG_A1_SERVANT_PEN", 1.95)

func _wall(pos: Vector3, size: Vector2):
	var w := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 2.0, size.y)
	w.mesh = box
	w.position = pos
	CourtyardVisuals.apply_toon(w, Color(0.58, 0.48, 0.38))
	w.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(w)
	var roof := MeshInstance3D.new()
	var rb := BoxMesh.new()
	var along := size.x if size.x > size.y else size.y
	var thick := size.x if size.x < size.y else size.y
	rb.size = Vector3(along + 1.0, 0.4, thick + 1.0)
	roof.mesh = rb
	roof.position = Vector3(pos.x, 2.2, pos.z)
	CourtyardVisuals.apply_toon(roof, Color(0.42, 0.34, 0.30), Color(0.28, 0.22, 0.20))
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(roof)

func _spawn_player():
	var player: Node = load("res://scripts/player/Player.gd").new()
	player.position = CourtyardLayout.PLAYER_SPAWN
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
		_roll_weather()
		if _ended:
			return
		# 第一幕收束：信王时期走满跨度，触发入继事件（而非无限循环或被强制拖入煤山）
		if ResourceManager.total_day >= ResourceManager.ACT1_SPAN_DAYS:
			_start_accession_then_closure()
		elif ResourceManager.day % 7 == 0:
			_start_night_council()
		elif not _shenliu_b1_done and ResourceManager.total_day >= 15:
			_start_shenliu_b1()
		elif not _brother_b1_done and ResourceManager.total_day >= 18:
			_start_brother_b1()
		elif not _zhoushi_done and ResourceManager.total_day >= 30:
			_start_zhoushi()
		elif not _shenliu_b2_done and ResourceManager.total_day >= 40:
			_start_shenliu_b2()
		elif not _brother_b2_done and ResourceManager.total_day >= 42:
			_start_brother_b2()
		elif not _qiushui_done and ResourceManager.total_day >= 50 and _qiushui_prereq_met():
			_start_qiushui_letter()
		elif not _eunuch_done and ResourceManager.total_day >= 60:
			_start_eunuch_fruit()
		elif not _calamity_done and ResourceManager.total_day >= 75:
			_start_calamity()
		elif not _brother_b3_done and ResourceManager.total_day >= 98:
			_start_brother_b3()
		elif not _shenliu_b3_done and ResourceManager.total_day >= 105:
			_start_shenliu_b3()
	)
	add_child(t)
	t.start()

# 天气随机：按季节概率切换雨/雪/晴，驱动 AtmosphereManager
func _roll_weather():
	if not _atmosphere:
		return
	# 约每 12 游戏日才掷一次，避免走路时天气/明暗乱跳
	if ResourceManager.total_day % 12 != 0:
		return
	var roll := randf()
	var season: int = ResourceManager.season
	match season:
		0:  # 春：10% 雨
			_atmosphere.set_weather(1 if roll < 0.10 else 0)
		1:  # 夏：30% 雨
			_atmosphere.set_weather(1 if roll < 0.30 else 0)
		2:  # 秋：5% 雨
			_atmosphere.set_weather(1 if roll < 0.05 else 0)
		3:  # 冬：20% 雪
			_atmosphere.set_weather(2 if roll < 0.20 else 0)

func _on_day_passed(_day: int, season: int, _year: int) -> void:
	if season != _last_season:
		_last_season = season
		CourtyardVisuals.apply_season(self, _env, season)
		if _atmosphere:
			_atmosphere.refresh()
		if _post:
			match season:
				0:
					_post.set_tint(Color(0.98, 0.95, 0.88), 0.08)
				1:
					_post.set_tint(Color(1.0, 0.96, 0.82), 0.10)
				2:
					_post.set_tint(Color(0.98, 0.86, 0.70), 0.14)
				3:
					_post.set_tint(Color(0.88, 0.92, 0.98), 0.12)

func _apply_day_light() -> void:
	if _sun == null or _env == null:
		return
	_sun.rotation_degrees = Vector3(-52, 35, 0)
	_sun.light_energy = 1.32
	_sun.light_color = Color(1.0, 0.94, 0.82)
	_env.ambient_light_energy = 0.62
	_env.ambient_light_color = Color(0.66, 0.62, 0.56)

func _setup_night_council_hall():
	var nh := CourtyardLayout.NIGHT_HALL
	var hall := CourtyardProps.make_chinese_building("NightCouncilHall", nh, 8.0, 6.0, 5.0, "夜召堂", 90.0)
	add_child(hall)
	var hall_mark := InteractMark.bind(hall, "", 3.5, false, 2.8)
	hall_mark.activated.connect(_on_hall_clicked)

	var lantern_light := OmniLight3D.new()
	lantern_light.position = Vector3(nh.x - 2.5, 4.5, nh.z)
	lantern_light.light_color = Color(1.0, 0.6, 0.2)
	lantern_light.light_energy = 2.2
	lantern_light.omni_range = 8.0
	lantern_light.shadow_enabled = false
	add_child(lantern_light)

	_hall_area = Area3D.new()
	_hall_area.name = "EnterZone"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(11, 6, 9)
	col.shape = shape
	_hall_area.add_child(col)
	_hall_area.position = Vector3(nh.x, 3, nh.z)
	_hall_area.body_entered.connect(_on_hall_entered)
	_hall_area.body_exited.connect(_on_hall_exited)
	add_child(_hall_area)

func _on_hall_entered(b):
	if b.is_in_group("player"):
		near_hall = true
		EventBus.interact_prompt.emit("点击问号进入夜召堂（召议）")

func _on_hall_exited(b):
	if b.is_in_group("player"):
		near_hall = false
		EventBus.interact_hide.emit()

func _on_hall_clicked() -> void:
	if _night_council_cd > 0.0:
		return
	_start_night_council()

func _start_night_council():
	if IssueManager.night_council_active or _ended:
		return
	var issue = IssueManager.draw_issue(["A1"])
	if issue.is_empty():
		# 区块二：池空时触发日常小事件填充（不占决策，只填时间）
		_start_daily_vignette()
		return
	IssueManager.night_council_active = true
	EventBus.interact_hide.emit()
	# 压暗环境（烛光聚焦前奏）
	if _env:
		_env.ambient_light_energy = 0.22
	if _sun:
		_sun.light_energy = 0.35
	if _post:
		_post.enter_night_mode()
	var panel: Node = load("res://scripts/ui/DecisionPanel.gd").new()
	get_tree().root.add_child(panel)
	panel.choice_made.connect(_on_issue_resolved)
	panel.present(issue)

func _on_issue_resolved(_res):
	IssueManager.night_council_active = false
	if _post:
		_post.enter_day_mode()
	_apply_day_light()
	_night_council_cd = 3.0

func _on_game_over():
	if _ended:
		return
	_ended = true
	get_tree().change_scene_to_file.call_deferred("res://scenes/world/Meishan.tscn")

# M1A5：夜召入继演出 → 收束统计（两段式，先戏后表）
func _start_accession_then_closure() -> void:
	if _ended:
		return
	_ended = true
	IssueManager.night_council_active = true
	if _env:
		_env.ambient_light_energy = 0.28
	if _sun:
		_sun.light_energy = 0.4
	if _post:
		_post.enter_night_mode()
	_accession.accession_finished.connect(_start_act1_closure, CONNECT_ONE_SHOT)
	_accession.trigger()

func _qiushui_prereq_met() -> bool:
	## 主线钉：先完成 M1A3 谷种（或至少首畦播种），再推 M1A4 秋穗，避免「未种先赈」的叙事断裂
	return IssueManager.flags.get("aen_seed_given", false) or IssueManager.flags.get("first_sow_done", false)

# 第一幕收束：入继演出后弹出回忆/资源盘点（ACT1_END 存档）
func _start_act1_closure() -> void:
	IssueManager.night_council_active = true
	if _env:
		_env.ambient_light_energy = 0.12
	if _sun:
		_sun.light_energy = 0.2
	var closure: Node = load("res://scripts/ui/Act1Closure.gd").new()
	get_tree().root.add_child(closure)
	closure.show_closure()

func _process(delta):
	if _intro_layer and (Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)):
		var l = _intro_layer
		_intro_layer = null
		if is_instance_valid(l):
			l.queue_free()
		_start_purse_tutorial()
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
	# _ready 期间父节点正在装配子节点，直接 add 到 root 会失败，需延迟
	get_tree().root.add_child.call_deferred(layer)
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
	t2.text = "大明很大。府门很小。"
	t2.add_theme_font_size_override("font_size", 26)
	t2.add_theme_color_override("font_color", Color(0.88, 0.84, 0.76))
	vb.add_child(t2)

	var t2b := Label.new()
	t2b.text = "天启七年（1627）· 你还只是信王"
	t2b.add_theme_font_size_override("font_size", 20)
	t2b.add_theme_color_override("font_color", Color(0.72, 0.68, 0.62))
	vb.add_child(t2b)

	var t3 := Label.new()
	t3.text = "WASD 点地行走 · 点问号交谈/照料 · 播种后需等数日成熟 · 滚轮拉远 · R 复位"
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
			_start_purse_tutorial()
	)
	add_child(t)
	t.start()

# M1A1：开场字幕后触发吴伯私囊教程（轻交互，锁住世界直到完成）
func _start_purse_tutorial():
	if _purse_tutorial_done:
		IssueManager.night_council_active = false
		return
	_purse_tutorial_done = true
	var tutorial: Node = load("res://scripts/ui/PrivatePurseTutorial.gd").new()
	get_tree().root.add_child(tutorial)
	tutorial.tutorial_completed.connect(_on_purse_tutorial_done)
	tutorial.present()

func _on_purse_tutorial_done(_private_total: float):
	IssueManager.night_council_active = false
	ResourceManager.pay_season_stipend()

# M1A4：中段天灾段（total_day>=50）触发秋穗家书三选
func _start_qiushui_letter():
	if _qiushui_done:
		return
	_qiushui_done = true
	_qiushui_event.trigger()

# 区块三·沈柳鸳鸯线第一幕三拍
func _start_shenliu_b1():
	_shenliu_b1_done = true
	_shenliu.trigger("b1")

func _start_shenliu_b2():
	_shenliu_b2_done = true
	_shenliu.trigger("b2")

func _start_shenliu_b3():
	_shenliu_b3_done = true
	_shenliu.trigger("b3")

# 区块三·周氏园中"人不是折子"回声
func _start_zhoushi():
	_zhoushi_done = true
	_zhoushi.trigger()

# 区块三·中使借果（可选 S2）
func _start_eunuch_fruit():
	_eunuch_done = true
	_eunuch.trigger()

# 区块三·蝗旱涝（可选 S2）
func _start_calamity():
	_calamity_done = true
	_calamity.trigger()

# 兄弟线：朱由检 × 朱由校（天启）三拍
func _start_brother_b1():
	_brother_b1_done = true
	_brother.trigger("b1")

func _start_brother_b2():
	_brother_b2_done = true
	_brother.trigger("b2")

func _start_brother_b3():
	_brother_b3_done = true
	_brother.trigger("b3")

# 区块二：夜召池空时触发日常小事件（街坊寒暄/天气/承恩随口一句）
func _start_daily_vignette():
	var dv: CanvasLayer = load("res://scripts/ui/DailyVignette.gd").new()
	get_tree().root.add_child(dv)
	dv.present()
	dv.dismissed.connect(func():
		_night_council_cd = 3.0
	)

# 区块二：收获旁白浮字（旱象减产/丰收分邻），屏幕底部短暂显示后消失
func _on_narration(text: String):
	if _narration_layer and is_instance_valid(_narration_layer):
		_narration_layer.queue_free()
	_narration_layer = CanvasLayer.new()
	get_tree().root.add_child(_narration_layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_narration_layer.add_child(root)

	var lbl := Label.new()
	lbl.text = text
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	lbl.position = Vector2(0, -60)
	lbl.size = Vector2(680, 40)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.88, 0.82, 0.7))
	root.add_child(lbl)

	var t := Timer.new()
	t.wait_time = 3.5
	t.one_shot = true
	t.timeout.connect(func():
		if is_instance_valid(_narration_layer):
			_narration_layer.queue_free()
			_narration_layer = null
	)
	add_child(t)
	t.start()
