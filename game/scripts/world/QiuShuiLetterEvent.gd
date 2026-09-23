extends Node
# M1A4 秋穗家书 → DialogueManager JSON。

signal letter_resolved(choice: String)

var _triggered := false


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger() -> void:
	if _triggered:
		return
	_triggered = true
	EventBus.dialogue_request.emit("DLG_A1_QIUSHUI_LETTER")


func _on_dialogue_finished(dialogue_id: String, result: Dictionary) -> void:
	if dialogue_id != "DLG_A1_QIUSHUI_LETTER":
		return
	letter_resolved.emit(str(result.get("choice", "")))
