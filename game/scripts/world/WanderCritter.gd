extends Node3D
class_name WanderCritter
# 畜栏小鸡：在出生点附近踱步。

var radius := 2.1
var speed := 0.55
var _home := Vector3.ZERO
var _goal := Vector3.ZERO
var _pause := 0.0

func _ready() -> void:
	_home = position
	_pick()

func _process(delta: float) -> void:
	if IssueManager.night_council_active:
		return
	_pause = maxf(0.0, _pause - delta)
	if _pause > 0.0:
		return
	var to := _goal - position
	to.y = 0.0
	if to.length() < 0.12:
		_pick()
		return
	position += to.normalized() * speed * delta
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), 1.0 - exp(-8.0 * delta))

func _pick() -> void:
	var ang := randf() * TAU
	var r := randf() * radius
	_goal = _home + Vector3(cos(ang) * r, 0.0, sin(ang) * r)
	_pause = randf_range(0.35, 1.8)
