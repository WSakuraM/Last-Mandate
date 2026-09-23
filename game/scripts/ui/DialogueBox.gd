extends CanvasLayer
# 对话演出框：底栏纸色面板 + 打字机 + 分支（Act1Theme）

signal dialogue_complete(id: String, result: Dictionary)

const TYPEWRITER_SPEED := 0.028
const PANEL_WIDTH := 680.0
const PANEL_BOTTOM := 36.0

var _data: Dictionary = {}
var _line_idx: int = 0
var _phase: String = "typing"
var _type_timer: float = 0.0
var _text_label: RichTextLabel
var _name_label: Label
var _hint_label: Label
var _choice_container: VBoxContainer
var _key_cd: float = 0.0
var _chosen_data: Dictionary = {}
var _card: PanelContainer
var _body_vb: VBoxContainer

func present(data: Dictionary):
	_data = data
	_line_idx = 0
	_type_timer = 0.0
	_phase = "typing"
	_chosen_data = {}
	_build_ui()
	_show_line(0)

func _build_ui():
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# 底缘轻压暗（随面板宽度，不铺满全屏）
	var dim := ColorRect.new()
	dim.color = Color(0.06, 0.04, 0.03, 0.32)
	dim.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dim.anchor_left = 0.5
	dim.anchor_top = 1.0
	dim.anchor_right = 0.5
	dim.anchor_bottom = 1.0
	dim.offset_left = -PANEL_WIDTH * 0.5 - 12.0
	dim.offset_right = PANEL_WIDTH * 0.5 + 12.0
	dim.offset_top = -210.0
	dim.offset_bottom = -PANEL_BOTTOM + 8.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)

	# 底栏对话面板（居中收窄，非全宽）
	_card = PanelContainer.new()
	_card.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_card.anchor_left = 0.5
	_card.anchor_top = 1.0
	_card.anchor_right = 0.5
	_card.anchor_bottom = 1.0
	_card.offset_left = -PANEL_WIDTH * 0.5
	_card.offset_right = PANEL_WIDTH * 0.5
	_card.offset_top = -196.0
	_card.offset_bottom = -PANEL_BOTTOM
	_card.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	var panel_style := Act1Theme.paper_panel(0.96, 10)
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 18
	panel_style.content_margin_bottom = 16
	_card.add_theme_stylebox_override("panel", panel_style)
	root.add_child(_card)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	_card.add_child(outer)

	var title_text: String = _data.get("title", "")
	if title_text != "":
		var title := Label.new()
		title.text = title_text
		Act1Theme.apply_label(title, Act1Theme.FONT_TITLE, Act1Theme.GOLD)
		outer.add_child(title)
		outer.add_child(Act1Theme.separator())

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	outer.add_child(header)

	var name_wrap := PanelContainer.new()
	name_wrap.add_theme_stylebox_override("panel", Act1Theme.speaker_tag())
	name_wrap.custom_minimum_size = Vector2(88, 0)
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Act1Theme.apply_label(_name_label, Act1Theme.FONT_SMALL, Act1Theme.PAPER)
	name_wrap.add_child(_name_label)
	header.add_child(name_wrap)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 8)
	header.add_child(text_col)

	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = true
	_text_label.fit_content = true
	_text_label.scroll_active = false
	_text_label.custom_minimum_size = Vector2(PANEL_WIDTH - 140.0, 64)
	_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text_label.add_theme_font_size_override("normal_font_size", Act1Theme.FONT_BODY)
	_text_label.add_theme_color_override("default_color", Act1Theme.INK)
	text_col.add_child(_text_label)

	_body_vb = VBoxContainer.new()
	_body_vb.add_theme_constant_override("separation", 6)
	outer.add_child(_body_vb)

	_choice_container = VBoxContainer.new()
	_choice_container.add_theme_constant_override("separation", 6)
	_choice_container.visible = false
	_body_vb.add_child(_choice_container)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	outer.add_child(footer)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	_hint_label = Label.new()
	_hint_label.text = "按 E 或 空格 继续"
	Act1Theme.apply_label(_hint_label, Act1Theme.FONT_HINT, Act1Theme.INK_MUTED)
	_hint_label.add_theme_color_override("font_outline_color", Color(Act1Theme.PAPER.r, Act1Theme.PAPER.g, Act1Theme.PAPER.b, 0.6))
	_hint_label.add_theme_constant_override("outline_size", 2)
	footer.add_child(_hint_label)

