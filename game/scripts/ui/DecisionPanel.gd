extends CanvasLayer
# 夜召议题抉择面板（3D 俯视 UI 规范 §4）
# 用法：caller 调用 present(issue) 显示；玩家用 ↑↓ / W S / 1-9 / 鼠标 选择，
# Space / Enter 确认。确认后回调 IssueManager.apply_choice，并 emit choice_made。

signal choice_made(result: Dictionary)

var issue := {}
var selected := 0
var choice_buttons := []
var panel_root: Control
var active := false

const ZH := {
	"treasury": "国库", "popular": "民心", "frontier": "边军",
	"court": "朝堂", "resolve": "君心", "mandate_decay": "气数", "rebel_pressure": "民变",
}
const GOLD := Color(0.95, 0.8, 0.4)   # 暗金朱批高亮

func present(p_issue: Dictionary):
	issue = p_issue
	selected = 0
	active = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_show(true)
	IssueManager.night_council_active = true
	IssueManager.issue_presented.emit(issue)

func _build():
	if panel_root:
		panel_root.queue_free()
	panel_root = Control.new()
	panel_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel_root)

	# 压暗背景（夜召烛光聚焦前的暗场）
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_root.add_child(dim)

	# 议题卡
	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(580, 440)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.16, 0.13, 0.11, 0.96)
	cs.border_color = GOLD
	cs.border_width_left = 2; cs.border_width_top = 2
	cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6; cs.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", cs)
	panel_root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.add_theme_constant_override("margin_left", 20)
	vb.add_theme_constant_override("margin_top", 20)
	vb.add_theme_constant_override("margin_right", 20)
	vb.add_theme_constant_override("margin_bottom", 20)
	card.add_child(vb)

	var title := Label.new()
	title.text = "夜召 · " + issue.get("title", "")
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	var sum := Label.new()
	sum.text = issue.get("summary", "")
	sum.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sum.add_theme_font_size_override("font_size", 18)
	sum.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(sum)

	var sep := HSeparator.new()
	vb.add_child(sep)

	choice_buttons.clear()
	var chs: Array = issue.get("choices", [])
	for c in chs:
		var btn := Button.new()
		btn.text = _format(c)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(540, 56)
		btn.add_theme_font_size_override("font_size", 19)
		btn.pressed.connect(_on_click.bind(c["id"]))
		vb.add_child(btn)
		choice_buttons.append(btn)

	var hint := Label.new()
	hint.text = "↑↓ / W S 选择 · Space 朱批 · 鼠标亦可"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	_refresh()

func _format(c: Dictionary) -> String:
	var s: String = c.get("label", "")
	var d: Dictionary = c.get("deltas", {})
	var parts := []
	for k in d.keys():
		var zh: String = ZH.get(k, k)
		var v = d[k]
		var arrow := "↑" if v > 0 else ("↓" if v < 0 else "·")
		parts.append("%s%s%d" % [zh, arrow, v])
	if parts.size() > 0:
		s += "    [ " + ", ".join(parts) + " ]"
	return s

func _refresh():
	for i in choice_buttons.size():
		var b: Button = choice_buttons[i]
		if i == selected:
			b.add_theme_color_override("font_color", GOLD)
		else:
			b.remove_theme_color_override("font_color")

func _on_click(cid: String):
	_confirm(cid)

func _unhandled_key_input(event: InputEvent):
	if not active:
		return
	if event is InputEventKey and event.pressed:
		var kc: int = event.keycode
		if kc == KEY_UP or kc == KEY_W:
			selected = (selected - 1 + choice_buttons.size()) % choice_buttons.size()
			_refresh()
		elif kc == KEY_DOWN or kc == KEY_S:
			selected = (selected + 1) % choice_buttons.size()
			_refresh()
		elif kc == KEY_SPACE or kc == KEY_ENTER:
			_confirm(issue["choices"][selected]["id"])
		elif kc >= KEY_1 and kc <= KEY_9:
			var idx: int = kc - KEY_1
			if idx < issue["choices"].size():
				_confirm(issue["choices"][idx]["id"])

func _confirm(cid: String):
	if not active:
		return
	active = false
	var res := IssueManager.apply_choice(issue, cid)
	_show(false)
	if panel_root:
		panel_root.queue_free()
		panel_root = null
	IssueManager.night_council_active = false
	choice_made.emit(res)

func _show(v: bool):
	if panel_root:
		panel_root.visible = v
