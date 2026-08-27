extends CanvasLayer
# 3D 俯视 HUD：木框资源条 + 季日 + 底部交互提示（对齐参考图角落布局）。

var bars := {}
var mandate_bar: ProgressBar
var mandate_fill: StyleBoxFlat
var mandate_warning: Label
var info_label: Label
var prompt_label: Label
var memory_label: Label
var farm_label: Label
var season_hint: Label
var zone_label: Label
var _zone_t := 0.0

const INK := Color(0.28, 0.18, 0.12)
const CREAM := Color(0.96, 0.90, 0.78)
const WOOD := Color(0.42, 0.28, 0.16)

func _ready():
	layer = 20
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var panel := _wood_panel()
	panel.position = Vector2(16, 16)
	panel.custom_minimum_size = Vector2(320, 0)
	root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.add_theme_color_override("font_color", CREAM)
	vb.add_child(info_label)

	var names := {
		"treasury": "国库", "people": "民心", "border_army": "边军",
		"court_order": "朝堂", "emperor_heart": "君心"
	}
	for key in names.keys():
		var hb := HBoxContainer.new()
		var lab := Label.new()
		lab.text = String(names[key])
		lab.custom_minimum_size = Vector2(52, 0)
		lab.add_theme_font_size_override("font_size", 13)
		lab.add_theme_color_override("font_color", CREAM)
		var bar := ProgressBar.new()
		bar.max_value = 100.0
		bar.value = 50.0
		bar.custom_minimum_size = Vector2(200, 16)
		bar.show_percentage = false
		_style_bar(bar, Color(0.72, 0.52, 0.28))
		hb.add_child(lab)
		hb.add_child(bar)
		vb.add_child(hb)
		bars[key] = bar

	mandate_bar = ProgressBar.new()
	mandate_bar.max_value = 100.0
	mandate_bar.value = 12.0
	mandate_bar.custom_minimum_size = Vector2(200, 16)
	mandate_bar.show_percentage = false
	mandate_fill = StyleBoxFlat.new()
	mandate_fill.bg_color = _mandate_color(12.0)
	mandate_fill.corner_radius_top_left = 3
	mandate_fill.corner_radius_top_right = 3
	mandate_fill.corner_radius_bottom_left = 3
	mandate_fill.corner_radius_bottom_right = 3
	mandate_bar.add_theme_stylebox_override("fill", mandate_fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.18, 0.12, 0.08, 0.7)
	mandate_bar.add_theme_stylebox_override("background", bg)
	var mh := HBoxContainer.new()
	var ml := Label.new()
	ml.text = "天命"
	ml.custom_minimum_size = Vector2(52, 0)
	ml.add_theme_font_size_override("font_size", 13)
	ml.add_theme_color_override("font_color", Color(0.95, 0.78, 0.42))
	mh.add_child(ml)
	mh.add_child(mandate_bar)
	vb.add_child(mh)

	var lock_label := Label.new()
	lock_label.text = "锁底 4 · 不可清零"
	lock_label.add_theme_font_size_override("font_size", 11)
	lock_label.add_theme_color_override("font_color", Color(0.72, 0.62, 0.48))
	vb.add_child(lock_label)

	mandate_warning = Label.new()
	mandate_warning.text = ""
	mandate_warning.add_theme_color_override("font_color", Color(0.85, 0.32, 0.22))
	mandate_warning.add_theme_font_size_override("font_size", 13)
	vb.add_child(mandate_warning)

	memory_label = Label.new()
	memory_label.text = "回忆碎片 ×0"
	memory_label.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42))
	memory_label.add_theme_font_size_override("font_size", 13)
	vb.add_child(memory_label)

	farm_label = Label.new()
	farm_label.text = "菜圃 · 成熟 0 · 生长 0"
	farm_label.add_theme_font_size_override("font_size", 12)
	farm_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.62))
	vb.add_child(farm_label)

	season_hint = Label.new()
	season_hint.text = _season_yield_hint(0)
	season_hint.add_theme_font_size_override("font_size", 11)
	season_hint.add_theme_color_override("font_color", Color(0.68, 0.62, 0.52))
	vb.add_child(season_hint)

	var hint := Label.new()
	hint.text = "滚轮拉远/拉近 · R 回到默认机位 · Shift+←→ 转视角"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.62, 0.54, 0.42))
	vb.add_child(hint)

	var prompt_wrap := PanelContainer.new()
	prompt_wrap.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_wrap.offset_left = -240
	prompt_wrap.offset_right = 240
	prompt_wrap.offset_top = -72
	prompt_wrap.offset_bottom = -24
	prompt_wrap.add_theme_stylebox_override("panel", _wood_stylebox(0.92))
	root.add_child(prompt_wrap)
	prompt_label = Label.new()
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 18)
	prompt_label.add_theme_color_override("font_color", CREAM)
	prompt_wrap.add_child(prompt_label)
	prompt_wrap.visible = false
	prompt_label.set_meta("wrap", prompt_wrap)

	zone_label = Label.new()
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	zone_label.offset_left = -160
	zone_label.offset_right = 160
	zone_label.offset_top = 28
	zone_label.offset_bottom = 64
	zone_label.add_theme_font_size_override("font_size", 22)
	zone_label.add_theme_color_override("font_color", CREAM)
	zone_label.add_theme_color_override("font_outline_color", Color(0.18, 0.12, 0.08, 0.85))
	zone_label.add_theme_constant_override("outline_size", 6)
	zone_label.modulate.a = 0.0
	root.add_child(zone_label)

	ResourceManager.resources_changed.connect(_on_res)
	ResourceManager.mandate_changed.connect(_on_man)
	EventBus.interact_prompt.connect(_on_prompt)
	EventBus.interact_hide.connect(_on_hide)
	IssueManager.memory_added.connect(_on_memory)
	EventBus.zone_entered.connect(_on_zone)
	EventBus.farm_status.connect(_on_farm)

