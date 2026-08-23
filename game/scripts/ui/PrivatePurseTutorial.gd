extends CanvasLayer
# M1A1 吴伯私囊教程：开场即触发的轻交互。
# 玩家将数笔银两归类为「私囊」或「官银」，吴伯逐一反馈。
# 私囊结余存入 ResourceManager.private_purse，跨幕转为 M2 国库初值。
# 教："私囊是你家的，官银是天下人的。"

signal tutorial_completed(private_total: float)

const GOLD := Color(0.95, 0.8, 0.4)
const SCALE_TREASURY := 0.1  # 官银→国库缩放（兩→0-100 资源体系）

# 4 笔银两：source=来源, amount=兩数, correct=正确归类(si/gong)
var _items := [
	{"source": "王府月例银", "amount": 12.0, "correct": "si",
	 "ok": "正是。这是王府的月例，该入私囊。",
	 "err": "王爷，这是咱府上的月例银，该归私囊才是。"},
	{"source": "田庄秋租", "amount": 28.0, "correct": "si",
	 "ok": "不错。田庄租课，乃府中私产。",
	 "err": "这田庄是王爷家的私产，租课自然该入私囊。"},
	{"source": "户部拨银", "amount": 50.0, "correct": "gong",
	 "ok": "正是。户部拨银出自国库，虽是给王爷的，却是天下人的银子。",
	 "err": "王爷，这户部拨银出自国库，是天下人的银子，不可入私囊。"},
	{"source": "官员馈银", "amount": 20.0, "correct": "gong",
	 "ok": "王爷明鉴。官员馈银，看似私情，实则是拿朝廷的权做交易。该入公账。",
	 "err": "这……王爷，官员送的银子，说是私情，可送银的人手里握的是官权。这种银子最该入公账，不然日后说不清。"},
]

var _step := 0
var _phase := "item"   # item / feedback / summary
var _private_total := 0.0
var _public_total := 0.0
var _last_correct := false
var _card: PanelContainer
var _vb: VBoxContainer
var _key_cd := 0.0

func present():
	process_mode = Node.PROCESS_MODE_ALWAYS
	IssueManager.night_council_active = true
	_build_base()
	_phase = "item"
	_rebuild()

func _build_base():
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	_card = PanelContainer.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_card.custom_minimum_size = Vector2(520, 0)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.15, 0.12, 0.1, 0.97)
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

func _rebuild():
	for c in _vb.get_children():
		c.queue_free()
	match _phase:
		"item":
			_build_item_phase()
		"feedback":
			_build_feedback_phase()
		"summary":
			_build_summary_phase()

func _build_item_phase():
	var title := Label.new()
	title.text = "吴伯 · 私囊"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	_vb.add_child(title)

	if _step == 0:
		var intro := Label.new()
		intro.text = "王爷，老奴今日有几笔银子要请您过目。您分一分，哪些该入私囊，哪些该归公账。"
		intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		intro.add_theme_font_size_override("font_size", 15)
		intro.add_theme_color_override("font_color", Color(0.75, 0.72, 0.68))
		_vb.add_child(intro)

	_vb.add_child(HSeparator.new())

	var item: Dictionary = _items[_step]
	var src := Label.new()
	src.text = "%s · %d 兩" % [item["source"], int(item["amount"])]
	src.add_theme_font_size_override("font_size", 20)
	src.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	_vb.add_child(src)

	var hint := Label.new()
	hint.text = "归类为："
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	_vb.add_child(hint)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	_vb.add_child(row)

	var b_si := Button.new()
	b_si.text = "私囊（1）"
	b_si.custom_minimum_size = Vector2(160, 44)
	b_si.pressed.connect(func(): _on_choice(true))
	row.add_child(b_si)

	var b_gong := Button.new()
	b_gong.text = "官银（2）"
	b_gong.custom_minimum_size = Vector2(160, 44)
	b_gong.pressed.connect(func(): _on_choice(false))
	row.add_child(b_gong)

func _build_feedback_phase():
	var item: Dictionary = _items[_step]
	var fb := Label.new()
	if _last_correct:
		fb.text = item["ok"]
	else:
		fb.text = item["err"]
	fb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fb.add_theme_font_size_override("font_size", 17)
	fb.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	_vb.add_child(fb)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	_vb.add_child(hint)

func _build_summary_phase():
	var title := Label.new()
	title.text = "私囊归档"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	_vb.add_child(title)

	_vb.add_child(HSeparator.new())

	var si_label := Label.new()
	si_label.text = "私囊结余  %d 兩" % int(_private_total)
	si_label.add_theme_font_size_override("font_size", 18)
	si_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	_vb.add_child(si_label)

	var gong_label := Label.new()
	gong_label.text = "官银入公账  %d 兩" % int(_public_total)
	gong_label.add_theme_font_size_override("font_size", 18)
	gong_label.add_theme_color_override("font_color", Color(0.75, 0.72, 0.68))
	_vb.add_child(gong_label)

	_vb.add_child(HSeparator.new())

	var moral := Label.new()
	moral.text = "私囊是你家的，官银是天下人的。\n这天下的账，迟早要算的。"
	moral.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	moral.add_theme_font_size_override("font_size", 16)
	moral.add_theme_color_override("font_color", Color(0.8, 0.77, 0.72))
	_vb.add_child(moral)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	_vb.add_child(hint)

func _on_choice(si: bool):
	var item: Dictionary = _items[_step]
	_last_correct = (si and item["correct"] == "si") or (not si and item["correct"] == "gong")
	if si:
		_private_total += float(item["amount"])
	else:
		_public_total += float(item["amount"])
		ResourceManager.add("treasury", float(item["amount"]) * SCALE_TREASURY)
	_phase = "feedback"
	_rebuild()

func _process(delta):
	_key_cd = max(0.0, _key_cd - delta)
	if _key_cd > 0.0:
		return
	if _phase == "item":
		if Input.is_key_pressed(KEY_1):
			_key_cd = 0.3
			_on_choice(true)
		elif Input.is_key_pressed(KEY_2):
			_key_cd = 0.3
			_on_choice(false)
	elif _phase == "feedback":
		if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER):
			_key_cd = 0.3
			_advance()
	elif _phase == "summary":
		if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER):
			_key_cd = 0.3
			_dismiss()

func _advance():
	_step += 1
	if _step >= _items.size():
		_phase = "summary"
		_finish_tutorial()
	else:
		_phase = "item"
	_rebuild()

func _finish_tutorial():
	ResourceManager.add_private_purse(_private_total)
	IssueManager.add_memory("MF_A1_PURSE_TUTORIAL", 3, \
		"吴伯教你分银：私囊是你家的，官银是天下人的", "Ⅰ")

func _dismiss():
	IssueManager.night_council_active = false
	tutorial_completed.emit(_private_total)
	queue_free()
