extends CanvasLayer
# 对话演出框：打字机效果 + 多行推进 + 可选分支。
# 由 DialogueManager 实例化并调用 present()。
# 视觉风格与现有叙事卡片一致（GOLD 边框 + 暗底），但增加了：
#   - 说话人名称标签
#   - RichTextLabel 打字机效果（visible_characters）
#   - 多行推进（E / Space / 点击 推进到下一行）
#   - 选择分支按钮

signal dialogue_complete(id: String, result: Dictionary)

const GOLD := Color(0.95, 0.8, 0.4)
const TYPEWRITER_SPEED := 0.03   # 每字符间隔（秒）

var _data: Dictionary = {}
var _line_idx: int = 0
var _phase: String = "typing"   # typing / waiting / choices / feedback
var _type_timer: float = 0.0
var _text_label: RichTextLabel
var _name_label: Label
var _hint_label: Label
var _choice_container: VBoxContainer
var _key_cd: float = 0.0
var _chosen_data: Dictionary = {}   # 选中分支的回调数据
var _card: PanelContainer

func present(data: Dictionary):
	_data = data
	_line_idx = 0
	_type_timer = 0.0
	_phase = "typing"
	_chosen_data = {}
	_build_ui()
	_show_line(0)

# ── UI 构建 ──

func _build_ui():
	# 半透明遮罩
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	# 卡片面板（与现有叙事卡片一致的 GOLD 边框风格）
	_card = PanelContainer.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_card.custom_minimum_size = Vector2(580, 280)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.15, 0.12, 0.1, 0.97)
	cs.border_color = GOLD
	cs.border_width_left = 2; cs.border_width_top = 2
	cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6; cs.corner_radius_bottom_right = 6
	cs.content_margin_left = 22; cs.content_margin_top = 22
	cs.content_margin_right = 22; cs.content_margin_bottom = 22
	_card.add_theme_stylebox_override("panel", cs)
	root.add_child(_card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	_card.add_child(vb)

	# 标题（对话标题）
	var title_text: String = _data.get("title", "")
	if title_text != "":
		var title := Label.new()
		title.text = title_text
		title.add_theme_font_size_override("font_size", 24)
		title.add_theme_color_override("font_color", GOLD)
		vb.add_child(title)

	# 说话人名称
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 18)
	_name_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.55))
	vb.add_child(_name_label)

	# 对话正文（RichTextLabel 支持打字机效果）
	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = true
	_text_label.fit_content = true
	_text_label.custom_minimum_size = Vector2(530, 80)
	_text_label.add_theme_font_size_override("normal_font_size", 18)
	_text_label.add_theme_color_override("default_color", Color(0.85, 0.82, 0.78))
	vb.add_child(_text_label)

	# 选项容器（默认隐藏）
	_choice_container = VBoxContainer.new()
	_choice_container.add_theme_constant_override("separation", 6)
	_choice_container.visible = false
	vb.add_child(_choice_container)

	# 提示文字
	_hint_label = Label.new()
	_hint_label.text = "（按 E / 空格 继续）"
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(_hint_label)

# ── 行显示 ──

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
	_name_label.text = line.get("speaker", "")
	var text: String = line.get("text", "")
	# 旁白用斜体标记
	var emotion: String = line.get("emotion", "")
	if emotion == "narration":
		_text_label.text = "[i]%s[/i]" % text
	else:
		_text_label.text = text
	_text_label.visible_characters = 0
	_type_timer = 0.0
	_phase = "typing"
	_hint_label.visible = false

# ── 输入处理 ──

func _process(delta):
	_key_cd = max(0.0, _key_cd - delta)
	var advance_pressed := _key_cd <= 0.0 and _is_advance_key()

	match _phase:
		"typing":
			_type_timer += delta
			var chars_to_show := int(_type_timer / TYPEWRITER_SPEED)
			_text_label.visible_characters = chars_to_show
			if _text_label.visible_characters >= _text_label.get_total_character_count():
				_phase = "waiting"
				_hint_label.visible = true
			# 按键跳过打字机（直接显示全部）
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

# ── 选项分支 ──

func _show_choices():
	_phase = "choices"
	_hint_label.text = "（按数字键或点击选择）"
	_hint_label.visible = true
	_choice_container.visible = true
	var choices: Array = _data.get("choices", [])
	for i in choices.size():
		var c: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, c.get("label", "")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(0.12, 0.1, 0.08, 0.9)
		btn_style.border_color = Color(0.5, 0.45, 0.35)
		btn_style.border_width_left = 1; btn_style.border_width_top = 1
		btn_style.border_width_right = 1; btn_style.border_width_bottom = 1
		btn_style.corner_radius_top_left = 4; btn_style.corner_radius_top_right = 4
		btn_style.corner_radius_bottom_left = 4; btn_style.corner_radius_bottom_right = 4
		btn_style.content_margin_left = 12; btn_style.content_margin_top = 6
		btn_style.content_margin_right = 12; btn_style.content_margin_bottom = 6
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_choice.bind(i))
		_choice_container.add_child(btn)

func _on_choice(idx: int):
	var choices: Array = _data.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return
	var c: Dictionary = choices[idx]
	_chosen_data = c
	# 清除选项按钮
	for child in _choice_container.get_children():
		child.queue_free()
	_choice_container.visible = false
	# 显示选择后反馈行
	var lines_after: Array = c.get("lines_after", [])
	if lines_after.size() > 0:
		_data["lines"] = lines_after
		_line_idx = 0
		_type_timer = 0.0
		_hint_label.text = "（按 E / 空格 继续）"
		_show_line(0)
	else:
		_complete_with_choice()

# ── 完成 ──

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
