extends Node
# M1A3 阿恩递种夜谈：玩家首次播种时触发（由 EventBus.first_sow 驱动）。
# 阿恩（王承恩）递上谷种，夜谈一句承诺——"别忘了园子里的人"。
# 谷种作跨幕道具（flags.aen_seed_given），终章蒙太奇回收为 MF_A1_AEN_PROMISE。

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _triggered := false

func _ready():
	EventBus.first_sow.connect(_on_first_sow)

func _on_first_sow():
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
	card.custom_minimum_size = Vector2(560, 300)
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
	title.text = "夜谈 · 谷种"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = "夜色渐浓，王承恩不知何时站在了你身后，手里捧着一只布袋。\n\n「王爷，这是奴婢攒下的谷种。府中园子，总该有人种。」\n\n你接过布袋，沉甸甸的。他没走，又低声说了一句：\n\n「王爷，有朝一日……您若到了那高处，别忘了园子里的人。」\n\n烛火微晃，他的影子很长。"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 17)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	# 写入回忆碎片（终章回收，must 级 · 信王个人支柱 Ⅰ）
	IssueManager.add_memory("MF_A1_AEN_PROMISE", 9, \
		"阿恩夜谈递谷种：别忘了园子里的人", "Ⅰ")
	# 谷种作跨幕道具标记（存档 flags 已包含，M2/M3 可查）
	IssueManager.flags["aen_seed_given"] = true

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
