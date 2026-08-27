extends Node
# 区块三·支线：蝗旱涝（可选 S2）。
# 天灾降临菜畦——蝗群过境/大旱/霖涝三选一随机。
# ~day75 由 Act1Director 日间 tick 触发 trigger()。
# 设 drought flag（CourtPlot._harvest 已读取此 flag 做减产×0.5）。
# 天灾后连锁：皇帝圣旨——岁禄折减 + 藩王开征纳赋。
# 写入 MF_A1_LOCUST(w7, Ⅲ)。遵循 RefugeeVignette 叙事卡模式。

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _triggered := false
var _await_edict := false

var _calamities := [
	{
		"title": "蝗过境",
		"text": "天边涌来一片乌云——不是云，是蝗。\n\n遮天蔽日的虫群落在菜畦上，咀嚼声像下雨。你站在廊下看着，什么也做不了。\n\n吴伯拿竹竿赶了一阵，赶不完。沈戍提着棍来帮忙，也只打落了百十只。\n\n半炷香后，蝗群走了。六畦菜，只剩光杆。",
	},
	{
		"title": "大旱",
		"text": "连着二十天没落一滴雨。井水浅了半尺，菜畦裂出细缝。\n\n你蹲在畦边，叶子焦黄卷曲，一碰就碎。吴伯说城外河也快断流了，已有村子开始逃荒。\n\n你提了桶去浇，一桶水泼下去，转眼就干。地像渴坏了的嘴，张着口等。\n\n天白花花的，没有一片云。",
	},
	{
		"title": "霖涝",
		"text": "雨连下了七天七夜，院里积了水，没过脚面。\n\n菜畦泡在黄泥汤里，根都烂了。你穿了草鞋去捞，捞起来一把烂叶子，腥气冲鼻。\n\n吴伯叹气：「涝了根，比旱还难救。旱是天不给你水，涝是天不给你地。」\n\n枣树落了一地果，泡在水里，浮浮沉沉。",
	},
]

func trigger():
	if _triggered:
		return
	_triggered = true
	_show_card()

func _show_card():
	IssueManager.night_council_active = true
	IssueManager.flags["drought"] = true

	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(540, 260)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.12, 0.1, 0.08, 0.97)
	cs.border_color = GOLD
	cs.border_width_left = 2; cs.border_width_top = 2
	cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6; cs.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", cs)
	root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.add_theme_constant_override("margin_left", 22)
	vb.add_theme_constant_override("margin_top", 22)
	vb.add_theme_constant_override("margin_right", 22)
	vb.add_theme_constant_override("margin_bottom", 22)
	card.add_child(vb)

	var cal: Dictionary = _calamities[randi() % _calamities.size()]

	var title := Label.new()
	title.text = cal.get("title", "天灾")
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = cal.get("text", "")
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	IssueManager.add_memory("MF_A1_LOCUST", 7, \
		"天灾降临菜畦——" + cal.get("title", "天灾") + "，你什么也做不了", "Ⅲ")
	IssueManager.flags["calamity_triggered"] = true

	var t := Timer.new()
	t.wait_time = 8.0
	t.one_shot = true
	t.timeout.connect(_dismiss)
	add_child(t)
	t.start()
	set_process(true)

func _show_edict_card() -> void:
	IssueManager.night_council_active = true
	ResourceManager.apply_prince_tax_edict()

	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(560, 300)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.14, 0.1, 0.08, 0.98)
	cs.border_color = Color(0.78, 0.22, 0.18)
	cs.border_width_left = 2; cs.border_width_top = 2
	cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6; cs.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", cs)
	root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.add_theme_constant_override("margin_left", 24)
	vb.add_theme_constant_override("margin_top", 24)
	vb.add_theme_constant_override("margin_right", 24)
	vb.add_theme_constant_override("margin_bottom", 24)
	card.add_child(vb)

	var title := Label.new()
	title.text = "圣旨 · 岁禄更制"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.92, 0.32, 0.24))
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = "辽事未宁，税赋不继，又值天灾，户部告匮。\n\n\n皇帝下旨：诸藩岁禄减半；自今各藩所得，悉按一成八分纳赋，不得隐匿。\n\n\n吴伯读罢，只低声道：「王爷，往后挣得多，交得也多。」"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续 · 季初岁禄将折减 · 菜圃收获亦纳赋）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	IssueManager.add_memory("MF_A1_STIPEND_EDICT", 6, \
		"天灾之后，圣旨减藩王岁禄，并令诸藩纳赋", "Ⅱ")

	var t := Timer.new()
	t.wait_time = 10.0
	t.one_shot = true
	t.timeout.connect(_dismiss_edict)
	add_child(t)
	t.start()
	set_process(true)

func _process(_delta):
	if overlay and Input.is_key_pressed(KEY_E):
		if _await_edict:
			_dismiss_edict()
		else:
			_dismiss()

func _dismiss():
	if overlay:
		overlay.queue_free()
		overlay = null
	set_process(false)
	if not IssueManager.flags.get("prince_tax_edict", false):
		_await_edict = true
		_show_edict_card()
	else:
		IssueManager.night_council_active = false

func _dismiss_edict():
	if overlay:
		overlay.queue_free()
		overlay = null
	_await_edict = false
	IssueManager.night_council_active = false
	set_process(false)
