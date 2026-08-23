extends Node3D
# 第一幕「人民疾苦」情感钩子：府门外流民老妪。
# 已迁移至对话系统：触发后通过 DialogueManager 播放 DLG_A1_REFUGEE。
# 回忆碎片（终章蒙太奇回收）由 DialogueManager 统一处理。

var shown := false

func _ready():
	# 老妪简模：佝偻身躯（前倾胶囊）+ 头巾 + 怀中孙儿
	var granny := MeshInstance3D.new()
	var gm := CapsuleMesh.new()
	gm.radius = 0.4
	gm.height = 0.9
	granny.mesh = gm
	granny.position.y = 0.45
	granny.rotation.x = 0.3   # 佝偻前倾
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(0.5, 0.44, 0.38)
	gmat.roughness = 1.0
	granny.material_override = gmat
	add_child(granny)

	var hood := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.26; hm.height = 0.5
	hood.mesh = hm
	hood.position = Vector3(0.0, 1.0, 0.12)
	var hmat := StandardMaterial3D.new()
	hmat.albedo_color = Color(0.4, 0.36, 0.32)
	hmat.roughness = 1.0
	hood.material_override = hmat
	add_child(hood)

	var child := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.2
	cm.height = 0.45
	child.mesh = cm
	child.position = Vector3(0.0, 0.32, 0.32)
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(0.62, 0.56, 0.5)
	cmat.roughness = 1.0
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
	# 通过对话系统播放（DialogueManager 自动锁世界输入 + 写入回忆碎片）
	EventBus.dialogue_request.emit("DLG_A1_REFUGEE")
