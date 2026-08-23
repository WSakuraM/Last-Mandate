extends Node
# 区块三·支线：周氏园中"人不是折子"回声。
# S4 一幕起·二幕隐·三幕显的主情感线——第一幕 portion。
# ~day30 由 Act1Director 日间 tick 触发 trigger()。
# 周氏（信王妃）立在菜畦边，递上一碗粥，说"人不是折子"。
# 写入 MF_A1_ZHOU_NOT_MEMORIAL(w5, Ⅰ)。终章回声为"爱过谁的证据"。

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _triggered := false

func trigger():
	if _triggered:
		return
	_triggered = true
	_show_card()

func _show_card():
	IssueManager.night_council_active = true   # 锁世界输入
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
	card.custom_minimum_size = Vector2(540, 280)
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

	var title := Label.new()
	title.text = "园中 · 谷风"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = "你蹲在菜畦边翻土，身后忽然多了一片影子。\n\n是信王妃周氏。她没穿大裳，只系着件半旧的袄，手里端着碗粥，搁在畦埂上。\n\n「别光顾着这些菜。你也该吃。」\n\n你接过碗，粥还烫。她看着那几畦菜，忽然说了一句：\n\n「殿下，这园子里种的是菜，不是折子。折子写不完的，人是活的。」\n\n风过枣树梢，叶子沙沙响。她没再说什么，转身走了。那碗粥你喝了，很暖。"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	# 写入回忆碎片（终章回收，信王个人支柱 Ⅰ）
	IssueManager.add_memory("MF_A1_ZHOU_NOT_MEMORIAL", 5, \
		"周氏园中递粥：人不是折子，折子写不完的，人是活的", "Ⅰ")
	# 设旗标供跨幕交叉台词检查
	IssueManager.flags["zhoushi_met_act1"] = true

	# 超时自动关闭（兜底）
	var t := Timer.new()
	t.wait_time = 9.0
	t.one_shot = true
	t.timeout.connect(_dismiss)
	add_child(t)
	t.start()
	set_process(true)

func _process(_delta):
	if overlay and Input.is_key_pressed(KEY_E):
		_dismiss()

func _dismiss():
	if overlay:
		overlay.queue_free()
		overlay = null
	IssueManager.night_council_active = false
	set_process(false)
