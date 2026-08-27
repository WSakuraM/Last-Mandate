extends Node
## M1A5 夜召·兄崩入继：第一幕强制收束演出（先于 Act1Closure 统计画面）。
## 根据一幕旗标（含兄弟线）插入交叉台词；写入 MF_A1_NIGHT_SUMMON。

signal accession_finished

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _lines: Array[String] = []
var _idx := 0
var _key_cd := 0.0

func trigger() -> void:
	_build_lines()
	_idx = 0
	_show_line()

func _build_lines() -> void:
	_lines = [
		"冬夜。马蹄踏碎霜，府门外的灯笼被风扯得乱晃。",
		"你正从菜畦边起身，吴伯已跪在廊下，声音发颤：「王爷……宫中来人了。」",
		"青衣中使立在阶前，手里捧着明黄卷轴。暖黄的烛火在他脸上切出一道冷线。",
	]
	if IssueManager.flags.get("brother_b3_done", false):
		_lines.append("你忽然想起数日前乾清宫的药气，和兄长攥住你腕时那一句：「祖制在此。」")
	elif IssueManager.flags.get("brother_b2_done", false):
		_lines.append("你想起那日兄长亲至府门，蹲在你的菜畦边看土——他说，除你之外，大明无路可继。")
	elif IssueManager.flags.get("brother_b1_done", false):
		_lines.append("你袖里还藏着兄长刻的那只木雀——翅纹不齐，刀口极细。")
	_lines.append("【中使】信王接旨——")
	_lines.append("【中使】（顿）天启皇帝龙驭宾天。")
	_lines.append("【中使】皇子皆早夭，无人可嗣。按祖宗成宪，兄崩弟及，遗诏立信王朱由检入承大统。")
	_lines.append("【中使】（低声）不是内廷争出来的名分，是祖制只剩这一条路。请王爷即刻入宫。")
	if IssueManager.flags.get("brother_b3_done", false):
		_lines.append("【中使】皇上临崩前还念叨：「五弟……把园子里的菜种好。朕……还想再吃你府上一次春菜。」")
	elif IssueManager.flags.get("brother_bond_warm", false):
		_lines.append("【中使】皇上曾跟奴婢说，信王在，他心里踏实。")
	elif IssueManager.flags.get("brother_advised_rest", false):
		_lines.append("【中使】皇上最后几日，果然少碰了木工。……只反复念您的名字。")
	_lines.append("你听见自己指节响了一声。园子里的土气还在袖里，像一层洗不掉的旧。")
	_lines.append("【你】……阿恩。")
	_lines.append("【阿恩】（跪着替你整理衣冠，从袖里摸出一只旧布袋，塞进你掌心）带上。旧谷种。")
	if IssueManager.flags.get("zhoushi_met_act1", false):
		_lines.append("【阿恩】王妃说，人不是折子。……奴婢只会重复这句话。")
	_lines.append("【你】宫里用得着？")
	_lines.append("【阿恩】用不着。王爷看着，会记得自己不是从龙椅里长出来的。")
	if IssueManager.flags.get("shenliu_b3_done", false):
		_lines.append("廊下，沈戍仍提着棍。他没抬头，只低声道：「王爷走。门，俺看着。」")
	elif IssueManager.flags.get("shenliu_b1_done", false):
		_lines.append("廊下，沈戍的影子被灯笼拉得很长。那一碗粥换来的忠义，今夜替你看门。")
	if IssueManager.flags.get("kind_likely", false):
		_lines.append("你想起秋穗收信时的背影——私囊里少的那笔银子，此刻像压在胸口。")
	_lines.append("【中使】请。")
	_lines.append("你迈出门槛。回头时，信王府的暖黄还留在门内；再往前，只有冷青。")
	_lines.append("兄长把江山交到你手里，不是因为恩宠，是因为大明已经无人可继。")
	_lines.append("自此无回头。")

func _show_line() -> void:
	if _idx >= _lines.size():
		_finish()
		return
	IssueManager.night_council_active = true
	if overlay == null:
		overlay = CanvasLayer.new()
		add_child(overlay)
		var root := Control.new()
		root.name = "Root"
		root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		overlay.add_child(root)
		var dim := ColorRect.new()
		dim.color = Color(0.02, 0.02, 0.03, 0.88)
		dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(dim)
		var card := PanelContainer.new()
		card.name = "Card"
		card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		card.custom_minimum_size = Vector2(620, 340)
		var cs := StyleBoxFlat.new()
		cs.bg_color = Color(0.12, 0.1, 0.08, 0.97)
		cs.border_color = GOLD
		cs.border_width_left = 2
		cs.border_width_top = 2
		cs.border_width_right = 2
		cs.border_width_bottom = 2
		cs.corner_radius_top_left = 6
		cs.corner_radius_top_right = 6
		cs.corner_radius_bottom_left = 6
		cs.corner_radius_bottom_right = 6
		card.add_theme_stylebox_override("panel", cs)
		root.add_child(card)
		var vb := VBoxContainer.new()
		vb.name = "VBox"
		vb.add_theme_constant_override("separation", 12)
		vb.add_theme_constant_override("margin_left", 24)
		vb.add_theme_constant_override("margin_top", 24)
		vb.add_theme_constant_override("margin_right", 24)
		vb.add_theme_constant_override("margin_bottom", 24)
		card.add_child(vb)
		var title := Label.new()
		title.name = "Title"
		title.text = "夜召 · 兄崩入继"
		title.add_theme_font_size_override("font_size", 28)
		title.add_theme_color_override("font_color", GOLD)
		vb.add_child(title)
		vb.add_child(HSeparator.new())
		var body := Label.new()
		body.name = "Body"
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_theme_font_size_override("font_size", 17)
		body.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
		vb.add_child(body)
		var hint := Label.new()
		hint.name = "Hint"
		hint.text = "（按 E 继续）"
		hint.add_theme_font_size_override("font_size", 14)
		hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
		vb.add_child(hint)
	var body_lbl: Label = overlay.get_node("Root/Card/VBox/Body")
	body_lbl.text = _lines[_idx]
	_idx += 1
	set_process(true)

func _process(delta: float) -> void:
	_key_cd = max(0.0, _key_cd - delta)
	if _key_cd > 0.0:
		return
	if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER):
		_key_cd = 0.35
		_show_line()

func _finish() -> void:
	set_process(false)
	if overlay:
		overlay.queue_free()
		overlay = null
	IssueManager.night_council_active = false
	IssueManager.flags["act1_accession_done"] = true
	IssueManager.add_memory("MF_A1_NIGHT_SUMMON", 10, "夜召入宫——兄崩弟继，祖制只剩你这条路", "Ⅰ")
	accession_finished.emit()
