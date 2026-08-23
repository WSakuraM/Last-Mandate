extends Node3D
# 王承恩：第一幕情感锚。信王时期的随侍太监，立于夜召堂前。
# 玩家靠近时显示提示，按 E 可触发一段短对话（DLG_A1_CHENGEN_IDLE）。

var near := false
var _dialogue_cd := 0.0

func _ready():
	# 王承恩占位模型（规范资产，后续可换精模不改代码）
	var ph: Node3D = preload("res://assets/models/characters/aen.tscn").instantiate()
	add_child(ph)

	# 触发区
	var area := Area3D.new()
	area.name = "ChengEnZone"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 3.0
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)
	add_child(area)

func _on_enter(b):
	if b.is_in_group("player"):
		near = true
		EventBus.interact_prompt.emit("王承恩随侍在侧（按 E 交谈）")

func _on_exit(b):
	if b.is_in_group("player"):
		near = false
		EventBus.interact_hide.emit()

func _process(delta):
	_dialogue_cd = max(0.0, _dialogue_cd - delta)
	if near and _dialogue_cd <= 0.0 and Input.is_key_pressed(KEY_E):
		_dialogue_cd = 3.0   # 防止连续触发
		EventBus.dialogue_request.emit("DLG_A1_CHENGEN_IDLE")
