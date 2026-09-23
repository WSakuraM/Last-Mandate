extends Node
# 区块三·支线：蝗旱涝 + 圣旨岁禄 → DialogueManager JSON。

const CALAMITY_IDS := [
	"DLG_A1_CALAMITY_LOCUST",
	"DLG_A1_CALAMITY_DROUGHT",
	"DLG_A1_CALAMITY_FLOOD",
]

var _triggered := false
var _await_edict := false


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger() -> void:
	if _triggered:
		return
	_triggered = true
	var idx: int = randi() % CALAMITY_IDS.size()
	var dlg_id: String = CALAMITY_IDS[idx]
	if idx == 0 or idx == 2:
		CourtPlot.wilt_all_crops()
	EventBus.dialogue_request.emit(dlg_id)


func _on_dialogue_finished(dialogue_id: String, _result: Dictionary) -> void:
	if dialogue_id in CALAMITY_IDS:
		if not IssueManager.flags.get("prince_tax_edict", false):
			_await_edict = true
			EventBus.dialogue_request.emit("DLG_A1_STIPEND_EDICT")
		return
	if dialogue_id == "DLG_A1_STIPEND_EDICT" and _await_edict:
		_await_edict = false
		ResourceManager.apply_prince_tax_edict()
