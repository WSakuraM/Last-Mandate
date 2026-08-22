extends CharacterBody3D
# 玩家：信王（青年朱由检）。WASD 相对俯视相机方向移动；行走有轻微 bob。

var speed := 6.0
var _bob_t := 0.0
var _visual: Node3D

func _ready():
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.5
	shape.height = 1.6
	col.shape = shape
	add_child(col)

	# 可视组（用于 bob，不随碰撞体）
	_visual = Node3D.new()
	add_child(_visual)

	# 暗金常服（上窄下宽的袍身）
	var robe := MeshInstance3D.new()
	var rm := CylinderMesh.new()
	rm.top_radius = 0.32
	rm.bottom_radius = 0.52
	rm.height = 1.5
	robe.mesh = rm
	robe.position.y = 0.75
	var rmat := StandardMaterial3D.new()
	rmat.albedo_color = Color(0.45, 0.34, 0.16)   # 赭石暗金
	rmat.roughness = 0.85
	robe.material_override = rmat
	_visual.add_child(robe)

	# 头
	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.24
	hm.height = 0.46
	head.mesh = hm
	head.position.y = 1.72
	var hmat := StandardMaterial3D.new()
	hmat.albedo_color = Color(0.72, 0.62, 0.52)
	hmat.roughness = 0.8
	head.material_override = hmat
	_visual.add_child(head)

	# 冠（暗金小方，示意翼善冠）
	var crown := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.34, 0.16, 0.34)
	crown.mesh = cm
	crown.position.y = 1.98
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(0.6, 0.5, 0.2)
	cmat.metallic = 0.4
	cmat.roughness = 0.5
	crown.material_override = cmat
	_visual.add_child(crown)

func _physics_process(delta):
	if IssueManager.night_council_active:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	var d := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): d.z -= 1
	if Input.is_key_pressed(KEY_S): d.z += 1
	if Input.is_key_pressed(KEY_A): d.x -= 1
	if Input.is_key_pressed(KEY_D): d.x += 1
	d = d.normalized()

	var cam := get_viewport().get_camera_3d()
	if cam:
		var fwd := -cam.global_transform.basis.z
		fwd.y = 0
		fwd = fwd.normalized()
		var right := cam.global_transform.basis.x
		right.y = 0
		right = right.normalized()
		velocity = (fwd * d.z + right * d.x) * speed
	else:
		velocity = d * speed

	move_and_slide()

	if velocity.length() > 0.1:
		var look_target := global_position + velocity
		look_at(look_target, Vector3.UP)
		_bob_t += delta * 9.0
		_visual.position.y = sin(_bob_t) * 0.06
	else:
		_visual.position.y = lerp(_visual.position.y, 0.0, delta * 8.0)
