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

	# 信王 M1 占位模型（规范资产，后续可换精模不改代码）
	var ph: Node3D = preload("res://assets/models/characters/xinwang_m1.tscn").instantiate()
	ph.position.y = -1.0   # 落地对齐（CharacterBody3D 原点在中心）
	_visual.add_child(ph)

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
