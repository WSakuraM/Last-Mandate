extends CanvasLayer
# 夜召议题抉择面板 — 纸色折子 + 朱批高亮

signal choice_made(result: Dictionary)

var issue := {}
var selected := 0
var choice_buttons := []
var panel_root: Control
var active := false

const ZH := {
	"treasury": "国库", "popular": "民心", "people": "民心",
	"frontier": "边军", "border_army": "边军",
	"court": "朝堂", "court_order": "朝堂",
	"resolve": "君心", "emperor_heart": "君心",
	"mandate_decay": "气数", "rebel_pressure": "民变",
}

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

	var dim := ColorRect.new()
	dim.color = Act1Theme.NIGHT_DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_top = 0.5
	card.anchor_right = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -300
	card.offset_right = 300
	card.offset_top = -220
	card.offset_bottom = 220
	card.add_theme_stylebox_override("panel", Act1Theme.night_card())
	panel_root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	card.add_child(vb)

	var title := Label.new()
	title.text = "夜召 · " + issue.get("title", "")
	Act1Theme.apply_label(title, Act1Theme.FONT_TITLE + 2, Act1Theme.VERMILLION)
	vb.add_child(title)

	var sum := Label.new()
	sum.text = issue.get("summary", "")
	sum.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Act1Theme.apply_label(sum, Act1Theme.FONT_BODY, Act1Theme.INK_MUTED)
	vb.add_child(sum)

	vb.add_child(Act1Theme.separator())

	choice_buttons.clear()
	var chs: Array = issue.get("choices", [])
	for c in chs:
		var btn := Button.new()
		btn.text = _format(c)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", Act1Theme.FONT_BODY)
		Act1Theme.apply_choice_button(btn)
		btn.pressed.connect(_on_click.bind(c["id"]))
		vb.add_child(btn)
		choice_buttons.append(btn)

	var hint := Label.new()
	hint.text = "↑↓ 择项 · 空格 朱批"
	Act1Theme.apply_label(hint, Act1Theme.FONT_HINT, Act1Theme.INK_FAINT)
	vb.add_child(hint)

	_refresh()

func _format(c: Dictionary) -> String:
	var s: String = c.get("label", "")
	var delta_line := Act1Theme.format_delta_line(c.get("deltas", {}), ZH)
	return s + delta_line

func _refresh():
	for i in choice_buttons.size():
		var b: Button = choice_buttons[i]
		if i == selected:
			b.add_theme_stylebox_override("normal", Act1Theme.choice_button_selected())
			b.add_theme_color_override("font_color", Act1Theme.VERMILLION)
		else:
			b.add_theme_stylebox_override("normal", Act1Theme.choice_button_normal())
			b.add_theme_color_override("font_color", Act1Theme.INK)

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
