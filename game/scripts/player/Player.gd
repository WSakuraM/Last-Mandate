extends CharacterBody3D
# 玩家：信王（青年朱由检）。WASD + 鼠标左键点击地面移动；行走有轻微 bob。

var speed := 6.0
var _bob_t := 0.0
var _visual: Node3D
var _move_target: Vector3 = Vector3.ZERO
var _has_target := false

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

	# 鼠标左键点击地面 → 设置移动目标
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var ground_pos := _get_ground_click()
		if ground_pos != null:
			_move_target = ground_pos
			_has_target = true

	# WASD 优先；无键盘输入时走点击目标
	if d.length() > 0.01:
		_has_target = false   # 键盘输入取消点击目标
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
	elif _has_target:
		# 朝目标移动
		var to_target := _move_target - global_position
		to_target.y = 0
		var dist := to_target.length()
		if dist < 0.3:
			_has_target = false
			velocity = Vector3.ZERO
		else:
			velocity = to_target.normalized() * speed
	else:
		velocity = Vector3.ZERO

	move_and_slide()

	if velocity.length() > 0.1:
		var look_target := global_position + velocity
		look_at(look_target, Vector3.UP)
		_bob_t += delta * 9.0
		_visual.position.y = sin(_bob_t) * 0.06
	else:
		_visual.position.y = lerp(_visual.position.y, 0.0, delta * 8.0)

# 从鼠标位置射线检测地面点击点
func _get_ground_click() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return null
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse_pos)
	var ray_dir := cam.project_ray_normal(mouse_pos)
	# 地面 y=0 平面交点
	if abs(ray_dir.y) < 0.001:
		return null
	var t := -ray_origin.y / ray_dir.y
	if t < 0:
		return null
	var hit := ray_origin + ray_dir * t
	# 限制在院落范围内（±28）
	hit.x = clamp(hit.x, -28.0, 28.0)
	hit.z = clamp(hit.z, -28.0, 28.0)
	hit.y = 0.0
	return hit
