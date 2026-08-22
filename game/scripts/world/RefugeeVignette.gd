extends Node3D
# 第一幕「人民疾苦」情感钩子：府门外流民老妪。
# 玩家靠近触发一次性叙事卡，并写入回忆碎片（终章蒙太奇回收）。

const GOLD := Color(0.95, 0.8, 0.4)

var shown := false
var overlay: CanvasLayer

func _ready():
	# 老妪简模：佝偻身躯 + 怀中孙儿
	var granny := MeshInstance3D.new()
	var gm := CapsuleMesh.new()
	gm.radius = 0.42
	gm.height = 1.0
	granny.mesh = gm
	granny.position.y = 0.5
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(0.52, 0.46, 0.4)
	gmat.roughness = 1.0
	granny.material_override = gmat
	add_child(granny)

	var child := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.22
	cm.height = 0.5
	child.mesh = cm
	child.position = Vector3(0.0, 0.35, 0.3)
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(0.6, 0.55, 0.5)
	child.material_override = cmat
	add_child(child)

	# 触发区
	var area := Area3D.new()
	area.name = "RefugeeZone"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 3.2
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect(_on_enter)
	add_child(area)

	position = Vector3(0, 0, -27)   # 南墙内、府门附近

func _on_enter(b):
	if not b.is_in_group("player"):
		return
	if shown:
		return
	shown = true
	_show_card()

func _show_card():
	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(580, 250)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.15, 0.12, 0.1, 0.97)
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
	title.text = "府门外"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	var txt := Label.new()
	txt.text = "一位衣衫褴褛的老妪跪在雪泥里，怀中抱着枯瘦的孙儿，只是望着你。\n你才想起，还身为信王时，这京城之外的天下，早已千疮百孔。"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 18)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	# 写入回忆碎片（终章回收）
	var mid := "MF_A1_VIGNETTE_GRANNY"
	IssueManager.memories.append({"id": mid, "weight": 8, "text": "府门外，流民老妪怀中枯瘦的孙儿"})
	IssueManager.memory_added.emit(mid, 8)

	# 超时自动关闭（兜底）
	var t := Timer.new()
	t.wait_time = 7.0
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
	set_process(false)
