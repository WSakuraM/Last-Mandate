extends CharacterBody3D
# 玩家：信王（青年朱由检）。WASD 相对画面；鼠标点一下地面走到该处（不按住拖）。

var speed := 6.0
var _bob_t := 0.0
var _visual: Node3D
var _move_target: Vector3 = Vector3.ZERO
var _has_target := false
var is_click_moving := false
var _marker: MeshInstance3D
var _dust: GPUParticles3D

const ARRIVE_DIST := 0.45
const WALL_COLLISION_LAYER := 1
const MOVE_ACCEL := 22.0

func _ready():
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	floor_stop_on_slope = false
	collision_layer = 2
	collision_mask = WALL_COLLISION_LAYER
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
	ph.position.y = -0.95
	ph.scale = Vector3(0.98, 0.92, 0.98)
	CourtyardVisuals.apply_toon_recursive(ph)
	_visual.add_child(ph)
	_add_ground_shadow()
	_marker = _make_marker()
	add_child(_marker)

func _unhandled_input(event: InputEvent) -> void:
	if IssueManager.night_council_active:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _try_click_talk():
			_cancel_click_move()
			get_viewport().set_input_as_handled()
			return
		var ground_pos: Variant = _get_ground_click()
		if ground_pos != null:
			_move_target = ground_pos as Vector3
			_has_target = true
			is_click_moving = true
			_show_marker(_move_target)
			get_viewport().set_input_as_handled()

func _add_ground_shadow() -> void:
	var shadow := MeshInstance3D.new()
	shadow.name = "GroundShadow"
	var disc := CylinderMesh.new()
	disc.top_radius = 0.58
	disc.bottom_radius = 0.58
	disc.height = 0.03
	shadow.mesh = disc
	shadow.position = Vector3(0, -0.97, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0, 0, 0.32)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow.material_override = mat
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shadow)

func _make_dust() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "FootDust"
	p.amount = 6
	p.lifetime = 0.45
	p.emitting = false
	p.position = Vector3(0, 0.08, 0)
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 70.0
	mat.initial_velocity_min = 0.2
	mat.initial_velocity_max = 0.6
	mat.gravity = Vector3(0, -0.4, 0)
	mat.scale_min = 0.04
	mat.scale_max = 0.09
	mat.color = Color(0.62, 0.52, 0.38, 0.35)
	p.process_material = mat
	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.08
	p.draw_pass_1 = mesh
	return p

func _make_marker() -> MeshInstance3D:
	# 点地落点环（俯视是淡色圆环，不是箭头；走近后自动淡出）
	var m := MeshInstance3D.new()
	m.name = "ClickMarker"
	var disc := CylinderMesh.new()
	disc.top_radius = 0.36
	disc.bottom_radius = 0.36
	disc.height = 0.025
	m.mesh = disc
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.72, 0.88, 0.76, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.visible = false
	m.top_level = true
	return m

func _physics_process(delta):
	if IssueManager.night_council_active:
		_cancel_click_move()
		velocity = Vector3.ZERO
		if _dust:
			_dust.emitting = false
		move_and_slide()
		return

	var wish := Vector3.ZERO
	var target_vel := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		wish.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		wish.z += 1.0
	if Input.is_key_pressed(KEY_A):
		wish.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		wish.x += 1.0

	# 鼠标点地改由 _unhandled_input 一次一令，避免按住拖行 + 镜头跟随把目标拖飞。

	# WASD：用相机 basis 取水平方向（比「人→相机」向量稳，镜头跟随不会扯动移动轴）
	if wish.length() > 0.01:
		_cancel_click_move()
		var cam := get_viewport().get_camera_3d()
		if cam:
			target_vel = _screen_move_dir(cam, wish) * speed
		else:
			target_vel = Vector3(wish.x, 0.0, wish.z).normalized() * speed
	elif _has_target:
		var to_target := _move_target - global_position
		to_target.y = 0.0
		var dist := to_target.length()
		if dist <= ARRIVE_DIST:
			_cancel_click_move()
			target_vel = Vector3.ZERO
		else:
			# 全程匀速，不做贴目标减速（减速易抖）
			target_vel = to_target / dist * speed
	else:
		target_vel = Vector3.ZERO

	velocity = velocity.lerp(target_vel, 1.0 - exp(-MOVE_ACCEL * delta))
	velocity.y = 0.0
	move_and_slide()

	var moving := velocity.length() > 0.2
	if moving:
		var yaw := atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, yaw, 1.0 - exp(-14.0 * delta))
		_bob_t += delta * 7.0
		_visual.position.y = sin(_bob_t) * 0.03
	else:
		_visual.position.y = lerp(_visual.position.y, 0.0, delta * 10.0)

	if _has_target and _marker and _marker.visible:
		var to_m := _move_target - global_position
		to_m.y = 0.0
		var fade := clampf(to_m.length() / 2.2, 0.0, 1.0)
		var mat := _marker.material_override as StandardMaterial3D
		mat.albedo_color.a = 0.15 + 0.35 * fade
		_marker.global_position = Vector3(_move_target.x, 0.04, _move_target.z)

func _cancel_click_move() -> void:
	_has_target = false
	is_click_moving = false
	if _marker:
		_marker.visible = false

func _show_marker(pos: Vector3) -> void:
	_marker.global_position = Vector3(pos.x, 0.04, pos.z)
	_marker.visible = true
	(_marker.material_override as StandardMaterial3D).albedo_color.a = 0.5

## 先打 layer 2 的问号碰撞；点中则触发对话/照料，不走路。
func _try_click_talk() -> bool:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return false
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := cam.project_ray_origin(mouse_pos)
	var dir := cam.project_ray_normal(mouse_pos)
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * 120.0)
	q.collision_mask = InteractMark.CLICK_LAYER
	q.collide_with_bodies = false
	q.collide_with_areas = true
	var hit: Dictionary = space.intersect_ray(q)
	if hit.is_empty():
		return false
	var n: Node = hit.get("collider") as Node
	while n:
		if n.has_method("on_click_talk"):
			return bool(n.call("on_click_talk"))
		n = n.get_parent()
	return false

# 从鼠标位置射线检测地面点击点（返回 Vector3 或 null）
func _get_ground_click():
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
	# 井有体积：点在井心上时改走到井沿，避免对着模型绕圈
	var well := CourtyardLayout.WELL
	var to_well := Vector3(hit.x - well.x, 0.0, hit.z - well.z)
	if to_well.length() < 1.8:
		if to_well.length() < 0.05:
			to_well = Vector3(0, 0, 1)
		hit = well + to_well.normalized() * 2.1
		hit.y = 0.0
	return hit

## 屏幕方向 → 地面方向：取相机水平 basis，与镜头平滑解耦。
func _screen_move_dir(cam: Camera3D, wish: Vector3) -> Vector3:
	var basis := cam.global_transform.basis
	var right := Vector3(basis.x.x, 0.0, basis.x.z)
	var forward := Vector3(-basis.z.x, 0.0, -basis.z.z)
	if right.length_squared() < 0.0001:
		right = Vector3.RIGHT
	else:
		right = right.normalized()
	if forward.length_squared() < 0.0001:
		forward = Vector3(0, 0, -1)
	else:
		forward = forward.normalized()
	var dir := forward * (-wish.z) + right * wish.x
	if dir.length_squared() < 0.0001:
		return Vector3.ZERO
	return dir.normalized()
