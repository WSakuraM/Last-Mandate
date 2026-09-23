extends Node3D
# 第一幕「人民疾苦」情感钩子：府门外流民老妪。
# 头顶问号，点击后播放 DLG_A1_REFUGEE（走近不再自动弹）。
# 回忆碎片（终章蒙太奇回收）由 DialogueManager 统一处理。

func _ready():
	var granny := MeshInstance3D.new()
	var gm := CapsuleMesh.new()
	gm.radius = 0.4
	gm.height = 0.9
	granny.mesh = gm
	granny.position.y = 0.45
	granny.rotation.x = 0.3
	CourtyardVisuals.apply_toon(granny, Color(0.5, 0.44, 0.38), Color(0.32, 0.28, 0.22))
	add_child(granny)

	var hood := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.26
	hm.height = 0.5
	hood.mesh = hm
	hood.position = Vector3(0.0, 1.0, 0.12)
	CourtyardVisuals.apply_toon(hood, Color(0.4, 0.36, 0.32), Color(0.28, 0.24, 0.20))
	add_child(hood)

	var child := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.2
	cm.height = 0.45
	child.mesh = cm
	child.position = Vector3(0.0, 0.32, 0.32)
	CourtyardVisuals.apply_toon(child, Color(0.62, 0.56, 0.5), Color(0.42, 0.36, 0.30))
	add_child(child)

	position = CourtyardLayout.REFUGEE
	InteractMark.bind(self, "DLG_A1_REFUGEE", 1.75, true, 0.85, "near", false)
