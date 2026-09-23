extends Node3D
# 第一幕导演：构建 3D 俯视信王府院落，驱动时间循环、夜召议题与终章跳转。

var _ended := false
var _env: Environment
var _night_council_cd := 0.0
var _night_council_pending := false
var near_hall := false
var _hall_area: Area3D
var _hall_mark: InteractMark
var _narration_layer: CanvasLayer
var _wubo_mark: InteractMark
var _intro_layer: CanvasLayer
var _intro_ready := false
var _purse_tutorial_done := false
var _qiushui_done := false
var _qiushui_event: Node
var _aen_seed: Node
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
	_aen_seed = aen_seed
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
	_show_opening_hint()

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

	_spawn_corner_lights()

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
	var plot_scenes: Array[String] = [
		"res://assets/models/props/plot_01.tscn",
		"res://assets/models/props/plot_02.tscn",
		"res://assets/models/props/plot_03.tscn",
		"res://assets/models/props/plot_04.tscn",
		"res://assets/models/props/plot_05.tscn",
		"res://assets/models/props/plot_06.tscn",
	]
	for i: int in positions.size():
		var p: Node = load("res://scripts/world/CourtPlot.gd").new()
		p.plot_id = "plot_%d" % i
		p.plot_scene_path = plot_scenes[i % plot_scenes.size()]
		p.position = positions[i]
		add_child(p)

	# 核心占位角色（规范资产，后续可换精模不改代码）
	var wubo: Node3D = preload("res://assets/models/characters/wubo.tscn").instantiate()
	wubo.position = CourtyardLayout.WUBO
	CourtyardProps.setup_character(wubo, 35.0)
	add_child(wubo)
	_wubo_mark = InteractMark.bind(wubo, "", 2.05, false, 0.55, "always", true)
	_wubo_mark.activated.connect(_on_wubo_talk)
	var qiushui: Node3D = preload("res://assets/models/characters/qiushui.tscn").instantiate()
	qiushui.position = CourtyardLayout.QIUSHUI
	CourtyardProps.setup_character(qiushui, -120.0)
	add_child(qiushui)
	InteractMark.bind(qiushui, "DLG_A1_QIUSHUI_IDLE", 1.98, false, 0.55, "near", false)
	var cook: Node3D = CourtyardProps.make_servant(CourtyardLayout.SERVANT_KITCHEN, Color(0.55, 0.42, 0.32), 25.0)
	add_child(cook)
	InteractMark.bind(cook, "DLG_A1_SERVANT_KITCHEN", 1.95, false, 0.55, "near", false)
	var herder: Node3D = CourtyardProps.make_servant(CourtyardLayout.SERVANT_PEN, Color(0.48, 0.44, 0.38), 70.0)
	add_child(herder)
	InteractMark.bind(herder, "DLG_A1_SERVANT_PEN", 1.95, false, 0.55, "near", false)

	var shen_guard: Node3D = CourtyardProps.make_servant(CourtyardLayout.SHEN_GUARD, Color(0.38, 0.42, 0.48), 160.0)
	shen_guard.name = "ShenGuard"
	add_child(shen_guard)
	var liu_zheng: Node3D = CourtyardProps.make_servant(CourtyardLayout.LIU_ZHENG, Color(0.52, 0.38, 0.58), -20.0)
	liu_zheng.name = "LiuZheng"
	add_child(liu_zheng)
	var zhoushi: Node3D = CourtyardProps.make_servant(CourtyardLayout.ZHOU_SHI, Color(0.62, 0.48, 0.52), 110.0)
	zhoushi.name = "ZhouShi"
	add_child(zhoushi)

func _spawn_corner_lights() -> void:
	var lamp_positions: Array[Vector3] = [
		Vector3(-26, 4, -26), Vector3(26, 4, -26),
		Vector3(-26, 4, 26), Vector3(26, 4, 26),
	]
	for lp: Vector3 in lamp_positions:
		var omni := OmniLight3D.new()
		omni.position = lp
		omni.light_color = Color(1.0, 0.72, 0.38)
		omni.light_energy = 0.85
		omni.omni_range = 14.0
		omni.shadow_enabled = false
		add_child(omni)

