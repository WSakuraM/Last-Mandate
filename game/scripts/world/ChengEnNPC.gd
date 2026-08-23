extends Node3D
# 王承恩：第一幕情感锚。信王时期的随侍太监，立于夜召堂前。
# 玩家靠近时显示提示，不阻塞主玩法，本身不可交互推进（只做氛围与叙事锚点）。

var near := false

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
		EventBus.interact_prompt.emit("王承恩随侍在侧，垂手而立")

func _on_exit(b):
	if b.is_in_group("player"):
		near = false
		EventBus.interact_hide.emit()
