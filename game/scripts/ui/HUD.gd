extends CanvasLayer
# 3D 俯视 HUD：五资源条 + 气数 + 年/季/日 + 交互提示。

var bars := {}
var mandate_bar: ProgressBar
var mandate_fill: StyleBoxFlat
var mandate_warning: Label
var info_label: Label
var prompt_label: Label
var memory_label: Label

func _ready():
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var vb := VBoxContainer.new()
	vb.position = Vector2(16, 16)
	root.add_child(vb)

	var names := {
		"treasury": "国库", "people": "民心", "border_army": "边军",
		"court_order": "朝堂秩序", "emperor_heart": "君心"
	}
	for key in names.keys():
		var hb := HBoxContainer.new()
		var lab := Label.new()
		lab.text = names[key]
		lab.custom_minimum_size = Vector2(90, 0)
		var bar := ProgressBar.new()
		bar.max_value = 100.0
		bar.value = 50.0
		bar.custom_minimum_size = Vector2(180, 18)
		hb.add_child(lab)
		hb.add_child(bar)
		vb.add_child(hb)
		bars[key] = bar

	mandate_bar = ProgressBar.new()
	mandate_bar.max_value = 100.0
	mandate_bar.value = 12.0
	mandate_bar.custom_minimum_size = Vector2(260, 18)
	mandate_fill = StyleBoxFlat.new()
	mandate_fill.bg_color = _mandate_color(12.0)
	mandate_bar.add_theme_stylebox_override("fill", mandate_fill)
	var mh := HBoxContainer.new()
	var ml := Label.new()
	ml.text = "天命"
	ml.custom_minimum_size = Vector2(90, 0)
	mh.add_child(ml)
	mh.add_child(mandate_bar)
	vb.add_child(mh)

	# 锁底指示：气数永不低于 4，此标记不可擦除
	var lock_label := Label.new()
	lock_label.text = "▎锁底 4 · 不可清零"
	lock_label.add_theme_font_size_override("font_size", 11)
	lock_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
	vb.add_child(lock_label)

	# 气数高时的暗色警示
	mandate_warning = Label.new()
	mandate_warning.text = ""
	mandate_warning.add_theme_color_override("font_color", Color(0.55, 0.2, 0.18))
	mandate_warning.add_theme_font_size_override("font_size", 14)
	vb.add_child(mandate_warning)

	info_label = Label.new()
	info_label.text = ""
	vb.add_child(info_label)

	memory_label = Label.new()
	memory_label.text = "回忆碎片 ×0"
	memory_label.add_theme_color_override("font_color", Color(0.7, 0.6, 0.4))
	vb.add_child(memory_label)

	prompt_label = Label.new()
	prompt_label.text = ""
	prompt_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt_label.offset_left = 16
	prompt_label.offset_right = -16
	prompt_label.offset_bottom = -16
	root.add_child(prompt_label)

	ResourceManager.resources_changed.connect(_on_res)
	ResourceManager.mandate_changed.connect(_on_man)
	EventBus.interact_prompt.connect(_on_prompt)
	EventBus.interact_hide.connect(_on_hide)
	IssueManager.memory_added.connect(_on_memory)

func _on_res(s: Dictionary):
	for k in bars:
		bars[k].value = s[k]
	info_label.text = "年 %d · 第 %d 日 · 季 %d" % [s.year, s.day, s.season]

func _on_man(v: float):
	mandate_bar.value = v
	mandate_fill.bg_color = _mandate_color(v)
	if v >= 70.0:
		mandate_warning.text = "你救不了这座江山"
	else:
		mandate_warning.text = ""

func _mandate_color(v: float) -> Color:
	if v < 30.0:
		return Color(0.7, 0.6, 0.35)   # 暗金：天命尚存
	elif v < 70.0:
		return Color(0.8, 0.4, 0.2)    # 橙红：衰势渐显
	else:
		return Color(0.6, 0.15, 0.12)  # 深红：气数将尽

func _on_prompt(t: String):
	prompt_label.text = t

func _on_hide():
	prompt_label.text = ""

func _on_memory(_id: String, _weight: int):
	memory_label.text = "回忆碎片 ×%d" % IssueManager.memories.size()