func _wall(pos: Vector3, size: Vector2):
	var along := size.x if size.x > size.y else size.y
	var thick := size.x if size.x < size.y else size.y
	var wall_h := 2.0

	var body := StaticBody3D.new()
	body.name = "WallBody"
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = pos
	var col := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(size.x, wall_h, size.y)
	col.shape = box_shape
	col.position.y = wall_h * 0.5
	body.add_child(col)
	add_child(body)

	var w := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, wall_h, size.y)
	w.mesh = box
	w.position.y = wall_h * 0.5
	CourtyardVisuals.apply_toon(w, Color(0.58, 0.48, 0.38))
	w.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	body.add_child(w)

	var roof := MeshInstance3D.new()
	var prism := PrismMesh.new()
	if size.x > size.y:
		prism.size = Vector3(along + 1.0, 0.55, thick + 0.6)
		roof.rotation_degrees = Vector3(0, 0, 90)
	else:
		prism.size = Vector3(thick + 0.6, 0.55, along + 1.0)
	roof.mesh = prism
	roof.position = Vector3(0, wall_h + 0.22, 0)
	CourtyardVisuals.apply_toon(roof, Color(0.42, 0.34, 0.30), Color(0.28, 0.22, 0.20))
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	body.add_child(roof)

func _spawn_player():
	var player: Node = load("res://scripts/player/Player.gd").new()
	player.position = CourtyardLayout.PLAYER_SPAWN
	# 面朝正堂（-Z），从府门望进院子
	player.rotation.y = 0.0
	player.add_to_group("player")
	add_child(player)

func _spawn_camera():
	var rig: Node = load("res://scripts/camera/TopDownCamera.gd").new()
	add_child(rig)

func _setup_day_cycle():
	var t := Timer.new()
	t.wait_time = 6.0
	t.timeout.connect(_on_day_tick)
	add_child(t)
	t.start()

func _on_day_tick() -> void:
	if IssueManager.night_council_active or _ended:
		return
	ResourceManager.tick_day()
	_roll_weather()
	if _ended:
		return
	if ResourceManager.total_day >= ResourceManager.ACT1_SPAN_DAYS:
		_start_accession_then_closure()
		return
	if _try_story_beat():
		return
	if ResourceManager.day % 7 == 0:
		_night_council_pending = true
		if _hall_mark:
			_hall_mark.set_active(true)
		EventBus.narration.emit("今夜有召——请赴夜召堂。")
		EventBus.objective_changed.emit("目标：夜召堂 · 点 ? 入堂听议")

## 固定日期的主线/支线优先于周夜召（避免 day42/98/105 等被 day%7==0 抢走）。
func _try_story_beat() -> bool:
	if not _shenliu_b1_done and ResourceManager.total_day >= 15:
		_start_shenliu_b1()
		return true
	if not _brother_b1_done and ResourceManager.total_day >= 18:
		_start_brother_b1()
		return true
	if not _zhoushi_done and ResourceManager.total_day >= 30:
		_start_zhoushi()
		return true
	if not _shenliu_b2_done and ResourceManager.total_day >= 40:
		_start_shenliu_b2()
		return true
	if not _brother_b2_done and ResourceManager.total_day >= 42:
		_start_brother_b2()
		return true
	if ResourceManager.total_day >= 45 and _aen_seed and _aen_seed.has_method("try_failsafe"):
		if _aen_seed.try_failsafe():
			return true
	if not _qiushui_done and ResourceManager.total_day >= 50 and _qiushui_prereq_met():
		_start_qiushui_letter()
		return true
	if not _eunuch_done and ResourceManager.total_day >= 60:
		_start_eunuch_fruit()
		return true
	if not _calamity_done and ResourceManager.total_day >= 75:
		_start_calamity()
		return true
	if not _brother_b3_done and ResourceManager.total_day >= 98:
		_start_brother_b3()
		return true
	if not _shenliu_b3_done and ResourceManager.total_day >= 105:
		_start_shenliu_b3()
		return true
	return false

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
	_hall_mark = InteractMark.bind(hall, "", 3.5, false, 2.8, "when_active", true)
	_hall_mark.activated.connect(_on_hall_clicked)
	_hall_mark.set_active(false)

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
		if _night_council_pending:
			EventBus.interact_prompt.emit("今夜有召 · 点击问号入夜召堂")
		else:
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
	_night_council_pending = false
	if _hall_mark:
		_hall_mark.set_active(false)
	EventBus.objective_changed.emit("")
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
	if _intro_layer:
		if _intro_ready and (Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)):
			_dismiss_opening_brief()
		return
	if IssueManager.night_council_active:
		return
	if _night_council_cd > 0.0:
		_night_council_cd = max(0.0, _night_council_cd - delta)
	elif near_hall and Input.is_key_pressed(KEY_E):
		_start_night_council()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M and not _ended and not IssueManager.night_council_active:
			_ended = true
			get_tree().change_scene_to_file.call_deferred("res://scenes/world/Meishan.tscn")
			get_viewport().set_input_as_handled()
			return
		# M1 测试调试：对话/议题进行中不可跳日
		if IssueManager.night_council_active or _ended:
			return
		if event.keycode == KEY_F8:
			var n := 7 if event.shift_pressed else 1
			_debug_skip_days(n)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F9:
			_debug_skip_to_next_story()
			get_viewport().set_input_as_handled()

