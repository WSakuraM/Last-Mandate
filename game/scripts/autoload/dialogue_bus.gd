extends Node
## 简易对话总线：排队显示对白，支持选项。

signal dialogue_started
signal dialogue_finished
signal choice_made(choice_id: String)

var _queue: Array = []
var _active: bool = false
var _waiting_choice: bool = false

func is_busy() -> bool:
	return _active

func play(lines: Array) -> void:
	## lines: Array of Dictionary
	## { "speaker": "阿恩", "text": "..." }
	## { "speaker": "", "text": "旁白", "narration": true }
	## { "choices": [ {"id":"a","label":"..."}, ... ], "prompt": "..." }
	_queue = lines.duplicate()
	_active = true
	dialogue_started.emit()
	_advance()

func _advance() -> void:
	if _queue.is_empty():
		_active = false
		_waiting_choice = false
		dialogue_finished.emit()
		return
	var item = _queue.pop_front()
	if typeof(item) == TYPE_DICTIONARY and item.has("choices"):
		_waiting_choice = true
		get_tree().call_group("dialogue_ui", "show_choices", item.get("prompt", "你如何抉择？"), item["choices"])
	else:
		_waiting_choice = false
		get_tree().call_group("dialogue_ui", "show_line", item)

func notify_continue() -> void:
	if not _active or _waiting_choice:
		return
	_advance()

func notify_choice(choice_id: String) -> void:
	if not _active or not _waiting_choice:
		return
	_waiting_choice = false
	choice_made.emit(choice_id)
	_advance()
