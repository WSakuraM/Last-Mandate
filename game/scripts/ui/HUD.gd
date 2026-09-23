extends CanvasLayer
# 3D 俯视 HUD：顶栏克制 + 右上日期 + 纸色分区匾额

var bars := {}
var bar_values := {}
var bar_fills := {}
var mandate_bar: ProgressBar
var mandate_value: Label
var mandate_fill: StyleBoxFlat
var mandate_warning: Label
var date_label: Label
var footer_label: Label
var prompt_label: Label
var objective_label: Label
var objective_wrap: PanelContainer
var zone_wrap: PanelContainer
var zone_label: Label
var _zone_t := 0.0
var _objective_text := ""
var _prompt_text := ""

func _ready():
	layer = 20
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# 左上：资源细条
	var res_panel := PanelContainer.new()
	res_panel.position = Vector2(12, 10)
	res_panel.custom_minimum_size = Vector2(248, 0)
	res_panel.add_theme_stylebox_override("panel", Act1Theme.paper_panel(0.91, 3))
	root.add_child(res_panel)

	var res_vb := VBoxContainer.new()
	res_vb.add_theme_constant_override("separation", 3)
	res_panel.add_child(res_vb)

	var names := {
		"treasury": "库", "people": "民", "border_army": "边",
		"court_order": "朝", "emperor_heart": "心",
	}
	for key in names.keys():
		res_vb.add_child(_make_resource_row(String(names[key]), key))

	res_vb.add_child(Act1Theme.separator())

	var mandate_row := HBoxContainer.new()
	mandate_row.add_theme_constant_override("separation", 6)
	var mandate_name := Label.new()
	mandate_name.text = "天命"
	mandate_name.custom_minimum_size = Vector2(28, 0)
	Act1Theme.apply_label(mandate_name, Act1Theme.FONT_HUD_LABEL, Act1Theme.VERMILLION_SOFT)
	mandate_row.add_child(mandate_name)
	mandate_bar = ProgressBar.new()
	mandate_bar.max_value = 100.0
	mandate_bar.value = 12.0
	mandate_bar.custom_minimum_size = Vector2(168, 6)
	mandate_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mandate_bar.show_percentage = false
	mandate_fill = Act1Theme.bar_fill(Act1Theme.mandate_fill(12.0))
	mandate_bar.add_theme_stylebox_override("fill", mandate_fill)
	mandate_bar.add_theme_stylebox_override("background", Act1Theme.bar_background())
	mandate_row.add_child(mandate_bar)
	mandate_value = Label.new()
	mandate_value.custom_minimum_size = Vector2(28, 0)
	mandate_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	Act1Theme.apply_label(mandate_value, Act1Theme.FONT_HUD_VALUE, Act1Theme.VERMILLION)
	mandate_row.add_child(mandate_value)
	res_vb.add_child(mandate_row)

	mandate_warning = Label.new()
	mandate_warning.text = ""
	Act1Theme.apply_label(mandate_warning, Act1Theme.FONT_TINY, Act1Theme.VERMILLION)
	res_vb.add_child(mandate_warning)

	footer_label = Label.new()
	footer_label.text = "回忆 ×0 · 菜圃 —"
	Act1Theme.apply_label(footer_label, Act1Theme.FONT_TINY, Act1Theme.INK_FAINT)
	res_vb.add_child(footer_label)

	# 右上：日期
	var date_panel := PanelContainer.new()
	date_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	date_panel.offset_left = -168
	date_panel.offset_top = 10
	date_panel.offset_right = -12
	date_panel.offset_bottom = 42
	date_panel.add_theme_stylebox_override("panel", Act1Theme.slim_panel(0.88))
	root.add_child(date_panel)
	date_label = Label.new()
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	Act1Theme.apply_label(date_label, Act1Theme.FONT_SMALL, Act1Theme.INK_MUTED)
	date_panel.add_child(date_label)

	# 常驻目标条（开场引导 / 主线提示）
	objective_wrap = PanelContainer.new()
	objective_wrap.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	objective_wrap.offset_left = -300
	objective_wrap.offset_right = 300
	objective_wrap.offset_top = -108
	objective_wrap.offset_bottom = -72
	objective_wrap.add_theme_stylebox_override("panel", Act1Theme.slim_panel(0.92))
	root.add_child(objective_wrap)
	objective_label = Label.new()
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Act1Theme.apply_label(objective_label, Act1Theme.FONT_SMALL, Act1Theme.VERMILLION)
	objective_wrap.add_child(objective_label)
	objective_wrap.visible = false

	# 底部交互提示
	var prompt_wrap := PanelContainer.new()
	prompt_wrap.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_wrap.offset_left = -280
	prompt_wrap.offset_right = 280
	prompt_wrap.offset_top = -64
	prompt_wrap.offset_bottom = -20
	prompt_wrap.add_theme_stylebox_override("panel", Act1Theme.slim_panel(0.90))
	root.add_child(prompt_wrap)
	prompt_label = Label.new()
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Act1Theme.apply_label(prompt_label, Act1Theme.FONT_SMALL, Act1Theme.INK_MUTED)
	prompt_wrap.add_child(prompt_label)
	prompt_wrap.visible = false
	prompt_label.set_meta("wrap", prompt_wrap)
	# 顶中：分区匾额
	zone_wrap = PanelContainer.new()
	zone_wrap.set_anchors_preset(Control.PRESET_CENTER_TOP)
	zone_wrap.offset_left = -88
	zone_wrap.offset_right = 88
	zone_wrap.offset_top = 14
	zone_wrap.offset_bottom = 46
	zone_wrap.add_theme_stylebox_override("panel", Act1Theme.slim_panel(0.85))
	zone_wrap.modulate.a = 0.0
	root.add_child(zone_wrap)
	zone_label = Label.new()
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Act1Theme.apply_label(zone_label, Act1Theme.FONT_BODY, Act1Theme.INK)
	zone_wrap.add_child(zone_label)

	ResourceManager.resources_changed.connect(_on_res)
	ResourceManager.mandate_changed.connect(_on_man)
	EventBus.interact_prompt.connect(_on_prompt)
	EventBus.interact_hide.connect(_on_hide)
	EventBus.objective_changed.connect(_on_objective)
	IssueManager.memory_added.connect(_on_memory)
	EventBus.zone_entered.connect(_on_zone)
	EventBus.farm_status.connect(_on_farm)
	call_deferred("_refresh_hud")