## 测试用：跳过 n 个游戏日（遇剧情/夜召提示即停，避免一口气打穿）
func _debug_skip_days(n: int) -> void:
	for _i in n:
		if _ended or IssueManager.night_council_active:
			break
		_on_day_tick()
		if IssueManager.night_council_active or _night_council_pending:
			EventBus.narration.emit("【测试】已跳至第 %d 日 · 请处理当前事件" % ResourceManager.total_day)
			break
	EventBus.narration.emit("【测试】总日 %d · 季内第 %d 日" % [ResourceManager.total_day, ResourceManager.day])

## 测试用：跳到下一剧情日（15/18/30/40/42/50/60/75/98/105/150）
func _debug_skip_to_next_story() -> void:
	var beats: Array[int] = [15, 18, 30, 40, 42, 45, 50, 60, 75, 98, 105, 150]
	var cur: int = ResourceManager.total_day
	var target := -1
	for d in beats:
		if d > cur:
			target = d
			break
	if target < 0:
		EventBus.narration.emit("【测试】已无后续剧情日")
		return
	while ResourceManager.total_day < target and not _ended and not IssueManager.night_council_active:
		_on_day_tick()
		if IssueManager.night_council_active:
			break
	EventBus.narration.emit("【测试】跳至总日 %d（目标 %d）" % [ResourceManager.total_day, target])

func _show_opening_hint() -> void:
	call_deferred("_show_opening_brief")

func _show_opening_brief() -> void:
	IssueManager.night_council_active = true
	_intro_ready = false
	var layer := CanvasLayer.new()
	layer.layer = 30
	get_tree().root.add_child(layer)
	_intro_layer = layer

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	var dim := ColorRect.new()
	dim.color = Act1Theme.NIGHT_DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_top = 0.5
	card.anchor_right = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -290
	card.offset_right = 290
	card.offset_top = -200
	card.offset_bottom = 200
	card.add_theme_stylebox_override("panel", Act1Theme.night_card())
	root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	card.add_child(vb)

	var t1 := Label.new()
	t1.text = "第一幕 · 信王府"
	Act1Theme.apply_label(t1, 24, Act1Theme.VERMILLION)
	vb.add_child(t1)

	var t2 := Label.new()
	t2.text = "天启七年春。你刚踏进府门——大明很大，这院子很小。"
	t2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Act1Theme.apply_label(t2, Act1Theme.FONT_BODY, Act1Theme.INK)
	vb.add_child(t2)

	vb.add_child(Act1Theme.separator())

	var goal := Label.new()
	goal.text = "今日要事\n去西侧灶房，找吴伯（头顶 ?）。\n他把几笔银子摊开，请你分清：哪些入私囊，哪些归官银。"
	goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Act1Theme.apply_label(goal, Act1Theme.FONT_BODY, Act1Theme.INK_MUTED)
	vb.add_child(goal)

	var tips := Label.new()
	tips.text = "WASD / 点地走动 · 点人物或菜畦头顶 ? 交互 · ←/→ 转视角"
	tips.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Act1Theme.apply_label(tips, Act1Theme.FONT_SMALL, Act1Theme.INK_FAINT)
	vb.add_child(tips)

	var hint := Label.new()
	hint.text = "按 E 或 空格 起身"
	Act1Theme.apply_label(hint, Act1Theme.FONT_HINT, Act1Theme.BRONZE)
	vb.add_child(hint)

	# 短延迟后再接受按键，避免进场景瞬间误触关掉
	var t := get_tree().create_timer(0.45)
	t.timeout.connect(func(): _intro_ready = true)