func _process(delta: float) -> void:
	if _zone_t > 0.0:
		_zone_t = maxf(0.0, _zone_t - delta)
		if _zone_t > 0.45:
			zone_label.modulate.a = 1.0
		else:
			zone_label.modulate.a = _zone_t / 0.45
	memory_label.modulate = memory_label.modulate.lerp(Color.WHITE, 1.0 - exp(-5.0 * delta))

func _wood_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _wood_stylebox(0.88))
	return p

func _wood_stylebox(alpha: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(WOOD.r, WOOD.g, WOOD.b, alpha)
	sb.border_color = Color(0.72, 0.55, 0.32, 0.95)
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb

func _style_bar(bar: ProgressBar, fill: Color) -> void:
	var f := StyleBoxFlat.new()
	f.bg_color = fill
	f.corner_radius_top_left = 3
	f.corner_radius_top_right = 3
	f.corner_radius_bottom_left = 3
	f.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", f)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.18, 0.12, 0.08, 0.7)
	bar.add_theme_stylebox_override("background", bg)

func _on_res(s: Dictionary):
	for k in bars:
		bars[k].value = s[k]
	var seasons: Array = ["春", "夏", "秋", "冬"]
	var si: int = int(s.season)
	var season_name: String = String(seasons[si]) if si >= 0 and si < 4 else "?"
	var purse_line := ""
	if float(s.get("private_purse", 0.0)) > 0.01:
		purse_line = " · 私囊 %.1f" % float(s.private_purse)
	if bool(s.get("prince_tax_edict", false)):
		purse_line += " · 纳赋%.0f%%" % (ResourceManager.PRINCE_TAX_RATE * 100.0)
	info_label.text = "%s · 第 %d 日 · 年 %d%s" % [season_name, int(s.day), int(s.year), purse_line]
	if season_hint:
		season_hint.text = _season_yield_hint(si)
	var season_ink: Array[Color] = [
		Color(0.72, 0.90, 0.62),
		Color(0.95, 0.88, 0.55),
		Color(0.95, 0.70, 0.42),
		Color(0.82, 0.88, 0.95),
	]
	info_label.add_theme_color_override("font_color", season_ink[si] if si >= 0 and si < 4 else CREAM)

func _on_man(v: float):
	mandate_bar.value = v
	mandate_fill.bg_color = _mandate_color(v)
	if v >= 70.0:
		mandate_warning.text = "你救不了这座江山"
	else:
		mandate_warning.text = ""

func _mandate_color(v: float) -> Color:
	if v < 30.0:
		return Color(0.78, 0.62, 0.28)
	elif v < 70.0:
		return Color(0.82, 0.42, 0.18)
	else:
		return Color(0.62, 0.16, 0.12)

func _on_prompt(t: String):
	prompt_label.text = t
	var wrap: CanvasItem = prompt_label.get_meta("wrap")
	wrap.visible = not t.is_empty()

func _on_hide():
	prompt_label.text = ""
	var wrap: CanvasItem = prompt_label.get_meta("wrap")
	wrap.visible = false

func _on_memory(_id: String, _weight: int):
	memory_label.text = "回忆碎片 ×%d" % IssueManager.memories.size()
	memory_label.modulate = Color(1.0, 0.92, 0.55)

func _on_zone(zname: String) -> void:
	zone_label.text = zname
	_zone_t = 1.8
	zone_label.modulate.a = 1.0

func _on_farm(ripe: int, growing: int, total: int) -> void:
	if farm_label:
		farm_label.text = "菜圃 · 成熟 %d · 生长 %d / %d" % [ripe, growing, total]

func _season_yield_hint(season: int) -> String:
	var base := ""
	match season:
		0: base = "春收 ×150% · 七成入私囊 · 生长 2 日"
		1: base = "夏收 ×100% · 七成入私囊 · 生长 3 日"
		2: base = "秋收 ×125% · 七成入私囊 · 生长 2 日"
		3: base = "冬收 ×40% · 七成入私囊 · 生长 4 日"
	var bonus := ""
	if IssueManager.flags.get("farm_growth_boost", false):
		bonus += " · 生长-1日"
	if int(IssueManager.flags.get("farm_yield_boost_season", -1)) == season:
		bonus += " · 本季菜收+10%"
	if ResourceManager.is_prince_tax_active():
		return base + bonus + " · 季初岁禄 · 所得纳赋 %.0f%%" % (ResourceManager.PRINCE_TAX_RATE * 100.0)
	return base + bonus + " · 季初岁禄 · 每30日月例"
