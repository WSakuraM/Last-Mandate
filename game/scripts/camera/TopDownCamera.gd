extends Node3D
# 等距 3D 经营相机：固定 45° 机位 + 平滑跟随 + 滚轮缩放。
# Shift+←/→ 才转视角，避免误触把等距感转乱。

var cam: Camera3D
var target: Node3D
var yaw := deg_to_rad(45.0)
var dist := 19.0
var elevation := deg_to_rad(51.0)
var _smooth_pos: Vector3
var _dist_cur := 19.0

const YAW_HOME := PI * 0.25
const DIST_HOME := 19.0
const DIST_MIN := 15.0
const DIST_MAX := 28.0

func _ready() -> void:
	cam = Camera3D.new()
	add_child(cam)
	cam.fov = 41.0
	cam.make_current()
	var t := get_tree().get_first_node_in_group("player")
	if t:
		target = t
		_smooth_pos = _desired_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			dist = clampf(dist - 1.2, DIST_MIN, DIST_MAX)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			dist = clampf(dist + 1.2, DIST_MIN, DIST_MAX)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		yaw = YAW_HOME
		dist = DIST_HOME
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_LEFT):
			yaw += delta * 1.0
		if Input.is_key_pressed(KEY_RIGHT):
			yaw -= delta * 1.0

func _physics_process(delta: float) -> void:
	if not target:
		return
	_dist_cur = lerpf(_dist_cur, dist, 1.0 - exp(-8.0 * delta))
	var look := target.global_position + Vector3(0, 1.0, 0)
	var desired := _desired_position_at(target.global_position)
	_smooth_pos = _smooth_pos.lerp(desired, 1.0 - exp(-9.0 * delta))
	cam.global_position = _smooth_pos
	cam.look_at(look, Vector3.UP)

func _desired_position() -> Vector3:
	return _desired_position_at(target.global_position)

func _desired_position_at(origin: Vector3) -> Vector3:
	var h_dist: float = cos(elevation) * _dist_cur
	var height: float = sin(elevation) * _dist_cur
	var offset := Vector3(sin(yaw), 0.0, cos(yaw)) * h_dist
	offset.y = height
	return origin + offset