func _dismiss_opening_brief() -> void:
	if _intro_layer and is_instance_valid(_intro_layer):
		_intro_layer.queue_free()
	_intro_layer = null
	_intro_ready = false
	IssueManager.night_council_active = false
	if not _purse_tutorial_done:
		EventBus.objective_changed.emit("目标：西侧灶房 · 找吴伯（?）分清私囊与官银")
	EventBus.narration.emit("吴伯在西厢灶房廊下等你。")

func _on_wubo_talk() -> void:
	if not _purse_tutorial_done:
		_start_purse_tutorial()
	else:
		EventBus.dialogue_request.emit("DLG_A1_WUBO_IDLE")

# M1A1：点击吴伯后触发私囊教程（轻交互，锁住世界直到完成）
func _start_purse_tutorial():
	if _purse_tutorial_done:
		IssueManager.night_council_active = false
		return
	_purse_tutorial_done = true
	EventBus.objective_changed.emit("")
	if _wubo_mark:
		_wubo_mark.set_important(false)
		_wubo_mark.set_show_mode("near")
	var tutorial: Node = load("res://scripts/ui/PrivatePurseTutorial.gd").new()
	get_tree().root.add_child(tutorial)
	tutorial.tutorial_completed.connect(_on_purse_tutorial_done)
	tutorial.present()

func _on_purse_tutorial_done(_private_total: float):
	IssueManager.night_council_active = false
	ResourceManager.pay_season_stipend()
	EventBus.objective_changed.emit("目标：中院菜圃 · 走近菜畦按 E 开垦播种")
	# 种过一畦后目标条再淡出，由首次播种钩子清
	if not EventBus.first_sow.is_connected(_on_first_sow_objective):
		EventBus.first_sow.connect(_on_first_sow_objective, CONNECT_ONE_SHOT)

func _on_first_sow_objective() -> void:
	EventBus.objective_changed.emit("")
	EventBus.narration.emit("种下了。日子还会很长——留意夜召堂前的 ?。")

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
	_narration_layer.layer = 18
	get_tree().root.add_child(_narration_layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_narration_layer.add_child(root)

	var wrap := PanelContainer.new()
	wrap.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	wrap.anchor_left = 0.5
	wrap.anchor_top = 1.0
	wrap.anchor_right = 0.5
	wrap.anchor_bottom = 1.0
	wrap.offset_left = -320
	wrap.offset_right = 320
	wrap.offset_top = -108
	wrap.offset_bottom = -52
	wrap.add_theme_stylebox_override("panel", Act1Theme.slim_panel(0.92))
	wrap.modulate.a = 0.0
	root.add_child(wrap)

	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Act1Theme.apply_label(lbl, Act1Theme.FONT_BODY, Act1Theme.INK_MUTED)
	wrap.add_child(lbl)

	var tween := create_tween()
	tween.tween_property(wrap, "modulate:a", 1.0, 0.35)
	tween.tween_interval(2.8)
	tween.tween_property(wrap, "modulate:a", 0.0, 0.45)
	tween.tween_callback(func():
		if is_instance_valid(_narration_layer):
			_narration_layer.queue_free()
			_narration_layer = null
	)
