extends Node
# 区块三·支线：沈柳鸳鸯线（沈戍×柳筝）第一幕三拍。
# S1 全三幕情感辅线——第一幕 portion：门前粥与刀 → 灶口定情 → 夜召留府。
# 每拍一次性叙事卡，遵循 AenSeedEvent 模式（CanvasLayer + StyleBoxFlat + GOLD 边框）。
# Beat2 写入 MF_LOVERS_SUGAR(w6, Ⅰ)，Beat3 写入 MF_A1_SHEN_GUARD(w5, Ⅰ)。
# 终章蒙太奇回收为"爱过谁的证据"。

signal beat_completed(beat_id: String)

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _current_beat := ""

# 三拍数据
var _beats := {
	"b1": {
		"title": "门前 · 粥与刀",
		"text": "府门外蹲着个老兵，怀里揣着一把旧刀，刀鞘磨得发白。\n\n吴伯去问了，回来说：「这汉子姓沈，辽东退下来的，没粮票没路引，说是……想拿刀换碗粥。」\n\n你走到门口，他抬头看你，眼睛浑浊却直。\n「王爷，俺不是乞汉。这刀跟了俺十二年，斩过建奴。如今……换碗粥，给娃留口命。」\n\n你让吴伯取粥来，刀没收。沈戍就这么留在了府上，做了个看门的闲差。",
		"memory_id": "",
		"day_threshold": 15,
	},
	"b2": {
		"title": "灶口 · 半块糖",
		"text": "夜里你去厨房取水，灶口蹲着两个人影。\n\n是沈戍和厨娘柳筝。柳筝手里攥着什么东西，红了脸要藏，沈戍只是憨笑。\n\n你退了一步，没出声。却看见柳筝掰了半块糖塞进沈戍手里——灶火映着那点糖纸，亮闪闪的。\n\n沈戍说：「丫头，这糖金贵，你留着。」\n柳筝说：「你连刀都换了，还不许人给你块糖？」\n\n你悄悄退回去。院子里的风很凉，但灶口那点光，比灯亮。",
		"memory_id": "MF_LOVERS_SUGAR",
		"memory_weight": 6,
		"memory_pillar": "Ⅰ",
		"memory_text": "灶口定情——沈戍与柳筝的半块糖，院子里的一点暖",
		"day_threshold": 40,
	},
	"b3": {
		"title": "夜召 · 留府",
		"text": "今夜又该入夜召堂。你走到廊下，见沈戍提着根棍立在府门内侧。\n\n「王爷，今夜外头不太平，街上有人窜。俺不走，给您看着门。」\n\n你想说府中有护卫，不必他操心。可他只是站在那里，影子被灯笼拉得很长。\n\n柳筝从灶房探出半个头，又缩了回去。沈戍没回头，只低声说了句：\n「王爷，俺这条命，是您一碗粥换回来的。今夜……俺替您守着。」\n\n你点了点头，进了夜召堂。身后那根棍敲在门框上，笃、笃，一声一声。",
		"memory_id": "MF_A1_SHEN_GUARD",
		"memory_weight": 5,
		"memory_pillar": "Ⅰ",
		"memory_text": "夜召留府——沈戍提棍守门，一碗粥换来的忠义",
		"day_threshold": 105,
	},
}

func trigger(beat_id: String):
	if _current_beat != "":
		return   # 已有一拍正在展示
	if not _beats.has(beat_id):
		return
	if IssueManager.flags.get("shenliu_" + beat_id + "_done", false):
		return
	_current_beat = beat_id
	_show_card(beat_id)

func _show_card(beat_id: String):
	var b: Dictionary = _beats[beat_id]
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
	title.text = b.get("title", "")
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = b.get("text", "")
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	# 写入回忆碎片
	var mid: String = b.get("memory_id", "")
	if mid != "":
		IssueManager.add_memory(mid, int(b.get("memory_weight", 5)), \
			b.get("memory_text", ""), b.get("memory_pillar", "Ⅰ"))

	# 标记此拍完成
	IssueManager.flags["shenliu_" + beat_id + "_done"] = true

	# 超时自动关闭（兜底）
	var t := Timer.new()
	t.wait_time = 10.0
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
	var b := _current_beat
	_current_beat = ""
	beat_completed.emit(b)
	set_process(false)