func _make_resource_row(display_name: String, key: String) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 5)
	var lab := Label.new()
	lab.text = display_name
	lab.custom_minimum_size = Vector2(20, 0)
	Act1Theme.apply_label(lab, Act1Theme.FONT_HUD_LABEL, Act1Theme.INK_MUTED)
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = 50.0
	bar.custom_minimum_size = Vector2(168, 5)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	var fill := Act1Theme.bar_fill(Act1Theme.resource_fill(50.0))
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", Act1Theme.bar_background())
	var val := Label.new()
	val.custom_minimum_size = Vector2(28, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	Act1Theme.apply_label(val, Act1Theme.FONT_HUD_VALUE, Act1Theme.INK)
	hb.add_child(lab)
	hb.add_child(bar)
	hb.add_child(val)
	bars[key] = bar
	bar_values[key] = val
	bar_fills[key] = fill
	return hb

func _refresh_hud() -> void:
	_on_res(ResourceManager.get_state())
	_on_man(ResourceManager.mandate_decay)
	_on_memory("", 0)
	CourtPlot.broadcast_farm_status()

func _process(delta: float) -> void:
	if _zone_t > 0.0:
		_zone_t = maxf(0.0, _zone_t - delta)
		if _zone_t > 0.45:
			zone_wrap.modulate.a = 1.0
		else:
			zone_wrap.modulate.a = _zone_t / 0.45

func _on_res(s: Dictionary):
	for k in bars:
		var v: float = float(s[k])
		bars[k].value = v
		bar_values[k].text = str(int(round(v)))
		bar_fills[k].bg_color = Act1Theme.resource_fill(v)
	var seasons: Array = ["春", "夏", "秋", "冬"]
	var si: int = int(s.season)
	var season_name: String = String(seasons[si]) if si >= 0 and si < 4 else "?"
	var purse_line := ""
	if float(s.get("private_purse", 0.0)) > 0.01:
		purse_line = "\n私囊 %.0f 兩" % float(s.private_purse)
	var total: int = int(s.get("total_day", 0))
	var span: int = ResourceManager.ACT1_SPAN_DAYS
	date_label.text = "%s · 第 %d 日\n%d/%d · %d年%s" % [
		season_name, int(s.day), total, span, int(s.year), purse_line]
	var season_ink: Array[Color] = [
		Color(0.38, 0.52, 0.30),
		Color(0.62, 0.48, 0.22),
		Color(0.68, 0.42, 0.20),
		Color(0.36, 0.44, 0.58),
	]
	date_label.add_theme_color_override("font_color", season_ink[si] if si >= 0 and si < 4 else Act1Theme.INK_MUTED)

func _on_man(v: float):
	mandate_bar.value = v
	mandate_fill.bg_color = Act1Theme.mandate_fill(v)
	mandate_value.text = str(int(round(v)))
	mandate_warning.text = "你救不了这座江山" if v >= 70.0 else ""

func _on_prompt(t: String):
	_prompt_text = t
	prompt_label.text = t
	var wrap: CanvasItem = prompt_label.get_meta("wrap")
	wrap.visible = not t.is_empty()

func _on_hide():
	_prompt_text = ""
	prompt_label.text = ""
	var wrap: CanvasItem = prompt_label.get_meta("wrap")
	wrap.visible = false

func _on_objective(t: String) -> void:
	_objective_text = t
	if objective_label:
		objective_label.text = t if t != "" else ""
	if objective_wrap:
		objective_wrap.visible = t != ""

func _on_memory(_id: String, _weight: int):
	_update_footer()

func _on_zone(zname: String) -> void:
	zone_label.text = zname
	_zone_t = 1.6
	zone_wrap.modulate.a = 1.0

func _on_farm(ripe: int, growing: int, _total: int) -> void:
	_farm_ripe = ripe
	_farm_growing = growing
	_update_footer()

var _farm_ripe := 0
var _farm_growing := 0

func _update_footer() -> void:
	footer_label.text = "回忆 ×%d · 菜圃 熟%d 长%d" % [
		IssueManager.memories.size(), _farm_ripe, _farm_growing]
