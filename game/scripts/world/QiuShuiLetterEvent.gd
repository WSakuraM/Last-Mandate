extends Node
# M1A4 秋穗家书：中段天灾段（total_day>=50）由 Act1Director 触发。
# 秋穗递上乡下家书——大旱连年，家中颗粒无收，老父卧病，幼弟嗷嗷。
# 信王三选：借粮（动私囊·仁慈+）/ 象征性给（中立）/ 婉拒（自保）。
# 仁慈选择写入 Traits（flag: kind_likely），软化 M2 开仓台词。

signal letter_resolved(choice: String)

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _card: PanelContainer
var _vb: VBoxContainer
var _triggered := false
var _choice := ""
var _phase := "letter"   # letter / feedback
var _key_cd := 0.0

# 三选数据
var _choices := [
	{
		"id": "lend",
		"label": "借粮（动私囊）",
		"desc": "从私囊取出十五兩银子，托秋穗寄回乡下。",
		"feedback": "秋穗跪地叩首，泪如雨下。\n你看着她的背影，想起门外那些跪在雪泥里的人。\n——这一笔银子，是你自己的。",
		"purse_cost": 15.0,
		"people_delta": 5.0,
		"flag": "kind_likely",
		"memory_id": "MF_A1_QIUSHUI_LEND",
		"memory_weight": 7,
		"memory_text": "秋穗家书——你从私囊取银借粮，给了活路",
		"memory_pillar": "Ⅲ",
	},
	{
		"id": "token",
		"label": "象征性给",
		"desc": "给些碎银，聊表心意。",
		"feedback": "秋穗接过碎银，低了头。\n你知道这点银子救不了命，可你也只能做到这一步。",
		"purse_cost": 3.0,
		"people_delta": 2.0,
		"flag": "",
		"memory_id": "MF_A1_QIUSHUI_TOKEN",
		"memory_weight": 4,
		"memory_text": "秋穗家书——你给了些碎银，聊表心意",
		"memory_pillar": "Ⅲ",
	},
	{
		"id": "refuse",
		"label": "婉拒",
		"desc": "府中也不宽裕，婉言回绝。",
		"feedback": "秋穗怔了一瞬，随即叩首告退。\n她的背影很安静，安静得让人不安。",
		"purse_cost": 0.0,
		"people_delta": -3.0,
		"flag": "",
		"memory_id": "MF_A1_QIUSHUI_REFUSE",
		"memory_weight": 3,
		"memory_text": "秋穗家书——你婉言回绝了她的请求",
		"memory_pillar": "Ⅲ",
	},
]

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

	_card = PanelContainer.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_card.custom_minimum_size = Vector2(580, 0)
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
		"letter":
			_build_letter()
		"feedback":
			_build_feedback()

func _build_letter():
	var title := Label.new()
	title.text = "秋穗家书"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	_vb.add_child(title)

	_vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = "秋穗跪在你面前，递上一封皱巴巴的家书。\n\n信是她父亲写的，字迹歪斜：「大旱连年，颗粒无收。老母已去，幼弟嗷嗷。只盼女儿在王府讨些活路……」\n\n秋穗低着头，不敢看你。烛火映在纸上，那几个字像是在抖。\n\n——吴伯教过你：私囊是你家的，官银是天下人的。这一笔，若出，只能出自私囊。"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	_vb.add_child(txt)

	_vb.add_child(HSeparator.new())

	# 显示私囊结余，让玩家知道自己的财务状况
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

	# 三选按钮（硬编码避免 lambda 捕获问题）
	var b1 := Button.new()
	b1.text = "借粮——动私囊十五兩（1）"
	b1.custom_minimum_size = Vector2(420, 40)
	b1.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	b1.pressed.connect(func(): _on_choice(0))
	_vb.add_child(b1)

	var b2 := Button.new()
	b2.text = "象征性给——碎银三兩（2）"
	b2.custom_minimum_size = Vector2(420, 40)
	b2.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	b2.pressed.connect(func(): _on_choice(1))
	_vb.add_child(b2)

	var b3 := Button.new()
	b3.text = "婉拒——府中不宽裕（3）"
	b3.custom_minimum_size = Vector2(420, 40)
	b3.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	b3.pressed.connect(func(): _on_choice(2))
	_vb.add_child(b3)

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
	# 结算后果
	if float(c["purse_cost"]) > 0.0:
		ResourceManager.add_private_purse(-float(c["purse_cost"]))
	if float(c["people_delta"]) != 0.0:
		ResourceManager.add("people", float(c["people_delta"]))
	if c["flag"] != "":
		IssueManager.flags[c["flag"]] = true
	IssueManager.add_memory(c["memory_id"], int(c["memory_weight"]), c["memory_text"], c.get("memory_pillar", "Ⅲ"))
	_phase = "feedback"
	_rebuild()

func _process(delta):
	_key_cd = max(0.0, _key_cd - delta)
	if _key_cd > 0.0:
		return
	if _phase == "letter":
		if Input.is_key_pressed(KEY_1):
			_key_cd = 0.3
			_on_choice(0)
		elif Input.is_key_pressed(KEY_2):
			_key_cd = 0.3
			_on_choice(1)
		elif Input.is_key_pressed(KEY_3):
			_key_cd = 0.3
			_on_choice(2)
	elif _phase == "feedback":
		if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER):
			_key_cd = 0.3
			_dismiss()

func _dismiss():
	if overlay:
		overlay.queue_free()
		overlay = null
	IssueManager.night_council_active = false
	letter_resolved.emit(_choice)
	set_process(false)
