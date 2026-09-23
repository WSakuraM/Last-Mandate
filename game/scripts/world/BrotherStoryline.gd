extends Node
# 朱由检 × 朱由校（天启）兄弟线：第一幕三拍 → DialogueManager JSON。

signal beat_completed(beat_id: String)

const DLG := {
	"b1": "DLG_A1_BROTHER_GIFT",
	"b2_intro": "DLG_A1_BROTHER_ARRIVE",
	"b2_visit": "DLG_A1_BROTHER_VISIT",
	"b3": "DLG_A1_BROTHER_SICKBED",
}

var _current_beat := ""
var _emperor_node: Node3D


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger(beat_id: String) -> void:
	if _current_beat != "":
		return
	if beat_id == "b2" and IssueManager.flags.get("brother_b2_done", false):
		return
	if beat_id != "b2" and IssueManager.flags.get("brother_%s_done" % beat_id, false):
		return
	_current_beat = beat_id
	match beat_id:
		"b1":
			EventBus.dialogue_request.emit(DLG["b1"])
		"b2":
			EventBus.dialogue_request.emit(DLG["b2_intro"])
		"b3":
			EventBus.dialogue_request.emit(DLG["b3"])


func _on_dialogue_finished(dialogue_id: String, result: Dictionary) -> void:
	if _current_beat == "":
		return
	match dialogue_id:
		DLG["b1"]:
			if _current_beat == "b1":
				_finish_beat("b1")
		DLG["b2_intro"]:
			if _current_beat == "b2":
				_spawn_emperor()
				EventBus.zone_entered.emit("御驾在府")
				EventBus.dialogue_request.emit(DLG["b2_visit"])
		DLG["b2_visit"]:
			if IssueManager.flags.get("brother_b2_done", false):
				return
			if result.get("choice", "") == "share_quiet":
				IssueManager.flags["farm_yield_boost_season"] = (ResourceManager.season + 1) % 4
				EventBus.narration.emit("兄长记下了你的园——下一季菜收 +10%")
			IssueManager.flags["brother_b2_done"] = true
			_despawn_emperor()
			_finish_beat("b2")
		DLG["b3"]:
			if _current_beat == "b3":
				_finish_beat("b3")


func _finish_beat(beat_id: String) -> void:
	_current_beat = ""
	beat_completed.emit(beat_id)


func _spawn_emperor() -> void:
	_despawn_emperor()
	var world := get_parent()
	if world == null:
		return
	_emperor_node = CourtyardProps.make_emperor_visit(CourtyardLayout.BROTHER_VISIT, -12.0)
	world.add_child(_emperor_node)


func _despawn_emperor() -> void:
	if _emperor_node and is_instance_valid(_emperor_node):
		_emperor_node.queue_free()
	_emperor_node = null
