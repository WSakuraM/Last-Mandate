extends Node3D
# 第一幕「井边」小事件：信王亲为下人汲水，润泽府中人心。
# 已迁移至对话系统：触发后通过 DialogueManager 播放 DLG_A1_WELL。
# 资源/旗标/回忆碎片结算由 DialogueManager 统一处理（见 on_complete 回调）。

var shown := false

func _ready():
	var area := Area3D.new()
	area.name = "WellZone"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 3.0
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect(_on_enter)
	add_child(area)
	position = Vector3(-10, 0, 8)   # 与 Act1Director 中水井 mesh 同址

func _on_enter(b):
	if not b.is_in_group("player"):
		return
	if shown:
		return
	shown = true
	# 通过对话系统播放（DialogueManager 自动锁世界输入 + 结算资源/回忆）
	EventBus.dialogue_request.emit("DLG_A1_WELL")
