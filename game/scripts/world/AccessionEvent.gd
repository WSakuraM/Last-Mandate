extends Node
## M1A5 夜召·兄崩入继 → DialogueManager（按旗标动态拼 lines）。

signal accession_finished


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger() -> void:
	DialogueManager.play_data(_build_dialogue())


func _build_dialogue() -> Dictionary:
	var lines: Array = []
	_push(lines, "", "冬夜。马蹄踏碎霜，府门外的灯笼被风扯得乱晃。")
	_push(lines, "", "你正从菜畦边起身，吴伯已跪在廊下，声音发颤：「王爷……宫中来人了。」")
	_push(lines, "", "青衣中使立在阶前，手里捧着明黄卷轴。暖黄的烛火在他脸上切出一道冷线。")
	if IssueManager.flags.get("brother_b3_done", false):
		_push(lines, "", "你忽然想起数日前乾清宫的药气，和兄长攥住你腕时那一句：「祖制在此。」")
	elif IssueManager.flags.get("brother_b2_done", false):
		_push(lines, "", "你想起那日兄长亲至府门，蹲在你的菜畦边看土——他说，除你之外，大明无路可继。")
	elif IssueManager.flags.get("brother_b1_done", false):
		_push(lines, "", "你袖里还藏着兄长刻的那只木雀——翅纹不齐，刀口极细。")
	_push(lines, "中使", "信王接旨——")
	_push(lines, "中使", "（顿）天启皇帝龙驭宾天。")
	_push(lines, "中使", "皇子皆早夭，无人可嗣。按祖宗成宪，兄崩弟及，遗诏立信王朱由检入承大统。")
	_push(lines, "中使", "（低声）不是内廷争出来的名分，是祖制只剩这一条路。请王爷即刻入宫。")
	if IssueManager.flags.get("brother_b3_done", false):
		_push(lines, "中使", "皇上临崩前还念叨：「五弟……把园子里的菜种好。朕……还想再吃你府上一次春菜。」")
	elif IssueManager.flags.get("brother_bond_warm", false):
		_push(lines, "中使", "皇上曾跟奴婢说，信王在，他心里踏实。")
	elif IssueManager.flags.get("brother_advised_rest", false):
		_push(lines, "中使", "皇上最后几日，果然少碰了木工。……只反复念您的名字。")
	_push(lines, "", "你听见自己指节响了一声。园子里的土气还在袖里，像一层洗不掉的旧。")
	_push(lines, "信王", "……阿恩。")
	_push(lines, "王承恩", "（跪着替你整理衣冠，从袖里摸出一只旧布袋，塞进你掌心）带上。旧谷种。")
	if IssueManager.flags.get("zhoushi_met_act1", false):
		_push(lines, "王承恩", "王妃说，人不是折子。……奴婢只会重复这句话。")
	_push(lines, "信王", "宫里用得着？")
	_push(lines, "王承恩", "用不着。王爷看着，会记得自己不是从龙椅里长出来的。")
	if IssueManager.flags.get("shenliu_b3_done", false):
		_push(lines, "沈戍", "王爷走。门，俺看着。")
	elif IssueManager.flags.get("shenliu_b1_done", false):
		_push(lines, "", "廊下，沈戍的影子被灯笼拉得很长。那一碗粥换来的忠义，今夜替你看门。")
	if IssueManager.flags.get("kind_likely", false):
		_push(lines, "", "你想起秋穗收信时的背影——私囊里少的那笔银子，此刻像压在胸口。")
	_push(lines, "中使", "请。")
	_push(lines, "", "你迈出门槛。回头时，信王府的暖黄还留在门内；再往前，只有冷青。")
	_push(lines, "", "兄长把江山交到你手里，不是因为恩宠，是因为大明已经无人可继。")
	_push(lines, "", "自此无回头。")
	return {
		"id": "DLG_A1_ACCESSION",
		"title": "夜召 · 兄崩入继",
		"lines": lines,
		"choices": [],
		"on_complete": {
			"flags_add": ["act1_accession_done"],
			"memory": {
				"id": "MF_A1_NIGHT_SUMMON",
				"weight": 10,
				"text": "夜召入宫——兄崩弟继，祖制只剩你这条路",
				"pillar": "Ⅰ"
			}
		}
	}


func _push(lines: Array, speaker: String, text: String) -> void:
	lines.append({"speaker": speaker, "text": text, "emotion": "narration" if speaker == "" else ""})


func _on_dialogue_finished(dialogue_id: String, _result: Dictionary) -> void:
	if dialogue_id != "DLG_A1_ACCESSION":
		return
	accession_finished.emit()
