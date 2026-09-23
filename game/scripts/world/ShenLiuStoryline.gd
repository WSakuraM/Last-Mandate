extends Node
# 区块三·支线：沈柳鸳鸯线（沈戍×柳筝）第一幕三拍 → DialogueManager JSON。

signal beat_completed(beat_id: String)

const DLG_MAP := {
	"b1": "DLG_A1_SHENLIU_B1",
	"b2": "DLG_A1_SHENLIU_B2",
	"b3": "DLG_A1_SHENLIU_B3",
}

var _pending := ""


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger(beat_id: String) -> void:
	if _pending != "":
		return
	if not DLG_MAP.has(beat_id):
		return
	if IssueManager.flags.get("shenliu_%s_done" % beat_id, false):
		return
	_pending = beat_id
	EventBus.dialogue_request.emit(DLG_MAP[beat_id])


func _on_dialogue_finished(dialogue_id: String, _result: Dictionary) -> void:
	if _pending == "":
		return
	var expected: String = DLG_MAP.get(_pending, "")
	if dialogue_id != expected:
		return
	var beat := _pending
	_pending = ""
	if not IssueManager.flags.get("shenliu_%s_done" % beat, false):
		IssueManager.flags["shenliu_%s_done" % beat] = true
	beat_completed.emit(beat)
