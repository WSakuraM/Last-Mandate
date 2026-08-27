extends Node
class_name IdlePresence
# 占位角色轻微起伏，靠近玩家时转身看人。挂在角色根节点上。

var amplitude := 0.035
var look_range := 9.0
var _t := 0.0
var _base_y := 0.0

func _ready() -> void:
	_t = randf() * 12.0
	var p := get_parent() as Node3D
	if p:
		_base_y = p.position.y

func _process(delta: float) -> void:
	var p := get_parent() as Node3D
	if p == null:
		return
	_t += delta
	p.position.y = _base_y + sin(_t * 1.65 + float(get_instance_id() % 7)) * amplitude
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var to := player.global_position - p.global_position
	to.y = 0.0
	var dist := to.length()
	if dist < look_range and dist > 0.25:
		var target_yaw := atan2(to.x, to.z)
		p.rotation.y = lerp_angle(p.rotation.y, target_yaw, 1.0 - exp(-2.2 * delta))
