extends Node
# 《末命》议题系统单例（自动加载）
# 职责：加载 data/issues/*.json，负责抽取、数值结算、旗标、回忆碎片、民变压力。
# 关键：议题 JSON 资源键（popular/frontier/court/resolve）与 ResourceManager 键
# （people/border_army/court_order/emperor_heart）在此统一翻译，避免结算错位。

const RES_MAP := {
	"treasury": "treasury",
	"popular": "people",
	"frontier": "border_army",
	"court": "court_order",
	"resolve": "emperor_heart",
	"mandate_decay": "mandate_decay",
}

var issues := []            # 全部议题（dict）
var flags := {}             # 当前旗标 Bool
var used_once := {}         # 已用过的 once 议题 id
var rebel_pressure := 0.0   # 民变压力（派生指标）
var memories := []          # [{id, weight, text}]
var night_council_active := false  # 夜召进行中：锁住世界输入

signal issue_pool_ready(count: int)
signal issue_presented(issue: Dictionary)
signal issue_resolved(result: Dictionary)
signal memory_added(id: String, weight: int)

func _ready():
	_load_issues()

func _load_issues():
	var dir := DirAccess.open("res://data/issues/")
	if dir == null:
		push_error("IssueManager: 找不到 res://data/issues/")
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".json") and not fname.begins_with("_"):
			var f := FileAccess.open("res://data/issues/" + fname, FileAccess.READ)
			var p := JSON.new()
			if p.parse(f.get_as_text()) == OK and typeof(p.data) == TYPE_DICTIONARY:
				issues.append(p.data)
			f.close()
		fname = dir.get_next()
	dir.list_dir_end()
	issue_pool_ready.emit(issues.size())
	print("IssueManager: 载入议题 %d 条" % issues.size())

# 返回当前可抽取的议题列表（过滤 once / 旗标前置条件 / 可选 stage 过滤）
func eligible(stage_filter: Array = []) -> Array:
	var out := []
	for it in issues:
		if it.get("once", false) and used_once.has(it["id"]):
			continue
		var req_any: Array = it.get("requires_any_flags", [])
		if req_any.size() > 0:
			var ok := false
			for fl in req_any:
				if flags.get(fl, false):
					ok = true
					break
			if not ok:
				continue
		var req_all: Array = it.get("requires_all_flags", [])
		var ok_all := true
		for fl in req_all:
			if not flags.get(fl, false):
				ok_all = false
				break
		if not ok_all:
			continue
		if stage_filter.size() > 0:
			var st: Array = it.get("stage", [])
			var hit := false
			for s in stage_filter:
				if s in st:
					hit = true
					break
			if not hit:
				continue
		out.append(it)
	return out

# 按 weight 加权随机抽取一个议题
func draw_issue(stage_filter: Array = []) -> Dictionary:
	var pool := eligible(stage_filter)
	if pool.is_empty():
		return {}
	var total := 0
	for it in pool:
		total += max(1, it.get("weight", 1))
	var r := randi() % total
	for it in pool:
		r -= max(1, it.get("weight", 1))
		if r < 0:
			return it
	return pool[0]

# 应用某选项的全部后果。返回结算结果 dict。
func apply_choice(issue: Dictionary, choice_id: String) -> Dictionary:
	var choice := {}
	var choices: Array = issue.get("choices", [])
	for c in choices:
		if c["id"] == choice_id:
			choice = c
			break
	if choice.is_empty():
		return {}

	# 1) 五资源 + 气数结算（键名翻译）
	var d: Dictionary = choice.get("deltas", {})
	for k in d.keys():
		var rm_key = RES_MAP.get(k, "")
		if rm_key == "":
			continue
		if rm_key == "mandate_decay":
			ResourceManager.add_mandate(float(d[k]))
		else:
			ResourceManager.add(rm_key, float(d[k]))

	# 2) 民变压力 -> 轻微推动气数（压迫越深，亡国之势越急）
	var rp := float(d.get("rebel_pressure", 0.0))
	rebel_pressure += rp
	if rp > 0.0:
		ResourceManager.add_mandate(rp * 0.2)

	# 3) 旗标变更
	var adds: Array = choice.get("flags_add", [])
	for fl in adds:
		flags[fl] = true
	var rems: Array = choice.get("flags_remove", [])
	for fl in rems:
		flags.erase(fl)

	# 4) 回忆碎片（终章蒙太奇回收）
	var mid: String = choice.get("memory", "")
	if mid != "":
		var w := int(choice.get("memory_weight", 5))
		var txt := "「%s」%s" % [issue.get("title", ""), choice.get("label", "")]
		memories.append({"id": mid, "weight": w, "text": txt})
		memory_added.emit(mid, w)

	# 5) once 标记
	if issue.get("once", false):
		used_once[issue["id"]] = true

	var result := {
		"issue": issue.get("id", ""),
		"choice": choice_id,
		"title": issue.get("title", ""),
		"label": choice.get("label", ""),
	}
	issue_resolved.emit(result)
	return result

# 终章用：按权重抽取被辜负的回忆碎片文本
func draw_memory_texts(max_count: int = 6) -> Array:
	if memories.is_empty():
		return []
	var sorted := memories.duplicate()
	sorted.sort_custom(func(a, b): return a["weight"] > b["weight"])
	var out := []
	for m in sorted:
		out.append(m["text"])
		if out.size() >= max_count:
			break
	return out
