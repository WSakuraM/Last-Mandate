extends Node3D
# 王承恩：第一幕情感锚。信王时期的随侍太监，立于夜召堂前。
# 头顶问号，点击触发 DLG_A1_CHENGEN_IDLE（走近不再自动弹、也不必按 E）。

func _ready():
	var ph: Node3D = preload("res://assets/models/characters/aen.tscn").instantiate()
	CourtyardProps.setup_character(ph, -90.0)
	add_child(ph)
	InteractMark.bind(self, "DLG_A1_CHENGEN_IDLE", 2.05)
