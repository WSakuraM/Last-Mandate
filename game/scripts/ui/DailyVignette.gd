extends CanvasLayer
# 区块二·日常小事件：夜召池空时（6 次空窗期）的轻量填充。
# 不占决策、不抢戏，只填时间——街坊寒暄/天气/承恩随口一句/市井见闻。
# 玩家按 E 或 5 秒后自动消失，世界恢复运转。

signal dismissed()

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _vignettes := [
	{
		"title": "夜·无议",
		"text": "今夜无人来报事。院中虫声断续，远处巷子里传来犬吠，一声接一声。\n王承恩添了回灯油，低声道：「王爷，早些歇吧。」",
	},
	{
		"title": "天象",
		"text": "入夜，天边压着厚云，像是要落雨。\n你站在廊下看了一阵，终究没有落下来。",
	},
	{
		"title": "市井",
		"text": "吴伯从外头回来，叹了口气：「今日米价又涨了三成。城中已有抢米的了。」\n你沉默片刻，只说：「明日去看看菜畦。」",
	},
	{
		"title": "街坊",
		"text": "东巷的张屠户送了块肉来，说是谢王爷去年帮衬。\n你让吴伯收下，又让回送一篮菜去。",
	},
	{
		"title": "秋声",
		"text": "起了风，院里那株枣树叶子落了一地。\n承恩扫了半天，你站在旁边看，忽然觉得日子过得真慢。",
	},
	{
		"title": "旧学",
		"text": "你想起幼时宫中先生讲的一句：民为邦本，本固邦宁。\n那时不懂，现在站在这小院里，好像懂了一点，又好像更不懂了。",
	},
	{
		"title": "邸报",
		"text": "承恩说今日有京中邸报，翻了半天，没什么要紧的。\n「辽东还在打，陕西又报了旱。」他低声说，不敢看你。",
	},
	{
		"title": "灯下",
		"text": "夜很静，静得能听见自己心跳。\n烛芯爆了一下，承恩赶紧来剪。你摆摆手，由它去。\n——这院子里，好歹还有个人守着。",
	},
]

func _ready():
	pass

func present():
	IssueManager.night_council_active = true
	_show_vignette(_vignettes[randi() % _vignettes.size()])

func _show_vignette(v: Dictionary):
	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(520, 200)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.14, 0.11, 0.09, 0.96)
	cs.border_color = GOLD
	cs.border_width_left = 1; cs.border_width_top = 1
	cs.border_width_right = 1; cs.border_width_bottom = 1
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6; cs.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", cs)
	root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.add_theme_constant_override("margin_left", 22)
	vb.add_theme_constant_override("margin_top", 20)
	vb.add_theme_constant_override("margin_right", 22)
	vb.add_theme_constant_override("margin_bottom", 20)
	card.add_child(vb)

	var title := Label.new()
	title.text = v.get("title", "夜")
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = v.get("text", "")
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.82, 0.79, 0.74))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.55, 0.53, 0.5))
	vb.add_child(hint)

	# 超时自动关闭（兜底）
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
	dismissed.emit()
	set_process(false)
