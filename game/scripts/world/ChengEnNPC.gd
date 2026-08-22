extends Node3D
# 王承恩：第一幕情感锚。信王时期的随侍太监，立于夜召堂前。
# 玩家靠近时显示提示，不阻塞主玩法，本身不可交互推进（只做氛围与叙事锚点）。

var near := false

func _ready():
	# 暗褐长袍（圆柱身 + 略收的底座）
	var body := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.35
	bm.bottom_radius = 0.5
	bm.height = 1.5
	body.mesh = bm
	body.position.y = 0.75
	var bmat := StandardMaterial3D.new()
	bmat.albedo_color = Color(0.3, 0.26, 0.22)
	bmat.roughness = 0.9
	body.material_override = bmat
	add_child(body)

	# 头（净面，微暗）
	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.22
	hm.height = 0.44
	head.mesh = hm
	head.position.y = 1.7
	var hmat := StandardMaterial3D.new()
	hmat.albedo_color = Color(0.6, 0.52, 0.45)
	hmat.roughness = 0.85
	head.material_override = hmat
	add_child(head)

	# 触发区
	var area := Area3D.new()
	area.name = "ChengEnZone"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 3.0
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)
	add_child(area)

func _on_enter(b):
	if b.is_in_group("player"):
		near = true
		EventBus.interact_prompt.emit("王承恩随侍在侧，垂手而立")

func _on_exit(b):
	if b.is_in_group("player"):
		near = false
		EventBus.interact_hide.emit()
