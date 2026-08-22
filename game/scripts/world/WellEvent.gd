extends Node3D
# 第一幕「井边」小事件：信王亲为下人汲水，润泽府中人心。
# 一次性叙事卡 + 轻微民心增益 + 回忆碎片（Ⅰ · 府中人心）。

const GOLD := Color(0.95, 0.8, 0.4)

var shown := false
var overlay: CanvasLayer

func _ready():
	var area := Area3D.new()
	area.name = "WellZone"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 3.0
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect(_on_enter)
	add_child(area)
	position = Vector3(-10, 0, 8)   # 与 Act1Director 中水井 mesh 同址

func _on_enter(b):
	if not b.is_in_group("player"):
		return
	if shown:
		return
	shown = true
	_show_card()

func _show_card():
	IssueManager.night_council_active = true   # 锁世界输入，避免 UI 叠加
	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(540, 220)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.15, 0.12, 0.1, 0.97)
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
	title.text = "井边"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	var txt := Label.new()
	txt.text = "你挽起袖口，替怯生生的小厮打上一桶井水。他慌得要接，你只说：『自家的人，不必拘礼。』\n——那时你还只是信王，府中岁月尚暖。"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 18)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	ResourceManager.add("people", 1.0)
	IssueManager.add_memory("MF_A1_WELL", 4, "井边，你亲手为下人打上一桶水", "Ⅰ")

	var t := Timer.new()
	t.wait_time = 6.0
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
