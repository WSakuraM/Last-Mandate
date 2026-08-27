extends Node3D
# 第一幕「井边」小事件：信王亲为下人汲水，润泽府中人心。
# 头顶问号，点击后通过 DialogueManager 播放 DLG_A1_WELL（走近不再自动弹）。

func _ready():
	position = CourtyardLayout.WELL
	var ring := CourtyardProps.make_interact_ring(1.7)
	ring.name = "WellRing"
	add_child(ring)
	ring.visible = true
	(ring.material_override as StandardMaterial3D).albedo_color.a = 0.22
	var mark := InteractMark.bind(self, "DLG_A1_WELL", 2.55, true, 1.15)
	mark.activated.connect(_on_talked)


func _on_talked() -> void:
	var ring := get_node_or_null("WellRing") as MeshInstance3D
	if ring:
		ring.visible = false