func _show_line(idx: int):
	if idx >= _data.get("lines", []).size():
		if _data.get("choices", []).size() > 0:
			_show_choices()
		elif not _chosen_data.is_empty():
			_complete_with_choice()
		else:
			_complete()
		return
	var line: Dictionary = _data["lines"][idx]
	var speaker: String = line.get("speaker", "")
	_name_label.text = speaker if speaker != "" else "　"
	var text: String = line.get("text", "")
	var emotion: String = line.get("emotion", "")
	if emotion == "narration":
		_text_label.text = "[i][color=#6a5848]%s[/color][/i]" % text
		_name_label.text = "旁白"
	else:
		_text_label.text = text
	_text_label.visible_characters = 0
	_type_timer = 0.0
	_phase = "typing"
	_hint_label.visible = false

func _process(delta):
	_key_cd = max(0.0, _key_cd - delta)
	var advance_pressed := _key_cd <= 0.0 and _is_advance_key()

	if _phase == "choices":
		if _key_cd <= 0.0:
			for i in 9:
				if Input.is_key_pressed(KEY_1 + i):
					var choices: Array = _data.get("choices", [])
					if i < choices.size():
						_key_cd = 0.25
						_on_choice(i)
						return
		return

	match _phase:
		"typing":
			_type_timer += delta
			var chars_to_show := int(_type_timer / TYPEWRITER_SPEED)
			_text_label.visible_characters = chars_to_show
			if _text_label.visible_characters >= _text_label.get_total_character_count():
				_phase = "waiting"
				_hint_label.visible = true
			if advance_pressed:
				_key_cd = 0.25
				_text_label.visible_characters = -1
				_phase = "waiting"
				_hint_label.visible = true
		"waiting":
			if advance_pressed:
				_key_cd = 0.25
				_line_idx += 1
				_type_timer = 0.0
				_show_line(_line_idx)

func _is_advance_key() -> bool:
	return Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)

func _show_choices():
	_phase = "choices"
	_hint_label.text = "数字键或点击选择"
	_hint_label.visible = true
	if bool(_data.get("show_purse", false)):
		var pl := Label.new()
		pl.text = "私囊结余 · %.0f 兩" % ResourceManager.private_purse
		Act1Theme.apply_label(pl, Act1Theme.FONT_SMALL, Act1Theme.BRONZE)
		_choice_container.add_child(pl)
	_choice_container.visible = true
	var choices: Array = _data.get("choices", [])
	for i in choices.size():
		var c: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = "%d · %s" % [i + 1, c.get("label", "")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		Act1Theme.apply_choice_button(btn)
		btn.add_theme_font_size_override("font_size", Act1Theme.FONT_BODY)
		btn.pressed.connect(_on_choice.bind(i))
		_choice_container.add_child(btn)

func _on_choice(idx: int):
	var choices: Array = _data.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return
	var c: Dictionary = choices[idx]
	var min_p: float = float(c.get("min_purse", 0.0))
	if min_p > 0.0 and ResourceManager.private_purse < min_p:
		var msg: String = str(c.get("insufficient_msg", "私囊不足 %.0f 两，无力照此办理。" % min_p))
		EventBus.narration.emit(msg)
		return
	_chosen_data = c
	_data["choices"] = []
	for child in _choice_container.get_children():
		child.queue_free()
	_choice_container.visible = false
	var lines_after: Array = c.get("lines_after", [])
	if lines_after.size() > 0:
		_data["lines"] = lines_after
		_line_idx = 0
		_type_timer = 0.0
		_hint_label.text = "按 E 或 空格 继续"
		_show_line(0)
	else:
		_complete_with_choice()

func _complete():
	var result := {
		"id": _data.get("id", ""),
		"on_complete": _data.get("on_complete", {}),
	}
	dialogue_complete.emit(_data.get("id", ""), result)

func _complete_with_choice():
	var result := {
		"id": _data.get("id", ""),
		"choice": _chosen_data.get("id", ""),
		"on_complete": {
			"resource_deltas": _chosen_data.get("deltas", {}),
			"flags_add": _chosen_data.get("flags_add", []),
			"memory": _chosen_data.get("memory", {}),
		}
	}
	dialogue_complete.emit(_data.get("id", ""), result)
