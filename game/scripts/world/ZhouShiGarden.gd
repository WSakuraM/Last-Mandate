extends Node
# 区块三·支线：周氏园中"人不是折子" → DialogueManager JSON。

var _triggered := false


func trigger() -> void:
	if _triggered:
		return
	_triggered = true
	EventBus.dialogue_request.emit("DLG_A1_ZHOUSHI")
