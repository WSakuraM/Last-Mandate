extends Node
# M1A3 阿恩递种夜谈：玩家首次播种时触发（由 EventBus.first_sow 驱动）。
# 已迁移至对话系统：触发后通过 DialogueManager 播放 DLG_A1_AEN_SEED。
# 谷种作跨幕道具（flags.aen_seed_given），终章蒙太奇回收为 MF_A1_AEN_PROMISE。

var _triggered := false

func _ready():
	EventBus.first_sow.connect(_on_first_sow)

func _on_first_sow():
	if _triggered:
		return
	_triggered = true
	# 通过对话系统播放（DialogueManager 自动锁世界输入 + 写入回忆碎片 + 设旗标）
	EventBus.dialogue_request.emit("DLG_A1_AEN_SEED")
