extends Node
# 区块三·支线：中使借果（可选 S2）。
# 宫中中使（太监）来王府"借"果——实为勒索。
# ~day60 由 Act1Director 日间 tick 触发 trigger()（可选，需玩家自行抉择）。
# 二选：①顺从（私囊-5·Ⅲ类回忆MF_A1_EUNUCH_FRUIT w7）②婉拒（设flag eunuch_refused·禄米阴影）。
# 遵循 QiuShuiLetterEvent 的选择面板模式（StyleBoxFlat卡片+键盘+鼠标双输入）。

signal fruit_resolved(choice: String)

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _card: PanelContainer
var _vb: VBoxContainer
var _triggered := false
var _choice := ""
var _phase := "demand"   # demand / feedback
var _key_cd := 0.0

var _choices := [
	{
		"id": "comply",
		"label": "顺从——给五兩银子打发了",
		"desc": "息事宁人，从私囊取银。",
		"feedback": "中使掂了掂银子，哼了一声，转身走了。\n吴伯恨恨道：「这些阉狗，贪得无厌！」\n你摆摆手。这银子是从你自己的私囊里出的，不是官银。\n——可你知道，这只是个开始。",
		"purse_cost": 5.0,
		"flag": "eunuch_complied",
		"memory_id": "MF_A1_EUNUCH_FRUIT",
		"memory_weight": 7,
		"memory_text": "中使借果——你从私囊取银打发宫中太监的勒索",
	},
	{
		"id": "refuse",
		"label": "婉拒——府中无余财",
		"desc": "硬着头皮回绝，日后必有阴影。",
		"feedback": "中使的脸拉了下来，阴阳怪气道：「王爷好大的架子。」\n拂袖而去。吴伯低声道：「王爷，这等人得罪不起，日后禄米……」\n你打断他：「禄米是公账，他卡不了。」\n——可你知道，他卡得了别的。",
		"purse_cost": 0.0,
		"flag": "eunuch_refused",
		"memory_id": "",
		"memory_weight": 0,
		"memory_text": "",
	},
]

func trigger():
	if _triggered:
		return
	_triggered = true
	_show_card()

func _show_card():
	IssueManager.night_council_active = true
	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	_card = PanelContainer.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_card.custom_minimum_size = Vector2(560, 0)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.12, 0.1, 0.08, 0.97)
	cs.border_color = GOLD
	cs.border_width_left = 2; cs.border_width_top = 2
	cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6; cs.corner_radius_bottom_right = 6
	_card.add_theme_stylebox_override("panel", cs)
	root.add_child(_card)

	_vb = VBoxContainer.new()
	_vb.add_theme_constant_override("separation", 12)
	_vb.add_theme_constant_override("margin_left", 24)
	_vb.add_theme_constant_override("margin_top", 24)
	_vb.add_theme_constant_override("margin_right", 24)
	_vb.add_theme_constant_override("margin_bottom", 24)
	_card.add_child(_vb)

	_rebuild()
	set_process(true)

func _rebuild():
	for c in _vb.get_children():
		c.queue_free()
	match _phase:
		"demand":
			_build_demand()
		"feedback":
			_build_feedback()

func _build_demand():
	var title := Label.new()
	title.text = "中使借果"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	_vb.add_child(title)

	_vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = "一个穿青衣的中使晃进了府门，说是奉司礼监之命来「借」些果品。\n\n吴伯低声告诉你：「这是来要银子的，果品不过是名目。上次信王府没给，禄米就迟了两个月。」\n\n中使笑眯眯地看着你，手里捏着拂尘，指尖在尘尾上一下一下地搓。"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	_vb.add_child(txt)

	_vb.add_child(HSeparator.new())

	var purse_label := Label.new()
	purse_label.text = "（私囊结余：%.0f 兩）" % ResourceManager.private_purse
	purse_label.add_theme_font_size_override("font_size", 14)
	purse_label.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	_vb.add_child(purse_label)

	var hint := Label.new()
	hint.text = "你的决定："
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	_vb.add_child(hint)

	var b1 := Button.new()
	b1.text = "顺从——给五兩打发（1）"
	b1.custom_minimum_size = Vector2(420, 40)
	b1.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	b1.pressed.connect(func(): _on_choice(0))
	_vb.add_child(b1)

	var b2 := Button.new()
	b2.text = "婉拒——府中无余财（2）"
	b2.custom_minimum_size = Vector2(420, 40)
	b2.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	b2.pressed.connect(func(): _on_choice(1))
	_vb.add_child(b2)

func _build_feedback():
	var c: Dictionary = {}
	for item in _choices:
		if item["id"] == _choice:
			c = item
			break
	if c.is_empty():
		return

	var title := Label.new()
	title.text = c["label"]
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", GOLD)
	_vb.add_child(title)

	var fb := Label.new()
	fb.text = c["feedback"]
	fb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fb.add_theme_font_size_override("font_size", 16)
	fb.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	_vb.add_child(fb)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	_vb.add_child(hint)

func _on_choice(idx: int):
	var c: Dictionary = _choices[idx]
	_choice = c["id"]
	if float(c["purse_cost"]) > 0.0:
		ResourceManager.add_private_purse(-float(c["purse_cost"]))
	if c["flag"] != "":
		IssueManager.flags[c["flag"]] = true
	var mid: String = c["memory_id"]
	if mid != "":
		IssueManager.add_memory(mid, int(c["memory_weight"]), c["memory_text"], "Ⅲ")
	_phase = "feedback"
	_rebuild()

func _process(delta):
	_key_cd = max(0.0, _key_cd - delta)
	if _key_cd > 0.0:
		return
	if _phase == "demand":
		if Input.is_key_pressed(KEY_1):
			_key_cd = 0.3
			_on_choice(0)
		elif Input.is_key_pressed(KEY_2):
			_key_cd = 0.3
			_on_choice(1)
	elif _phase == "feedback":
		if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER):
			_key_cd = 0.3
			_dismiss()

func _dismiss():
	if overlay:
		overlay.queue_free()
		overlay = null
	IssueManager.night_council_active = false
	fruit_resolved.emit(_choice)
	set_process(false)
