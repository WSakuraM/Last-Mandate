extends CharacterBody3D
# 玩家：信王（青年朱由检）。WASD 相对俯视相机方向移动。

var speed := 6.0

func _ready():
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.5
	shape.height = 1.6
	col.shape = shape
	add_child(col)

	var vis := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.5
	cm.height = 1.6
	vis.mesh = cm
	vis.position.y = -0.8
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.2, 0.3, 0.5)
	m.roughness = 0.8
	vis.material_override = m
	add_child(vis)

func _physics_process(_delta):
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
