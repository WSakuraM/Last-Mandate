extends Node3D
# 俯视相机：高位俯角跟随玩家，←/→ 旋转 yaw。

var cam: Camera3D
var target: Node3D
var yaw := 0.0
var dist := 22.0
var height := 20.0

func _ready():
	cam = Camera3D.new()
	add_child(cam)
	var t := get_tree().get_first_node_in_group("player")
	if t:
		target = t

func _process(delta):
	if IssueManager.night_council_active:
		return
	if Input.is_key_pressed(KEY_LEFT):
		yaw += delta * 1.2
	if Input.is_key_pressed(KEY_RIGHT):
		yaw -= delta * 1.2
	if target:
		var offset := Vector3(sin(yaw), 0, cos(yaw)) * dist
		offset.y = height
		cam.global_position = target.global_position + offset
		cam.look_at(target.global_position + Vector3(0, 1, 0), Vector3.UP)
