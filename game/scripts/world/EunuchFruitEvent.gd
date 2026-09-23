extends Node
# 区块三·支线：中使借果 → DialogueManager JSON。

signal fruit_resolved(choice: String)

var _triggered := false


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger() -> void:
	if _triggered:
		return
	_triggered = true
	EventBus.dialogue_request.emit("DLG_A1_EUNUCH_FRUIT")


func _on_dialogue_finished(dialogue_id: String, result: Dictionary) -> void:
	if dialogue_id != "DLG_A1_EUNUCH_FRUIT":
		return
	fruit_resolved.emit(str(result.get("choice", "")))
