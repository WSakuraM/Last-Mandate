extends SceneTree
# M1 无界面验收：资源键翻译、议题池、重玩重置。用法：
# Godot --headless --path game -s res://scripts/tools/m1_acceptance.gd

const EXPECT_A1 := 15

func _initialize() -> void:
	await process_frame
	var im = _im()
	if im.issues.is_empty():
		await im.issue_pool_ready
	var fails: Array[String] = []
	_test_issue_load(fails)
	_test_res_map(fails)
	_test_reset(fails)
	_test_story_priority_source(fails)
	if fails.is_empty():
		print("M1 acceptance: ALL PASS (%d checks)" % 4)
	else:
		for f in fails:
			push_error(f)
		print("M1 acceptance: %d FAIL" % fails.size())
	quit(0 if fails.is_empty() else 1)


func _im():
	return get_root().get_node("IssueManager")

func _rm():
	return get_root().get_node("ResourceManager")


func _test_issue_load(fails: Array[String]) -> void:
	var im = _im()
	var rm = _rm()
	var n: int = im.issues.size()
	if n < EXPECT_A1:
		fails.append("议题总数不足：%d" % n)
	var a1_all := 0
	for it in im.issues:
		if "A1" in it.get("stage", []):
			a1_all += 1
	if a1_all != EXPECT_A1:
		fails.append("A1 议题条数应为 %d，实际 %d" % [EXPECT_A1, a1_all])
	rm.total_day = 200
	var a1_unlocked: Array = im.eligible(["A1"])
	if a1_unlocked.size() < EXPECT_A1:
		fails.append("A1 全解锁后可抽不足：%d（应 %d）" % [a1_unlocked.size(), EXPECT_A1])
	rm.reset_for_new_act1()


func _test_res_map(fails: Array[String]) -> void:
	var im = _im()
	var rm = _rm()
	var path := "res://data/issues/ISSUE_A1_COURT_RIVALRY.json"
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		fails.append("无法读取 ISSUE_A1_COURT_RIVALRY.json")
		return
	var before: float = rm.r["emperor_heart"]
	im.apply_choice(data, "ally")
	var after: float = rm.r["emperor_heart"]
	if not is_equal_approx(after, before + 3.0):
		fails.append("RES_MAP 未生效：暗结清流 君心应 +3，实际 %.1f→%.1f" % [before, after])
	var border_path := "res://data/issues/ISSUE_A1_BORDER_INTEL.json"
	var border: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(border_path))
	var ba_before: float = rm.r["border_army"]
	im.apply_choice(border, "memo")
	if not is_equal_approx(rm.r["border_army"], ba_before + 4.0):
		fails.append("border_army 直键未结算")


func _test_reset(fails: Array[String]) -> void:
	var im = _im()
	var rm = _rm()
	im.flags["test_flag"] = true
	im.memories.append({"id": "TEST"})
	rm.mandate_decay = 88.0
	rm.reset_for_new_act1()
	im.reset_for_new_act1()
	if rm.mandate_decay != 12.0:
		fails.append("reset_for_new_act1 未重置气数")
	if im.flags.has("test_flag"):
		fails.append("reset_for_new_act1 未清空旗标")
	if im.memories.size() > 0:
		fails.append("reset_for_new_act1 未清空回忆")


func _test_story_priority_source(fails: Array[String]) -> void:
	var src := FileAccess.get_file_as_string("res://scripts/world/Act1Director.gd")
	if "if _try_story_beat():" not in src:
		fails.append("Act1Director 剧情日未优先于夜召")
	if "if ResourceManager.day % 7 == 0:" not in src:
		fails.append("Act1Director 缺少周夜召")
