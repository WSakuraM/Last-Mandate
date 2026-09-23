extends Node
# 《末命》对话管理器（自动加载）
# 职责：加载 data/dialogues/*.json，管理对话队列与播放状态。
# 参考：星露谷 / 动物之森的对话气泡体验。
# 统一替代现有 8 个脚本中重复的 CanvasLayer + PanelContainer 叙事卡片模式。

signal dialogue_started(id: String)
signal dialogue_finished(id: String, result: Dictionary)

var _queue: Array = []
var _playing: bool = false
var _box: Node = null   # DialogueBox 实例

func _ready():
	# 监听 EventBus 的对话请求信号（允许任意脚本通过信号触发对话）
	EventBus.dialogue_request.connect(_on_dialogue_request)

# ── 外部调用入口 ──

# 通过对话 ID 请求播放（从 data/dialogues/ 加载 JSON）
func play(dialogue_id: String):
	var resolved := _resolve_dialogue_id(dialogue_id)
	var data := _load_dialogue(resolved)
	if data.is_empty():
		push_warning("DialogueManager: 找不到对话 %s" % resolved)
		return
	_queue.append(data)
	_try_next()

func _resolve_dialogue_id(dialogue_id: String) -> String:
	match dialogue_id:
		"DLG_A1_QIUSHUI_IDLE":
			if IssueManager.flags.get("kind_likely", false):
				return "DLG_A1_QIUSHUI_IDLE_AFTER"
			if IssueManager.flags.get("qiushui_letter_done", false):
				return "DLG_A1_QIUSHUI_IDLE_AFTER"
		"DLG_A1_WUBO_IDLE":
			if ResourceManager.is_prince_tax_active():
				return "DLG_A1_WUBO_IDLE_TAX"
		"DLG_A1_CHENGEN_IDLE":
			if IssueManager.flags.get("aen_seed_given", false):
				return "DLG_A1_CHENGEN_IDLE_SEED"
	return dialogue_id

# 直接传入 dict 播放（用于硬编码的快速对话或动态生成内容）
func play_data(data: Dictionary):
	if data.is_empty():
		return
	_queue.append(data)
	_try_next()

func is_active() -> bool:
	return _playing

func reset_for_new_act1() -> void:
	_queue.clear()
	_playing = false
	if _box and is_instance_valid(_box):
		_box.queue_free()
		_box = null
	IssueManager.night_council_active = false

# ── 内部调度 ──

func _on_dialogue_request(id: String):
	play(id)

func _try_next():
	if _playing or _queue.is_empty():
		return
	_playing = true
	IssueManager.night_council_active = true   # 锁世界输入
	var data: Dictionary = _queue.pop_front()
	var box_script: GDScript = load("res://scripts/ui/DialogueBox.gd")
	_box = box_script.new()
	get_tree().root.add_child(_box)
	_box.dialogue_complete.connect(_on_box_complete)
	_box.present(data)
	dialogue_started.emit(data.get("id", ""))

func _on_box_complete(dialogue_id: String, result: Dictionary):
	_playing = false
	if _box and is_instance_valid(_box):
		_box.queue_free()
		_box = null
	IssueManager.night_council_active = false
	dialogue_finished.emit(dialogue_id, result)
	_apply_callbacks(result)
	_try_next()

# ── 结算回调（资源 / 旗标 / 回忆碎片） ──

func _apply_callbacks(result: Dictionary):
	var oc: Dictionary = result.get("on_complete", {})
	if oc.is_empty():
		return
	var deltas: Dictionary = oc.get("resource_deltas", {})
	for k in deltas.keys():
		var val: float = float(deltas[k])
		if k == "purse" or k == "private_purse":
			ResourceManager.add_private_purse(val)
		elif k == "mandate_decay":
			ResourceManager.add_mandate(val)
		elif IssueManager.RES_MAP.has(k):
			ResourceManager.add(IssueManager.RES_MAP[k], val)
		elif ResourceManager.r.has(k):
			ResourceManager.add(k, val)
	var adds: Array = oc.get("flags_add", [])
	for fl in adds:
		IssueManager.flags[fl] = true
	var mem: Dictionary = oc.get("memory", {})
	if mem.has("id") and mem["id"] != "":
		IssueManager.add_memory(
			mem["id"],
			int(mem.get("weight", 5)),
			mem.get("text", ""),
			mem.get("pillar", "Ⅰ")
		)
	var narr: String = str(oc.get("narration", ""))
	if narr != "":
		EventBus.narration.emit(narr)

# ── 数据加载 ──

func _load_dialogue(id: String) -> Dictionary:
	var path := "res://data/dialogues/%s.json" % id
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var p := JSON.new()
	if p.parse(f.get_as_text()) == OK and typeof(p.data) == TYPE_DICTIONARY:
		f.close()
		return p.data
	f.close()
	return {}
