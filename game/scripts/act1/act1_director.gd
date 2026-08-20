extends Node
## 第一幕导演：开场、阿恩、轻危机、夜召推进。

var _harvest_count: int = 0
var _talked_aen: bool = false

func _ready() -> void:
	add_to_group("act1_director")
	await get_tree().process_frame
	_play_intro()

func _play_intro() -> void:
	Dialogue.play([
		{"narration": true, "text": "大明很大。府门很小。你暂时只需要把这一畦侍候活。"},
		{"speaker": "阿恩", "text": "王爷起得早。……奴婢叫阿恩。"},
		{"speaker": "阿恩", "text": "王爷若饿，园子里有菜。比御膳房近。"},
		{"narration": true, "text": "去畦里播种，等它长大后收获，再到木牌处售卖。也可找府中人说话。"},
	])
	GameState.set_flag("met_aen", true)
	GameState.add_memory("MF_A1_AEN_FIRST")
	if not Dialogue.dialogue_finished.is_connected(_on_intro_done):
		Dialogue.dialogue_finished.connect(_on_intro_done, CONNECT_ONE_SHOT)

func _on_intro_done() -> void:
	pass

func on_first_harvest() -> void:
	_harvest_count += 1
	if _harvest_count == 1:
		Dialogue.play([
			{"speaker": "吴伯", "text": "第一畦。王爷亲手拔的，卖了能换农具；分给灶上人，他们会记得。"},
		])

func on_npc_talk(npc_id: String) -> void:
	if Dialogue.is_busy():
		return
	match npc_id:
		"aen":
			_talk_aen()
		"wu_bo":
			Dialogue.play([
				{"speaker": "吴伯", "text": "播种、等候、收获、售卖。把日子过明白，比读邸报有用。"},
			])
		"qiushui":
			_talk_qiushui()

func _talk_aen() -> void:
	if GameState.flags.get("has_seed_bag", false):
		Dialogue.play([
			{"speaker": "阿恩", "text": "谷种收好了。哪天府散了，也能种。"},
		])
		return
	if not _talked_aen and GameState.flags.get("first_harvest", false):
		_talked_aen = true
		Dialogue.play([
			{"speaker": "阿恩", "text": "京里风紧。"},
			{"speaker": "你", "text": "与府里何干？"},
			{"speaker": "阿恩", "text": "王爷若有一日入宫……别忘了园子里的人。"},
			{"speaker": "你", "text": "我不会入宫。"},
			{"speaker": "阿恩", "text": "奴婢瞎说。谷种我收了一小袋。哪天——带着。"},
			{"narration": true, "text": "你收下旧谷种。（母题已埋下）"},
		])
		GameState.set_flag("has_seed_bag", true)
		GameState.add_memory("MF_A1_AEN_PROMISE")
		Dialogue.dialogue_finished.connect(_maybe_crisis_after_aen, CONNECT_ONE_SHOT)
	else:
		Dialogue.play([
			{"speaker": "阿恩", "text": "畦里的土还湿着。王爷走稳些。"},
		])

func _maybe_crisis_after_aen() -> void:
	if not GameState.flags.get("crisis_done", false):
		_start_crisis()

func _talk_qiushui() -> void:
	if GameState.flags.get("qiushui_resolved", false):
		Dialogue.play([{"speaker": "秋穗", "text": "……谢王爷。"}])
		return
	_start_crisis()

func _start_crisis() -> void:
	if GameState.flags.get("crisis_done", false):
		return
	Dialogue.choice_made.connect(_on_crisis_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "秋穗", "text": "娘家涝了。……我不敢问赏，只敢问，王府能否借三斗米，来年还。"},
		{
			"prompt": "秋穗低着头。你如何决断？",
			"choices": [
				{"id": "help", "label": "借粮相助（仁慈）"},
				{"id": "token", "label": "象征性给一点"},
				{"id": "refuse", "label": "拒绝（府中也紧）"},
			],
		},
	])

func _on_crisis_choice(choice_id: String) -> void:
	GameState.set_flag("crisis_done", true)
	GameState.flags["qiushui_resolved"] = true
	match choice_id:
		"help":
			GameState.bump_trait("mercy", 2)
			GameState.add_memory("MF_A1_HELP_QIUSHUI")
			GameState.set_flag("helped_qiushui", true)
			if GameState.money >= 5:
				GameState.add_money(-5)
			Dialogue.play([
				{"speaker": "你", "text": "去仓里拨三斗。记在我账上。"},
				{"speaker": "秋穗", "text": "……秋穗不敢忘。"},
				{"narration": true, "text": "轻危机已过。再与阿恩深谈后，夜色会来敲门。"},
			])
		"token":
			GameState.bump_trait("mercy", 1)
			Dialogue.play([
				{"speaker": "你", "text": "先拿这些。……别声张。"},
				{"speaker": "秋穗", "text": "……是。"},
			])
		"refuse":
			GameState.add_memory("MF_A1_REFUSE_QIUSHUI")
			Dialogue.play([
				{"speaker": "你", "text": "府中也紧。恕难。"},
				{"speaker": "秋穗", "text": "……奴婢多嘴了。"},
			])
	Dialogue.dialogue_finished.connect(_check_night_ready, CONNECT_ONE_SHOT)

func _check_night_ready() -> void:
	## 条件：收获过 + 阿恩谷种 + 轻危机 → 可触发夜召（或自动）
	if GameState.flags.get("night_summon_done", false):
		return
	if GameState.flags.get("first_harvest", false) and GameState.flags.get("has_seed_bag", false) and GameState.flags.get("crisis_done", false):
		await get_tree().create_timer(0.6).timeout
		_start_night_summon()

func _start_night_summon() -> void:
	if GameState.flags.get("night_summon_done", false):
		return
	GameState.set_flag("night_summon_done", true)
	GameState.add_memory("MF_A1_NIGHT_SUMMON")
	get_tree().call_group("act1_world", "begin_night_tint")
	Dialogue.play([
		{"narration": true, "text": "冬夜。马蹄。灯笼的冷青，压过府里的暖黄。"},
		{"speaker": "中使", "text": "信王接旨——兄台龙驭宾天。请王爷即刻入宫。"},
		{"speaker": "你", "text": "……阿恩。"},
		{"speaker": "阿恩", "text": "带上。旧谷种。"},
		{"speaker": "你", "text": "宫里用得着？"},
		{"speaker": "阿恩", "text": "用不着。王爷看着，会记得自己不是从龙椅里长出来的。"},
		{"speaker": "中使", "text": "请。"},
		{"narration": true, "text": "自此无回头。"},
	])
	Dialogue.dialogue_finished.connect(_go_act1_end, CONNECT_ONE_SHOT)

func _go_act1_end() -> void:
	get_tree().change_scene_to_file("res://scenes/act1/act1_end.tscn")
