extends CanvasLayer
# 夜召池空时的日常小事件 — 纸色夜话笺

signal dismissed()

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
	dim.color = Act1Theme.NIGHT_DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_top = 0.5
	card.anchor_right = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -280
	card.offset_right = 280
	card.offset_top = -160
	card.offset_bottom = 160
	card.add_theme_stylebox_override("panel", Act1Theme.night_card())
	root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	card.add_child(vb)

	var title := Label.new()
	title.text = v.get("title", "夜")
	Act1Theme.apply_label(title, Act1Theme.FONT_TITLE, Act1Theme.GOLD)
	vb.add_child(title)

	vb.add_child(Act1Theme.separator())

	var txt := Label.new()
	txt.text = v.get("text", "")
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Act1Theme.apply_label(txt, Act1Theme.FONT_BODY, Act1Theme.INK)
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "按 E 继续"
	Act1Theme.apply_label(hint, Act1Theme.FONT_HINT, Act1Theme.INK_FAINT)
	vb.add_child(hint)

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
