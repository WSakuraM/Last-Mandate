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

const ARRIVE_DIST := 0.42
const SLOW_DIST := 1.7

func _ready():
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	floor_stop_on_slope = false
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
	var m := MeshInstance3D.new()
	m.name = "ClickMarker"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.32
	torus.outer_radius = 0.46
	torus.rings = 8
	torus.ring_segments = 8
	m.mesh = torus
	m.rotation_degrees = Vector3(90, 0, 0)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.95, 0.82, 0.42, 0.0)
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
	if Input.is_key_pressed(KEY_W):
		wish.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		wish.z += 1.0
	if Input.is_key_pressed(KEY_A):
		wish.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		wish.x += 1.0

	# 鼠标点地改由 _unhandled_input 一次一令，避免按住拖行 + 镜头跟随把目标拖飞。

	# WASD 相对屏幕：W=画面上方（远离相机），S=画面下方。与相机 yaw 无关。
	if wish.length() > 0.01:
		_cancel_click_move()
		var cam := get_viewport().get_camera_3d()
		if cam:
			velocity = _screen_move_dir(cam, wish) * speed
		else:
			velocity = Vector3(wish.x, 0.0, wish.z).normalized() * speed
	elif _has_target:
		var to_target := _move_target - global_position
		to_target.y = 0.0
		var dist := to_target.length()
		if dist <= ARRIVE_DIST:
			_cancel_click_move()
			velocity = Vector3.ZERO
		else:
			var pace: float = speed
			if dist < SLOW_DIST:
				pace = speed * clampf(dist / SLOW_DIST, 0.22, 1.0)
			velocity = to_target / dist * pace
	else:
		velocity = Vector3.ZERO

	velocity.y = 0.0
	move_and_slide()

	var moving := velocity.length() > 0.1
	if moving:
		var yaw := atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, yaw, 1.0 - exp(-12.0 * delta))
		_bob_t += delta * 9.0
		_visual.position.y = sin(_bob_t) * 0.06
	else:
		_visual.position.y = lerp(_visual.position.y, 0.0, delta * 8.0)

	if _has_target and _marker:
		_marker.visible = true
		(_marker.material_override as StandardMaterial3D).albedo_color.a = 0.55 + 0.2 * sin(Time.get_ticks_msec() * 0.006)
		_marker.scale = Vector3.ONE * (1.0 + 0.06 * sin(Time.get_ticks_msec() * 0.008))

func _cancel_click_move() -> void:
	_has_target = false
	is_click_moving = false
	if _marker:
		_marker.visible = false

func _show_marker(pos: Vector3) -> void:
	_marker.global_position = Vector3(pos.x, 0.05, pos.z)
	_marker.visible = true
	(_marker.material_override as StandardMaterial3D).albedo_color.a = 0.75

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
	q.collide_with_bodies = true
	q.collide_with_areas = false
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

## 屏幕方向 → 地面方向。W/S 用画面上下，不是世界 ±Z。
func _screen_move_dir(cam: Camera3D, wish: Vector3) -> Vector3:
	var to_cam := cam.global_position - global_position
	to_cam.y = 0.0
	var down_on_screen := to_cam.normalized() if to_cam.length_squared() > 0.0001 else Vector3(0, 0, 1)
	var right_on_screen := Vector3.UP.cross(down_on_screen).normalized()
	var up_on_screen := -down_on_screen
	var dir := up_on_screen * (-wish.z) + right_on_screen * wish.x
	if dir.length_squared() < 0.0001:
		return Vector3.ZERO
	return dir.normalized()
