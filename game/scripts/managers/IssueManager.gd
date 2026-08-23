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
var memories := []          # [{id, weight, text, pillar}]  pillar: Ⅰ朱由检悲情/Ⅱ明末动乱/Ⅲ人民疾苦
var night_council_active := false  # 夜召进行中：锁住世界输入
var _seq_cursor := 0        # 固定顺序游标：按议题 order 升序循环呈现

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
		# 分段解锁：unlock_day 之后的天数才进入可抽池（第一幕按 total_day 推进剧情）
		var unlock: int = int(it.get("unlock_day", 1))
		if ResourceManager.total_day < unlock:
			continue
		out.append(it)
	return out

# 按剧本固定顺序（order 升序）+ 分段解锁 + 线性消耗呈现议题。
# 已呈现过的议题记入 used_once 不再出现——保证剧情层层递进、演过不再回头，不循环重复。
func draw_issue(stage_filter: Array = []) -> Dictionary:
	var pool := eligible(stage_filter)
	if pool.is_empty():
		return {}
	# 排除已消耗议题（线性推进，不重复）
	var avail := []
	for it in pool:
		if used_once.has(it["id"]):
			continue
		avail.append(it)
	if avail.is_empty():
		return {}
	# 按 order 升序排序（缺省排末尾），保证"剧本固定顺序呈现"
	avail.sort_custom(func(a, b): return a.get("order", 999) < b.get("order", 999))
	var chosen: Dictionary = avail[0]
	# 线性消耗：标记已用，下次不再出现
	used_once[chosen.get("id", "")] = true
	return chosen

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
		var pillar: String = choice.get("memory_pillar", "Ⅰ")
		var txt := "「%s」%s" % [issue.get("title", ""), choice.get("label", "")]
		add_memory(mid, w, txt, pillar)

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

# 写入回忆碎片：同 id 去重（保留更高 weight），并携带 pillar 支柱信息。
func add_memory(id: String, weight: int, text: String, pillar: String = "Ⅰ"):
	var existing = null
	for m in memories:
		if m["id"] == id:
			existing = m
			break
	if existing != null:
		if weight > existing["weight"]:
			existing["weight"] = weight
			existing["text"] = text
			existing["pillar"] = pillar
	else:
		memories.append({"id": id, "weight": weight, "text": text, "pillar": pillar})
	memory_added.emit(id, weight)

# 终章蒙太奇抽取：Ⅲ类（人民疾苦）严格优先填满 count 个名额，
# 剩余再按权重抽Ⅰ/Ⅱ类。返回完整 memory dict 数组（含 id/weight/text/pillar）。
func draw_montage(count: int = 8) -> Array:
	if memories.is_empty():
		return []
	var people: Array = []
	var others: Array = []
	for m in memories:
		if m.get("pillar", "Ⅰ") == "Ⅲ":
			people.append(m)
		else:
			others.append(m)
	people.sort_custom(func(a, b): return int(a["weight"]) > int(b["weight"]))
	others.sort_custom(func(a, b): return int(a["weight"]) > int(b["weight"]))
	var out: Array = []
	# Ⅲ类严格优先：有多少填多少，直到 count 个名额占满
	for m in people:
		if out.size() >= count:
			break
		out.append(m)
	# 名额未满则补Ⅰ/Ⅱ类
	for m in others:
		if out.size() >= count:
			break
		out.append(m)
	return out

# 血诏脸谱：返回权重最高的 2-3 条Ⅲ类回忆，作为"勿伤我百姓"时浮现的具体脸。
func draw_blood_edict_faces(count: int = 3) -> Array:
	if memories.is_empty():
		return []
	var people: Array = []
	for m in memories:
		if m.get("pillar", "Ⅰ") == "Ⅲ":
			people.append(m)
	people.sort_custom(func(a, b): return int(a["weight"]) > int(b["weight"]))
	var out: Array = []
	for m in people:
		if out.size() >= count:
			break
		out.append(m)
	return out

# 兼容旧接口：返回 text 字符串数组。
func draw_memory_texts(max_count: int = 8) -> Array:
	var montage := draw_montage(max_count)
	var out: Array = []
	for m in montage:
		out.append(m["text"])
	return out
