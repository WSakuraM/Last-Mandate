extends Node
## 第一幕导演：目标推进、vignette、危机、夜召。

var _harvest_count: int = 0
var _talked_aen: bool = false

func _ready() -> void:
	add_to_group("act1_director")
	await get_tree().process_frame
	_hide_group("gate_visitor")
	_hide_group("court_visitor")
	_hide_group("weaver_visitor")
	_hide_group("relief_visitor")
	_hide_group("lover_npc")
	_play_intro()

func _hide_group(group_name: String) -> void:
	for n in get_tree().get_nodes_in_group(group_name):
		n.visible = false
		n.set_deferred("monitoring", false)

func _show_group(group_name: String) -> void:
	for n in get_tree().get_nodes_in_group(group_name):
		n.visible = true
		n.set_deferred("monitoring", true)

func _play_intro() -> void:
	Dialogue.play([
		{"narration": true, "text": "大明很大。府门很小。你暂时只需要把这一畦侍候活。"},
		{"speaker": "阿恩", "text": "王爷起得早。……奴婢叫阿恩。"},
		{"speaker": "阿恩", "text": "王爷若饿，园子里有菜。比御膳房近。"},
		{"narration": true, "text": "右上角钉死主线：私囊→首获→阿恩谷种→秋穗→夜召。其余都是可选，不挡结局。种收耗气力，井边每日只能歇一次。"},
	])
	GameState.set_flag("met_aen", true)
	GameState.add_memory("MF_A1_AEN_FIRST")

func on_first_harvest() -> void:
	_harvest_count += 1
	if _harvest_count == 1:
		Dialogue.play([
			{"speaker": "吴伯", "text": "第一畦。卖了进私囊；分给灶上人，他们会记得。"},
			{"narration": true, "text": "府门外有人影。书房林生也有邸报要读。护卫棚空着——人心够了，才能收人。"},
		])
		GameState.set_flag("gate_open", true)
		GameState.set_flag("lin_ready", true)
		GameState.set_flag("guard_intro", true)
		_show_group("gate_visitor")
		return
	if _harvest_count == 3 and not GameState.flags.get("vig_drought_done", false):
		_trigger_drought()

func _trigger_drought() -> void:
	GameState.set_flag("vig_drought_done", true)
	WorldClock.force_disaster("drought")
	GameState.add_memory("MF_A1_DROUGHT")
	Dialogue.play([
		{"narration": true, "text": "井绳忽然变重。土面裂开细纹。天色发白。"},
		{"speaker": "吴伯", "text": "旱了。菜贵，药更贵。外头求赈的会更多。"},
		{"speaker": "周氏", "text": "……水先留给畦。人，也要留一点。"},
	])
	Dialogue.dialogue_finished.connect(_open_relief_after, CONNECT_ONE_SHOT)

func on_new_day() -> void:
	if Dialogue.is_busy():
		return
	match WorldClock.disaster:
		"locust":
			_maybe_locust_event()
		"storm":
			_maybe_storm_line()
		"flood":
			_maybe_flood_line()
		_:
			_maybe_weather_chatter()

func _maybe_weather_chatter() -> void:
	if randf() > 0.35:
		return
	match WorldClock.weather:
		WorldClock.Weather.RAIN:
			_queue_narration("檐下滴答。阿恩把谷种袋往怀里又掖了掖。")
		WorldClock.Weather.SNOW:
			_queue_narration("薄雪落在畦埂上。像一层不肯化的灰。")
		WorldClock.Weather.WIND:
			_queue_narration("风把旗角抽得啪啪响。院猫贴墙走。")
		_:
			if WorldClock.season == WorldClock.Season.SPRING:
				_queue_narration("晴。蝶在菜花边绕了一圈，又走了。")

func _maybe_locust_event() -> void:
	if GameState.flags.get("vig_locust_done", false):
		return
	## 不强制对话框，等玩家去护卫棚或吴伯；先给一句旁白
	_queue_narration("天边暗了一层——不是云，是翅膀。蝗。")

func _maybe_storm_line() -> void:
	if GameState.flags.get("vig_storm_done", false):
		return
	GameState.set_flag("vig_storm_done", true)
	GameState.add_memory("MF_A1_STORM")
	Dialogue.play([
		{"narration": true, "text": "暴雨砸瓦。井沿漫出水花。"},
		{"speaker": "吴伯", "text": "王爷莫下田。涝比旱更急——先护仓，再救人。"},
		{"speaker": "阿恩", "text": "奴婢把谷种袋举高些。……湿了就坏。"},
	])

func _maybe_flood_line() -> void:
	if GameState.flags.get("vig_flood_done", false):
		return
	GameState.set_flag("vig_flood_done", true)
	GameState.add_memory("MF_A1_FLOOD")
	Dialogue.play([
		{"narration": true, "text": "院角积水，蛙声一夜未停。"},
		{"speaker": "秋穗", "text": "家里信里也写涝。……王爷若能匀一口粮，便是活路。"},
	])

func try_resolve_locust() -> void:
	if WorldClock.disaster != "locust" or GameState.flags.get("vig_locust_done", false):
		return
	GameState.set_flag("vig_locust_done", true)
	GameState.add_memory("MF_A1_LOCUST")
	if GameState.guards >= 2:
		GameState.bump_trait("diligence", 1)
		Dialogue.play([
			{"speaker": "沈戍", "text": "亲随拿竹竿拍网。畦能保住大半。"},
			{"speaker": "吴伯", "text": "有人护着，蝗也怕。人心没白攒。"},
			{"narration": true, "text": "蝗灾支线：护畦成功。物价仍紧，但府里还有菜。"},
		])
	elif GameState.guards >= 1:
		Dialogue.play([
			{"speaker": "沈戍", "text": "人少。能护一畦，护不了墙根。"},
			{"narration": true, "text": "蝗灾支线：勉强护住主畦。灌木已空。"},
		])
	else:
		if GameState.veggies > 0:
			GameState.add_veggies(-mini(2, GameState.veggies))
		GameState.bump_trait("mercy", 0)
		Dialogue.play([
			{"speaker": "吴伯", "text": "没有亲随，只能眼睁睁看。私囊里的菜也要烂两棵。"},
			{"speaker": "周氏", "text": "……人不是折子。虫，也不认折子。"},
			{"narration": true, "text": "蝗灾支线：损失菜蔬。可去护卫棚收人，下次会好些。"},
		])

func _open_relief_after() -> void:
	_open_relief()

func on_sold() -> void:
	if not GameState.flags.get("sold_once", false):
		return
	if not GameState.flags.get("eunuch_open", false) and not GameState.flags.get("vig_eunuch_done", false):
		await get_tree().create_timer(0.35).timeout
		if Dialogue.is_busy():
			await Dialogue.dialogue_finished
		GameState.set_flag("eunuch_open", true)
		_show_group("court_visitor")
		Dialogue.play([
			{"narration": true, "text": "前院多了一个笑。中使说是「路过借点果子」。"},
		])
		await Dialogue.dialogue_finished
	_maybe_open_weaver()
	_open_relief()

func _maybe_open_weaver() -> void:
	if GameState.flags.get("weaver_open", false) or GameState.flags.get("vig_weaver_done", false):
		return
	## 流民孩或老兵任一完成后，或已售卖，即可稳定刷出织妇
	var ready := GameState.flags.get("vig_child_done", false) or GameState.flags.get("vig_soldier_done", false) or GameState.flags.get("sold_once", false)
	if not ready:
		return
	GameState.set_flag("weaver_open", true)
	_show_group("weaver_visitor")
	_queue_narration("府门又停了一个女人。袖口有线头，像刚从机杼边扯开。")

func _open_relief() -> void:
	if GameState.flags.get("relief_open", false) or GameState.flags.get("vig_relief_done", false):
		return
	## 天旱后，或织妇/孩/兵任一救助线走过，刷出求赈一家
	var ready := GameState.drought or GameState.flags.get("vig_child_done", false) or GameState.flags.get("vig_weaver_done", false)
	if not ready:
		return
	if not GameState.flags.get("gate_open", false):
		return
	GameState.set_flag("relief_open", true)
	_show_group("relief_visitor")
	_queue_narration("府门外跪着一家流民。孩子的肋骨像算盘珠。")

func _queue_narration(text: String) -> void:
	if Dialogue.is_busy():
		await Dialogue.dialogue_finished
	if Dialogue.is_busy():
		return
	Dialogue.play([{"narration": true, "text": text}])

func on_well_interact() -> void:
	if GameState.flags.get("vig_well_done", false):
		WorldClock.try_rest_at_well()
		var weather_line := "井水清。"
		match WorldClock.weather:
			WorldClock.Weather.RAIN:
				weather_line = "雨脚打在井沿。歇一口气也好。"
			WorldClock.Weather.SNOW:
				weather_line = "井口呵出白气。手暖了，再走。"
			WorldClock.Weather.WIND:
				weather_line = "风大。井边反而静一点。"
			_:
				pass
		Dialogue.play([
			{"narration": true, "text": weather_line + " 小厮的咳声远了，或只是你不愿再听。"},
		])
		return
	if not GameState.flags.get("first_harvest", false):
		WorldClock.try_rest_at_well()
		Dialogue.play([
			{"narration": true, "text": "井绳新，水面旧。先把畦侍候活，再管旁人的咳。——你先歇了歇气力。"},
		])
		return
	Dialogue.choice_made.connect(_on_well_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"narration": true, "text": "柴房方向有人压着嗓子咳。怕传给你，他睡得离井很近。"},
		{"speaker": "小厮", "text": "……王爷别近。药贵。熬粥也行。"},
		{
			"prompt": "井边夜咳。你如何决断？",
			"choices": [
				{"id": "visit", "label": "探望，给两文买粥"},
				{"id": "herb", "label": "若有菜/野菜，分他一棵"},
				{"id": "leave", "label": "默默打水离开"},
			],
		},
	])

func _on_well_choice(choice_id: String) -> void:
	GameState.set_flag("vig_well_done", true)
	GameState.add_memory("MF_A1_WELL_COUGH")
	match choice_id:
		"visit":
			if GameState.money >= 2:
				GameState.add_money(-2)
			GameState.bump_trait("mercy", 2)
			GameState.add_hearts(3)
			Dialogue.play([
				{"speaker": "你", "text": "拿去买粥。别睡风口。"},
				{"speaker": "小厮", "text": "……谢王爷。奴才不敢脏了您的袖。"},
			])
		"herb":
			if GameState.veggies >= 1:
				GameState.add_veggies(-1)
				GameState.bump_trait("mercy", 2)
				GameState.add_hearts(3)
				Dialogue.play([
					{"speaker": "你", "text": "先垫肚子。"},
					{"speaker": "小厮", "text": "……暖。"},
				])
			else:
				GameState.bump_trait("mercy", 1)
				GameState.add_hearts(1)
				Dialogue.play([
					{"narration": true, "text": "筐空。你只能把井水递过去。他笑了一下，像怕咳出来。"},
				])
		"leave":
			Dialogue.play([
				{"narration": true, "text": "水桶沉。咳声被井沿挡住。你告诉自己：先顾畦。"},
			])

func on_npc_talk(npc_id: String) -> void:
	if Dialogue.is_busy():
		return
	match npc_id:
		"aen":
			_talk_aen()
		"wu_bo":
			_talk_wu_bo()
		"qiushui":
			_talk_qiushui()
		"gate_child":
			_talk_gate_child()
		"gate_soldier":
			_talk_gate_soldier()
		"eunuch":
			_talk_eunuch()
		"weaver":
			_talk_weaver()
		"lin_sheng":
			_talk_lin_sheng()
		"zhou":
			_talk_zhou()
		"relief":
			_talk_relief()
		"shen":
			_talk_shen()
		"liu":
			_talk_liu()

func _talk_wu_bo() -> void:
	if not GameState.flags.get("learned_purse", false):
		Dialogue.play([
			{"speaker": "吴伯", "text": "官银有簿，动一分，中使便多问一句。"},
			{"speaker": "吴伯", "text": "这畦是王爷的「私课」。收成进私囊——赈人也好，换锄也好，别写进官簿。"},
			{"speaker": "吴伯", "text": "往后两件事分开办：一是过日子——锄、仓、网药；二是攒人心——赈济、分粮，再到护卫棚。别在一张单子上全勾。"},
			{"speaker": "吴伯", "text": "王爷亲自侍候菜畦，厂卫看来，是无野心、知节俭。坐着享福，反而危险。"},
			{"narration": true, "text": "你明白了：顶上的铜钱，是私囊，不是国库。升级与救人抢同一只袋——得选先做哪条。"},
		])
		GameState.set_flag("learned_purse", true)
		GameState.add_memory("MF_A1_PURSE_LESSON")
		return

	Dialogue.choice_made.connect(_on_wu_bo_root, CONNECT_ONE_SHOT)
	var soft := "私囊软上限约 %d 文。" % WorldClock.effective_soft_cap()
	Dialogue.play([
		{"speaker": "吴伯", "text": "王爷，今日办哪一头？%s 别当逛街。" % soft},
		{
			"prompt": "两轨，别混着办。",
			"choices": [
				{"id": "life", "label": "过日子（锄→仓→网/药）"},
				{"id": "hearts", "label": "人心事（赈济→人心→护卫棚）"},
				{"id": "chat", "label": "问问近况"},
				{"id": "leave", "label": "告退"},
			],
		},
	])

func _on_wu_bo_root(choice_id: String) -> void:
	match choice_id:
		"life":
			_wu_bo_life_menu()
		"hearts":
			_wu_bo_hearts_menu()
		"chat":
			_wu_bo_chat()
		"leave":
			Dialogue.play([{"speaker": "吴伯", "text": "王爷慢走。"}])

## 过日子轨：锄 → 仓 →（可选）网/药。按节点解锁。
func _wu_bo_life_menu() -> void:
	var choices: Array = []
	var hoe_cost := maxi(22, 35 - WorldClock.shop_discount())
	var net_cost := maxi(28, 42 - WorldClock.shop_discount())
	var herb_cost := maxi(35, 50 - WorldClock.shop_discount())

	if not GameState.flags.get("has_hoe", false):
		var hoe_lab := "先换利锄（%d 文）——畦要侍候利索" % hoe_cost
		if GameState.money < hoe_cost:
			hoe_lab = "利锄（需 %d 文）" % hoe_cost
		choices.append({"id": "buy_hoe", "label": hoe_lab})
		choices.append({"id": "why_hoe", "label": "为何先锄？"})
	else:
		if GameState.storage_level < 2:
			var can_storage := GameState.flags.get("sold_once", false) or GameState.inventory_count() >= GameState.storage_cap() - 2 or GameState.storage_level >= 1
			if can_storage:
				var cost := 48 if GameState.storage_level == 0 else 62
				var lab := "扩仓储→%d格（%d 文）" % [14 if GameState.storage_level == 0 else 22, cost]
				if GameState.money < cost:
					lab = "扩仓储（需 %d 文）" % cost
				choices.append({"id": "storage", "label": lab})
			else:
				choices.append({"id": "need_sell", "label": "仓还早（先卖一回，或筐将满再来）"})
		if not GameState.flags.get("has_net", false):
			if GameState.storage_level >= 1 or GameState.drought:
				var net_lab := "买捞网（%d 文）——稳、少、不发财" % net_cost
				if GameState.money < net_cost:
					net_lab = "捞网（需 %d 文）" % net_cost
				choices.append({"id": "buy_net", "label": net_lab})
			else:
				choices.append({"id": "need_net", "label": "捞网尚早（先把仓稳住）"})
		if not GameState.flags.get("herb_unlocked", false):
			if GameState.drought or GameState.flags.get("vig_drought_done", false):
				var herb_lab := "开垦药圃（%d 文）——旱年药贵" % herb_cost
				if GameState.money < herb_cost:
					herb_lab = "药圃（需 %d 文）" % herb_cost
				choices.append({"id": "open_herb", "label": herb_lab})
			else:
				choices.append({"id": "need_herb", "label": "药圃尚早（等天旱，才值）"})

	if choices.is_empty():
		Dialogue.play([
			{"speaker": "吴伯", "text": "过日子这一头，该置的都齐了。剩下的铜钱，留给人心——或留给夜召前的紧。"},
		])
		return

	choices.append({"id": "back", "label": "回到两轨"})
	Dialogue.choice_made.connect(_on_wu_bo_life, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "吴伯", "text": "过日子：锄→仓→网/药。一步有一步的理由，不一口气全买。"},
		{"prompt": "过日子轨", "choices": choices},
	])

func _on_wu_bo_life(choice_id: String) -> void:
	match choice_id:
		"buy_hoe", "buy_net", "open_herb", "storage":
			_on_wu_bo_buy(choice_id)
		"why_hoe":
			Dialogue.play([
				{"speaker": "吴伯", "text": "钝锄耗气力。乱世里，先把眼前这一畦侍候活，再谈仓、再谈网。"},
				{"speaker": "吴伯", "text": "救人的钱也从私囊出——所以锄要买，也不能样样都买。"},
			])
		"need_sell":
			Dialogue.play([{"speaker": "吴伯", "text": "仓是为「装得下」才扩。先卖一回，或筐快满了，再来找我。"}])
		"need_net":
			Dialogue.play([{"speaker": "吴伯", "text": "网是稳口粮。仓都没有，捞了鱼往哪搁？先仓，后网。"}])
		"need_herb":
			Dialogue.play([{"speaker": "吴伯", "text": "天不旱，药圃是闲钱。等井绳变重，再开不迟——那时才叫不得不做。"}])
		"back":
			_talk_wu_bo()
		_:
			_talk_wu_bo()

## 人心轨：吴伯不卖人，只指路。
func _wu_bo_hearts_menu() -> void:
	var choices: Array = [{"id": "how", "label": "人心怎么攒？"}]
	if GameState.flags.get("gate_open", false):
		choices.append({"id": "gate", "label": "府门外还有人吗？"})
	if GameState.hearts >= 16 and GameState.flags.get("guard_intro", false):
		choices.append({"id": "to_guard", "label": "人心够了——去护卫棚"})
	elif GameState.flags.get("guard_intro", false):
		choices.append({"id": "need_hearts", "label": "护卫棚（人心还不够，现 %d/16）" % GameState.hearts})
	choices.append({"id": "back", "label": "回到两轨"})
	Dialogue.choice_made.connect(_on_wu_bo_hearts, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "吴伯", "text": "人心轨：赈济、灶口分粮、善待门外——攒够了，才去护卫棚收人。"},
		{"speaker": "吴伯", "text": "我这里不卖「亲随」。银子能雇人，买不来肯守夜的心。"},
		{"prompt": "人心轨", "choices": choices},
	])

func _on_wu_bo_hearts(choice_id: String) -> void:
	match choice_id:
		"how":
			Dialogue.play([
				{"speaker": "吴伯", "text": "左下府门、灶口分粮、求赈一家——每做一件，人心涨。"},
				{"speaker": "吴伯", "text": "铜钱花在救人上，就少花在锄与仓上。这是乱世里的互斥，不是购物。"},
			])
		"gate":
			Dialogue.play([{"speaker": "吴伯", "text": "去府门听听。给或不给，都是王爷的心。"}])
		"to_guard":
			Dialogue.play([
				{"speaker": "吴伯", "text": "去护卫棚。叫亲随、庄客——切莫叫锦衣。"},
				{"narration": true, "text": "人心轨下一站：护卫棚。"},
			])
		"need_hearts":
			Dialogue.play([{"speaker": "吴伯", "text": "现人心 %d。到十六，棚里才站得住人。先救人，再收人。" % GameState.hearts}])
		"back":
			_talk_wu_bo()
		_:
			_talk_wu_bo()

func _wu_bo_chat() -> void:
	var weather := "%s日·%s。" % [WorldClock.season_name(), WorldClock.weather_name()]
	if WorldClock.disaster != "":
		weather = "天灾·%s。%s" % [WorldClock.disaster_name(), weather]
	elif GameState.drought:
		weather = "天旱，药贵菜也贵。"
	else:
		weather += "天还算抬举。"
	var traits_line := "王爷近来：仁慈%d · 节俭%d · 勤勉%d。" % [
		int(GameState.traits.get("mercy", 0)),
		int(GameState.traits.get("thrift", 0)),
		int(GameState.traits.get("diligence", 0)),
	]
	if int(GameState.traits.get("mercy", 0)) >= 3:
		traits_line += "下人说，王爷眼里有人。"
	elif int(GameState.traits.get("thrift", 0)) >= 3:
		traits_line += "账紧着，厂卫挑不出浪子的话。"
	elif int(GameState.traits.get("diligence", 0)) >= 3:
		traits_line += "畦里的土，认得王爷的手。"
	var track := "过日子：锄%s · 仓%d · 网%s · 药%s。人心 %d → 亲随 %d。" % [
		"✓" if GameState.flags.get("has_hoe", false) else "○",
		GameState.storage_level,
		"✓" if GameState.flags.get("has_net", false) else "○",
		"✓" if GameState.flags.get("herb_unlocked", false) else "○",
		GameState.hearts,
		GameState.guards,
	]
	Dialogue.play([
		{"speaker": "吴伯", "text": "近畿粮紧。锄与赈济抢同一只袋——得选。"},
		{"speaker": "吴伯", "text": weather + " 仓储 %d/%d。气力 %d。" % [GameState.inventory_count(), GameState.storage_cap(), WorldClock.stamina]},
		{"speaker": "吴伯", "text": track},
		{"speaker": "吴伯", "text": traits_line},
	])
	if WorldClock.disaster == "locust" and not GameState.flags.get("vig_locust_done", false):
		Dialogue.dialogue_finished.connect(try_resolve_locust, CONNECT_ONE_SHOT)

func _on_wu_bo_buy(choice_id: String) -> void:
	match choice_id:
		"buy_hoe":
			var hoe_cost := maxi(22, 35 - WorldClock.shop_discount())
			if GameState.money >= hoe_cost and not GameState.flags.get("has_hoe", false):
				GameState.add_money(-hoe_cost)
				GameState.set_flag("has_hoe", true)
				GameState.bump_trait("diligence")
				var thrift_note := "（节俭，少付几文）" if WorldClock.shop_discount() > 0 else ""
				Dialogue.play([
					{"speaker": "吴伯", "text": "拿去。此后畦里少等一会儿。%s" % thrift_note},
					{"speaker": "吴伯", "text": "下一步才是仓。网与药，各有时候——别现在就全勾。"},
					{"narration": true, "text": "利锄入手。过日子轨：锄✓"},
				])
			else:
				Dialogue.play([{"speaker": "吴伯", "text": "钱不够。再卖几畦——但别卖到刺眼。"}])
		"buy_net":
			var net_cost := maxi(28, 42 - WorldClock.shop_discount())
			if GameState.money >= net_cost and not GameState.flags.get("has_net", false):
				GameState.add_money(-net_cost)
				GameState.set_flag("has_net", true)
				GameState.bump_trait("diligence")
				Dialogue.play([
					{"speaker": "吴伯", "text": "网给你。塘里稳，少，不发财。"},
					{"narration": true, "text": "可去鱼塘捞鱼。"},
				])
			else:
				Dialogue.play([{"speaker": "吴伯", "text": "捞网要 %d 文。再等等。" % net_cost}])
		"open_herb":
			var herb_cost := maxi(35, 50 - WorldClock.shop_discount())
			if GameState.money >= herb_cost and not GameState.flags.get("herb_unlocked", false):
				GameState.add_money(-herb_cost)
				GameState.set_flag("herb_unlocked", true)
				GameState.bump_trait("diligence")
				Dialogue.play([
					{"speaker": "吴伯", "text": "旱年开药圃，才叫不得不做。平日开，是浪。"},
					{"narration": true, "text": "新畦有药香的土味。"},
				])
			else:
				Dialogue.play([{"speaker": "吴伯", "text": "开垦要 %d 文。" % herb_cost}])
		"storage":
			_buy_storage()

func _buy_storage() -> void:
	if GameState.storage_level >= 2:
		Dialogue.play([{"speaker": "吴伯", "text": "仓已尽府中能扩的地步。"}])
		return
	var cost := 48 if GameState.storage_level == 0 else 62
	if GameState.money < cost:
		Dialogue.play([{"speaker": "吴伯", "text": "扩仓要 %d 文。先卖几畦——或先救人，别样样都要。" % cost}])
		return
	GameState.add_money(-cost)
	GameState.storage_level += 1
	GameState.bump_trait("thrift")
	GameState.add_memory("MF_A1_STORAGE")
	GameState.toast("仓储扩至 %d 格" % GameState.storage_cap())
	GameState.refresh_objective()
	Dialogue.play([
		{"speaker": "吴伯", "text": "仓板加厚了。扩仓的钱，就不能再雇亲随了——王爷心里有数。"},
		{"narration": true, "text": "容量变为 %d。" % GameState.storage_cap()},
	])

func _talk_eunuch() -> void:
	if not GameState.flags.get("eunuch_open", false):
		return
	if GameState.flags.get("vig_eunuch_done", false):
		Dialogue.play([{"narration": true, "text": "中使的笑还挂在廊下，像没干的漆。"}])
		return
	Dialogue.choice_made.connect(_on_eunuch_choice, CONNECT_ONE_SHOT)
	var choices: Array = [
		{"id": "give", "label": "忍痛给菜（或钱）"},
		{"id": "refuse", "label": "官样拒绝"},
		{"id": "aen", "label": "让阿恩代挡"},
	]
	if GameState.guards >= 1:
		choices.insert(0, {"id": "guard", "label": "亲随挡一挡（少损）"})
	Dialogue.play([
		{"speaker": "中使", "text": "信王好雅兴。路过，借几棵「果子」——不是抢，是借。"},
		{"speaker": "中使", "text": "明年禄米……若顺，便快三旬；若不顺，便慢三旬。笑一笑的事。"},
		{"prompt": "他袖口金线刺眼。你如何决断？", "choices": choices},
	])

func _on_eunuch_choice(choice_id: String) -> void:
	GameState.set_flag("vig_eunuch_done", true)
	GameState.add_memory("MF_A1_EUNUCH_BORROW")
	match choice_id:
		"guard":
			## 亲随可见效益：少损或不损菜，只丢 2 文面子钱
			if GameState.money >= 2:
				GameState.add_money(-2)
			elif GameState.veggies >= 1:
				GameState.add_veggies(-1)
			Dialogue.play([
				{"speaker": "沈戍" if GameState.flags.get("shen_joined", false) else "亲随", "text": "公公，府里紧。这点意思，请回。"},
				{"speaker": "中使", "text": "……哦。王爷府里有人了。"},
				{"narration": true, "text": "亲随挡了一下。损得少。这就是收人的用处。"},
			])
		"give":
			var loss_coin := 6
			var loss_veg := 1
			if GameState.guards >= 2:
				loss_coin = 3
				## 亲随多：中使不敢太狠
			if GameState.veggies >= loss_veg:
				GameState.add_veggies(-loss_veg)
			elif GameState.money >= loss_coin:
				GameState.add_money(-loss_coin)
			var guard_note := "亲随在侧，他少伸了一下手。" if GameState.guards >= 2 else "私囊轻了。廊下却安静些。"
			Dialogue.play([
				{"speaker": "你", "text": "……拿去。记着是借。"},
				{"speaker": "中使", "text": "记着。中使最会记。"},
				{"narration": true, "text": guard_note},
			])
		"refuse":
			GameState.bump_trait("diligence", 1)
			var refuse_line := "……好。好。慢三旬也不过是慢。"
			if GameState.guards >= 1:
				refuse_line = "有人守门，便硬气些。……慢三旬。记住了。"
			Dialogue.play([
				{"speaker": "你", "text": "府中也紧。恕难从命。"},
				{"speaker": "中使", "text": refuse_line},
				{"narration": true, "text": "他笑着退下。你知道账会记在看不见的地方。"},
			])
		"aen":
			GameState.bump_trait("mercy", 1)
			Dialogue.play([
				{"speaker": "阿恩", "text": "公公……园子薄，奴婢替王爷送两棵。别难为殿下。"},
				{"speaker": "中使", "text": "小黄门倒护主。"},
				{"narration": true, "text": "阿恩的袖子被攥皱。你忽然觉得，代挡也是一种债。"},
			])
			GameState.add_memory("MF_A1_AEN_SHIELD")
	_hide_named("NPC_Eunuch")

func on_purse_pressure() -> void:
	if GameState.flags.get("purse_pressure_done", false):
		return
	if GameState.money <= WorldClock.effective_soft_cap():
		return
	if Dialogue.is_busy():
		return
	GameState.set_flag("purse_pressure_done", true)
	var skim := mini(12, GameState.money - WorldClock.effective_soft_cap())
	if GameState.guards >= 2:
		skim = maxi(4, skim / 2)
	if skim > 0:
		GameState.add_money(-skim)
	var thrift_note := ""
	if int(GameState.traits.get("thrift", 0)) >= 3:
		thrift_note = "你平日节俭，眼线少咬一口。"
	Dialogue.play([
		{"narration": true, "text": "廊下多了一双眼睛。私囊太厚，厂卫不必进门——中使会替他们笑。"},
		{"speaker": "吴伯", "text": "王爷，铜钱过了「好看」的数，便有人来「借」。赈济、买锄、收人——总得割舍一样。"},
		{"speaker": "中使", "text": "路过。见王爷丰足，先替宫里「寄存」%d 文。……笑一笑的事。" % skim},
		{"narration": true, "text": ("亲随挡了一半。仍被啃了。" if GameState.guards >= 2 else "私囊被咬了一口。") + thrift_note},
	])

func _talk_gate_child() -> void:
	if not GameState.flags.get("gate_open", false):
		return
	if GameState.flags.get("vig_child_done", false):
		Dialogue.play([{"narration": true, "text": "孩子的脚印浅，风一吹就没有了。"}])
		return
	Dialogue.choice_made.connect(_on_child_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "孩子", "text": "……王爷。娘在城外，不敢进府。求半个菜头。"},
		{"speaker": "孩子", "text": "弟弟比我小。我可以不吃。"},
		{
			"prompt": "孩子袖子破了。你如何决断？",
			"choices": [
				{"id": "veg", "label": "给一棵菜"},
				{"id": "coin", "label": "给三文铜钱"},
				{"id": "shoo", "label": "让吴伯打发走"},
			],
		},
	])

func _on_child_choice(choice_id: String) -> void:
	GameState.set_flag("vig_child_done", true)
	GameState.add_memory("MF_A1_GATE_CHILD")
	match choice_id:
		"veg":
			if GameState.veggies >= 1:
				GameState.add_veggies(-1)
				GameState.bump_trait("mercy", 2)
				Dialogue.play([
					{"speaker": "你", "text": "拿去。藏好。"},
					{"speaker": "孩子", "text": "留给弟弟。他比我小。"},
				])
				GameState.add_hearts(4)
			else:
				GameState.bump_trait("mercy", 1)
				if GameState.money >= 2:
					GameState.add_money(-2)
				GameState.add_hearts(2)
				Dialogue.play([
					{"speaker": "你", "text": "菜没了。……这两文，买粥。"},
					{"speaker": "孩子", "text": "……谢王爷。"},
				])
		"coin":
			if GameState.money >= 3:
				GameState.add_money(-3)
			GameState.bump_trait("mercy", 1)
			GameState.add_hearts(3)
			Dialogue.play([
				{"speaker": "你", "text": "三文。别在府门口停留。"},
				{"speaker": "孩子", "text": "铜钱会响，菜不会。可响的也能换粥。"},
			])
		"shoo":
			Dialogue.play([
				{"speaker": "吴伯", "text": "去去。王府不是粥棚。"},
				{"narration": true, "text": "你没有拦。袖口被风吹得像一张空纸。"},
			])
	_hide_named("NPC_GateChild")
	_maybe_open_weaver()
	_open_relief()

func _talk_weaver() -> void:
	if not GameState.flags.get("weaver_open", false):
		return
	if GameState.flags.get("vig_weaver_done", false):
		Dialogue.play([{"narration": true, "text": "机杼声远了。线头还粘在门槛上。"}])
		return
	Dialogue.choice_made.connect(_on_weaver_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "织妇", "text": "丈夫被点去运粮。求雇一夜纺线，换孩子粥。"},
		{"speaker": "织妇", "text": "王府若用不着……给几文也行。我不是来要饭的。"},
		{
			"prompt": "她的手很稳，眼圈却红。",
			"choices": [
				{"id": "hire", "label": "雇一夜（6 文）"},
				{"id": "coin", "label": "只给三文粥钱"},
				{"id": "refuse", "label": "府中无工可雇"},
			],
		},
	])

func _on_weaver_choice(choice_id: String) -> void:
	GameState.set_flag("vig_weaver_done", true)
	GameState.add_memory("MF_A1_WEAVER")
	match choice_id:
		"hire":
			if GameState.money >= 6:
				GameState.add_money(-6)
			GameState.bump_trait("mercy", 2)
			GameState.add_hearts(4)
			Dialogue.play([
				{"speaker": "你", "text": "今夜纺线。钱先拿去买粥。"},
				{"speaker": "织妇", "text": "……线会整齐。人也会。"},
			])
		"coin":
			if GameState.money >= 3:
				GameState.add_money(-3)
			GameState.bump_trait("mercy", 1)
			GameState.add_hearts(2)
			Dialogue.play([
				{"speaker": "你", "text": "三文。别在门外久留。"},
				{"speaker": "织妇", "text": "谢王爷。机杼还在，人还在。"},
			])
		"refuse":
			Dialogue.play([
				{"speaker": "你", "text": "府中无工。恕难。"},
				{"speaker": "织妇", "text": "……是。那我去别家问问。"},
				{"narration": true, "text": "她走得很直。你忽然觉得「无工」三个字比刀还轻。"},
			])
	_hide_named("NPC_Weaver")
	_open_relief()

func _talk_lin_sheng() -> void:
	if not GameState.flags.get("lin_ready", false):
		Dialogue.play([
			{"speaker": "林生", "text": "王爷先把畦侍候活。邸报……不急在这一时。"},
		])
		return
	if GameState.flags.get("vig_gazette_done", false):
		Dialogue.play([
			{"speaker": "林生", "text": "有些字会咬人。王爷若记得「忠贤」二字，便够了——也够危险了。"},
			{"speaker": "林生", "text": "外头求赈的人多了。王爷若救人，是人心；若收人，是刀——刀要藏在庄客两个字里。"},
		])
		return
	Dialogue.choice_made.connect(_on_gazette_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "林生", "text": "邸报……厂卫。魏上公。王爷，这些字，读完就忘吧。"},
		{"speaker": "你", "text": "忘得掉吗？"},
		{"speaker": "林生", "text": "忘不掉的人，才死得快。"},
		{
			"prompt": "纸边被炉火烤卷。",
			"choices": [
				{"id": "keep", "label": "记住关键词（收残页）"},
				{"id": "burn", "label": "让他塞进炉里"},
			],
		},
	])

func _on_gazette_choice(choice_id: String) -> void:
	GameState.set_flag("vig_gazette_done", true)
	GameState.add_memory("MF_A1_GAZETTE")
	match choice_id:
		"keep":
			GameState.add_memory("MF_A1_WEI_RUMOR")
			Dialogue.play([
				{"narration": true, "text": "你收下残页。字不响，却像在袖里喘气。"},
				{"speaker": "林生", "text": "……王爷小心。"},
			])
		"burn":
			Dialogue.play([
				{"narration": true, "text": "纸成灰。灰比字安全。"},
				{"speaker": "林生", "text": "善。"},
			])
	Dialogue.dialogue_finished.connect(_hide_named.bind("NPC_LinSheng"), CONNECT_ONE_SHOT)

func _talk_gate_soldier() -> void:
	if not GameState.flags.get("gate_open", false):
		return
	if GameState.flags.get("vig_soldier_done", false):
		Dialogue.play([{"narration": true, "text": "刀磨过的痕迹还留在门槛上。"}])
		return
	Dialogue.choice_made.connect(_on_soldier_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "老兵", "text": "刀钝了。想换粮。辽东的雨，和京城一样湿。"},
		{"speaker": "老兵", "text": "饷银……听说还在路上。路上很远。"},
		{
			"prompt": "锈迹爬上刀背。你如何决断？",
			"choices": [
				{"id": "buy", "label": "买下当废铁（8 文）"},
				{"id": "extra", "label": "多给钱，劝他留刀"},
				{"id": "ignore", "label": "不问，路过"},
			],
		},
	])

func _on_soldier_choice(choice_id: String) -> void:
	GameState.set_flag("vig_soldier_done", true)
	GameState.add_memory("MF_A1_OLD_SOLDIER")
	match choice_id:
		"buy":
			if GameState.money >= 8:
				GameState.add_money(-8)
			GameState.bump_trait("mercy", 1)
			GameState.add_hearts(3)
			GameState.set_flag("soldier_loyal", true)
			Dialogue.play([
				{"speaker": "你", "text": "八文。刀留下。"},
				{"speaker": "老兵", "text": "这铁不值钱，命值钱。……若王府缺人守夜，喊一声。"},
			])
		"extra":
			if GameState.money >= 12:
				GameState.add_money(-12)
			elif GameState.money > 0:
				GameState.add_money(-GameState.money)
			GameState.bump_trait("mercy", 2)
			GameState.add_hearts(5)
			GameState.set_flag("soldier_loyal", true)
			Dialogue.play([
				{"speaker": "你", "text": "钱拿着。刀留着。人还要走路。"},
				{"speaker": "老兵", "text": "殿下若坐了殿，别忘了饷。——眼下，我能守门。"},
			])
		"ignore":
			Dialogue.play([
				{"speaker": "老兵", "text": "……打扰了。"},
				{"narration": true, "text": "刀柄咯吱一声。你没有回头。"},
			])
	_hide_named("NPC_GateSoldier")
	_maybe_open_weaver()
	_open_relief()

func _hide_named(node_name: String) -> void:
	var n := get_parent().get_node_or_null(node_name)
	if n == null:
		return
	var ink_id := _ink_id_for_node(node_name)
	if Dialogue.is_busy():
		await Dialogue.dialogue_finished
	if ink_id != "":
		await InkFarewell.play(ink_id)
	else:
		await get_tree().create_timer(0.25).timeout
	if not is_instance_valid(n):
		return
	n.visible = false
	n.set_deferred("monitoring", false)

func _ink_id_for_node(node_name: String) -> String:
	match node_name:
		"NPC_Eunuch":
			return "eunuch"
		"NPC_GateChild":
			return "gate_child"
		"NPC_Weaver":
			return "weaver"
		"NPC_GateSoldier":
			return "gate_soldier"
		"NPC_Relief":
			return "relief"
		"NPC_Qiushui":
			return "qiushui"
		"NPC_LinSheng":
			return "lin_sheng"
		"NPC_Zhou":
			return "zhou"
		"NPC_Shen":
			return "shen"
		"NPC_Liu":
			return "liu"
		_:
			return ""

func _play_ink_seal(character_id: String) -> void:
	## 不离开场景的支线收束：只播水墨定格，不隐藏 NPC。
	if Dialogue.is_busy():
		await Dialogue.dialogue_finished
	await InkFarewell.play(character_id)

func _ensure_shen_liu() -> void:
	if not GameState.flags.get("shen_joined", false):
		GameState.set_flag("shen_joined", true)
		GameState.add_memory("MF_A1_SHEN_JOIN")
	_show_group("lover_npc")

func _talk_shen() -> void:
	if not GameState.flags.get("shen_joined", false):
		Dialogue.play([{"narration": true, "text": "棚还空着。"}])
		return
	if GameState.flags.get("lovers_sugar", false):
		Dialogue.play([
			{"speaker": "沈戍", "text": "王爷安心种地。门我守。柳姑娘……在灶下。"},
			{"speaker": "沈戍", "text": "成亲的话，我们欠着。欠到太平。"},
		])
		return
	if GameState.flags.get("liu_met", false):
		_try_lovers_sugar()
		return
	Dialogue.play([
		{"speaker": "沈戍", "text": "辽东的雨，和京城一样湿。刀钝了，人还在。"},
		{"speaker": "沈戍", "text": "王爷若许，小人做庄客头。——厂卫面前，我们只是看门的。"},
		{"narration": true, "text": "他目光偶尔飘向灶口。那里有人影。"},
	])

func _talk_liu() -> void:
	if not GameState.flags.get("shen_joined", false):
		return
	if not GameState.flags.get("liu_met", false):
		GameState.set_flag("liu_met", true)
		GameState.add_memory("MF_A1_LIU_STOVE")
		Dialogue.play([
			{"speaker": "柳筝", "text": "……王爷。民女柳筝。兄长被点去运粮后，只剩这破筝囊。"},
			{"speaker": "柳筝", "text": "沈戍说府里有粥。民女愿在灶下帮工，不吃白食。"},
			{"narration": true, "text": "筝囊破，弦还在。像人。"},
		])
		return
	if GameState.flags.get("lovers_sugar", false):
		Dialogue.play([
			{"speaker": "柳筝", "text": "糖还有半块。……留给太平。"},
			{"speaker": "柳筝", "text": "王爷若见沈戍偷懒，打他。别打脸——脸要留着见人。"},
		])
		return
	_try_lovers_sugar()

func _try_lovers_sugar() -> void:
	if GameState.flags.get("lovers_sugar", false):
		return
	if not (GameState.flags.get("shen_joined", false) and GameState.flags.get("liu_met", false)):
		return
	GameState.set_flag("lovers_sugar", true)
	GameState.add_memory("MF_A1_LOVERS_SUGAR")
	GameState.add_hearts(3)
	Dialogue.play([
		{"narration": true, "text": "灶口。两人不知道你站在影里——或知道，却顾不得。"},
		{"speaker": "柳筝", "text": "刀上的锈，洗得掉吗？"},
		{"speaker": "沈戍", "text": "洗不掉。像这世道。"},
		{"speaker": "柳筝", "text": "那……人呢？"},
		{"speaker": "沈戍", "text": "人要是也洗不掉，就挨着脏活。"},
		{"speaker": "柳筝", "text": "一半你，一半我。成亲的话——留到太平。"},
		{"speaker": "沈戍", "text": "太平若永远不来呢？"},
		{"speaker": "柳筝", "text": "那就永远欠着。欠着也好过没有。"},
		{"narration": true, "text": "半块粗糖。比宫里的琴简单，也比国运短。"},
	])
	Dialogue.dialogue_finished.connect(_after_lovers_sugar, CONNECT_ONE_SHOT)

func _after_lovers_sugar() -> void:
	await InkFarewell.play("shen")
	await InkFarewell.play("liu")

func _talk_zhou() -> void:
	if GameState.flags.get("met_zhou", false):
		Dialogue.play([
			{"speaker": "周氏", "text": "畦还活着。王爷也还活着。……够了。"},
			{"speaker": "周氏", "text": "救人可以。收人要小心——厂卫的耳朵比井绳还长。"},
		])
		return
	Dialogue.play([
		{"speaker": "周氏", "text": "王爷又蹲在土里。……泥会进指甲缝。"},
		{"speaker": "你", "text": "洗得掉。"},
		{"speaker": "周氏", "text": "有些脏，洗不掉。王爷若只把脏留在园子里，最好。"},
		{"speaker": "周氏", "text": "若有一日府门变宫门……妾希望王爷还记得：人不是折子。"},
		{"narration": true, "text": "王妃袖口沾了一点土。她没有立刻拂掉。"},
	])
	GameState.set_flag("met_zhou", true)
	GameState.add_memory("MF_A1_ZHOU_GARDEN")
	Dialogue.dialogue_finished.connect(_play_ink_seal.bind("zhou"), CONNECT_ONE_SHOT)

func _talk_relief() -> void:
	if not GameState.flags.get("relief_open", false):
		return
	if GameState.flags.get("vig_relief_done", false):
		Dialogue.play([{"narration": true, "text": "求赈的脚印被风抹平。人心却不会。"}])
		return
	Dialogue.choice_made.connect(_on_relief_choice, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "流民男", "text": "王爷……乡里旱穿了。求一勺粥，或半棵菜。"},
		{"speaker": "流民妇", "text": "孩子三日没饱。我们不是盗。盗有刀，我们只有膝盖。"},
		{
			"prompt": "一家三口跪在尘里。你如何决断？",
			"choices": [
				{"id": "food", "label": "开私囊赈粮（菜或钱）"},
				{"id": "hire", "label": "留一个做庄客（收拢人心）"},
				{"id": "shoo", "label": "关门，怕惹厂卫"},
			],
		},
	])

func _on_relief_choice(choice_id: String) -> void:
	GameState.set_flag("vig_relief_done", true)
	GameState.add_memory("MF_A1_RELIEF")
	match choice_id:
		"food":
			if GameState.veggies >= 2:
				GameState.add_veggies(-2)
			elif GameState.money >= 8:
				GameState.add_money(-8)
			elif GameState.veggies >= 1:
				GameState.add_veggies(-1)
			GameState.bump_trait("mercy", 2)
			GameState.add_hearts(6)
			Dialogue.play([
				{"speaker": "你", "text": "拿去。记在私囊——别写官簿。"},
				{"speaker": "流民男", "text": "……谢王爷。我们走远些，不连累府门。"},
				{"narration": true, "text": "人心涨了一寸。护卫棚外的风，轻了一点。"},
			])
		"hire":
			if GameState.guards >= 6:
				GameState.add_hearts(2)
				Dialogue.play([{"speaker": "吴伯", "text": "人满了。先给粮，再谈收人。"}])
			else:
				if GameState.money >= 5:
					GameState.add_money(-5)
				GameState.add_guards(1)
				GameState.add_hearts(5)
				GameState.bump_trait("mercy", 1)
				_ensure_shen_liu()
				Dialogue.play([
					{"speaker": "你", "text": "留一个壮的看守柴房。叫庄客，别叫护卫——更别叫锦衣。"},
					{"speaker": "沈戍", "text": "……小人懂得闭嘴。棚里若缺人，喊沈戍。"},
					{"narration": true, "text": "多了一双会守夜的眼睛。灶下似也多了人影。"},
				])
		"shoo":
			Dialogue.play([
				{"speaker": "吴伯", "text": "去去。王府不是粥厂。"},
				{"narration": true, "text": "门闩落下。远处有孩哭。人心凉了一寸。"},
			])
			GameState.add_hearts(-2)
	_hide_named("NPC_Relief")

func on_guard_post() -> void:
	if not GameState.flags.get("guard_intro", false):
		Dialogue.play([
			{"narration": true, "text": "棚空着。先把日子过明白，再谈收人。"},
		])
		return
	if WorldClock.disaster == "locust" and not GameState.flags.get("vig_locust_done", false):
		try_resolve_locust()
		return
	Dialogue.choice_made.connect(_on_guard_choice, CONNECT_ONE_SHOT)
	var lines: Array = [
		{"speaker": "吴伯", "text": "此处只收「亲随」「庄客」。厂卫面前，他们是看门的——不是刀。"},
		{"narration": true, "text": "人心 %d／亲随 %d。仓储 %d/%d。" % [GameState.hearts, GameState.guards, GameState.inventory_count(), GameState.storage_cap()]},
	]
	var choices: Array = []
	if GameState.flags.get("soldier_loyal", false) and GameState.guards < 6:
		choices.append({"id": "soldier", "label": "召老兵入棚（感念你）"})
	if GameState.hearts >= 16 and GameState.money >= 28 and GameState.guards < 6:
		choices.append({"id": "hire", "label": "花 28 文收一名亲随"})
	elif GameState.guards < 6:
		choices.append({"id": "need", "label": "条件未足（需人心≥16 且 28 文）"})
	choices.append({"id": "status", "label": "只查看"})
	choices.append({"id": "leave", "label": "离开"})
	lines.append({"prompt": "棚里有刀鞘，无官印。", "choices": choices})
	Dialogue.play(lines)

func _on_guard_choice(choice_id: String) -> void:
	match choice_id:
		"soldier":
			GameState.set_flag("soldier_loyal", false)
			GameState.add_guards(1)
			GameState.add_hearts(2)
			GameState.add_memory("MF_A1_RECRUIT_GUARD")
			_ensure_shen_liu()
			Dialogue.play([
				{"speaker": "沈戍", "text": "刀钝，心不钝。我守门。——叫我庄客便好。若王爷信得过，棚里事由我撑着。"},
				{"narration": true, "text": "沈戍成了亲随头。灶下多了一个提水的女子身影。"},
			])
		"hire":
			if GameState.hearts < 16 or GameState.money < 28:
				Dialogue.play([{"speaker": "吴伯", "text": "人心或银子不够。先救人，再收人——二十八文，别跟扩仓抢。"}])
				return
			GameState.add_money(-28)
			GameState.add_guards(1)
			GameState.add_memory("MF_A1_RECRUIT_GUARD")
			_ensure_shen_liu()
			Dialogue.play([
				{"speaker": "吴伯", "text": "人留下了。夜里有人看畦，中使来「借」时也能挡一挡。"},
				{"speaker": "沈戍", "text": "……末将——不，小人沈戍。棚里我来排夜。"},
			])
		"need":
			Dialogue.play([
				{"speaker": "吴伯", "text": "赈济门外、灶口分粮——人心攒到十六，再带二十八文来。钱花在收人，就少花在扩仓。"},
			])
		"status":
			Dialogue.play([
				{"narration": true, "text": "亲随 %d 人。他们认的是私囊里的粥，不是官印。" % GameState.guards},
			])
		"leave":
			Dialogue.play([{"narration": true, "text": "棚外风过。"}])

func _talk_aen() -> void:
	if GameState.flags.get("has_seed_bag", false):
		if not GameState.flags.get("aen_sugar", false):
			GameState.set_flag("aen_sugar", true)
			GameState.add_memory("MF_A1_AEN_SUGAR")
			Dialogue.play([
				{"speaker": "阿恩", "text": "还有这个。粗糖。掰两半。"},
				{"speaker": "阿恩", "text": "一半现在。一半……等王爷哪天哭了再给。"},
				{"narration": true, "text": "甜得很浅。你忽然不想把另一半用掉。"},
			])
			return
		Dialogue.play([
			{"speaker": "阿恩", "text": "谷种收好了。哪天府散了，也能种。"},
			{"speaker": "阿恩", "text": "另一半糖，还在。"},
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
			{"narration": true, "text": "你收下旧谷种。"},
		])
		GameState.set_flag("has_seed_bag", true)
		GameState.add_memory("MF_A1_AEN_PROMISE")
		Dialogue.dialogue_finished.connect(_maybe_crisis_after_aen, CONNECT_ONE_SHOT)
	else:
		Dialogue.play([
			{"speaker": "阿恩", "text": "畦里的土还湿着。王爷走稳些。"},
			{"speaker": "阿恩", "text": "井边、府门、中使……王爷看着办。奴婢只会种地。"},
		])

func _maybe_crisis_after_aen() -> void:
	if not GameState.flags.get("crisis_done", false):
		_start_crisis()

func _talk_qiushui() -> void:
	if GameState.flags.get("qiushui_resolved", false):
		if GameState.flags.get("helped_qiushui", false):
			Dialogue.play([
				{"speaker": "秋穗", "text": "……娘让我还这个。鞋垫。"},
				{"speaker": "秋穗", "text": "娘说，王府的米，要记在膝上，不能只记在嘴上。"},
			])
		else:
			Dialogue.play([{"speaker": "秋穗", "text": "……谢王爷。"}])
		return
	_start_crisis()

func _start_crisis() -> void:
	if GameState.flags.get("crisis_done", false):
		return
	Dialogue.choice_made.connect(_on_crisis_choice, CONNECT_ONE_SHOT)
	var mercy_hint := ""
	if int(GameState.traits.get("mercy", 0)) >= 3:
		mercy_hint = "（她听说过你在府门外给人菜——眼里有光。）"
	Dialogue.play([
		{"speaker": "秋穗", "text": "娘家涝了。……我不敢问赏，只敢问，王府能否借三斗米，来年还。" + mercy_hint},
		{
			"prompt": "秋穗低着头。借满手要 12 文——之后买锄/收人会更紧。",
			"choices": [
				{"id": "help", "label": "借粮相助（12 文）"},
				{"id": "token", "label": "象征性给一点（5 文）"},
				{"id": "refuse", "label": "拒绝（府中也紧）"},
			],
		},
	])

func _on_crisis_choice(choice_id: String) -> void:
	GameState.set_flag("crisis_done", true)
	GameState.set_flag("qiushui_resolved", true)
	match choice_id:
		"help":
			GameState.bump_trait("mercy", 2)
			GameState.add_memory("MF_A1_HELP_QIUSHUI")
			GameState.set_flag("helped_qiushui", true)
			GameState.add_hearts(5)
			var cost := 12
			if int(GameState.traits.get("mercy", 0)) >= 4:
				cost = 10
			if GameState.money >= cost:
				GameState.add_money(-cost)
			var extra := ""
			if int(GameState.traits.get("mercy", 0)) >= 3:
				extra = "娘说，仁慈的主子，米要记在膝上。"
			Dialogue.play([
				{"speaker": "你", "text": "去仓里拨三斗。记在我私囊上——别动官簿。"},
				{"speaker": "秋穗", "text": "……秋穗不敢忘。" + extra},
				{"narration": true, "text": "私囊少了。买锄与收人，得重新算。"},
			])
		"token":
			GameState.bump_trait("mercy", 1)
			GameState.add_hearts(2)
			if GameState.money >= 5:
				GameState.add_money(-5)
			Dialogue.play([
				{"speaker": "你", "text": "先拿这些。……别声张。"},
				{"speaker": "秋穗", "text": "……是。"},
			])
		"refuse":
			GameState.add_memory("MF_A1_REFUSE_QIUSHUI")
			var hard := "……奴婢多嘴了。"
			if int(GameState.traits.get("mercy", 0)) >= 2:
				hard = "……奴婢知王爷平日心软。今日拒了，也是难。"
			Dialogue.play([
				{"speaker": "你", "text": "府中也紧。恕难。"},
				{"speaker": "秋穗", "text": hard},
			])
	Dialogue.dialogue_finished.connect(_after_qiushui_crisis, CONNECT_ONE_SHOT)

func _after_qiushui_crisis() -> void:
	await _hide_named("NPC_Qiushui")
	_check_night_ready()

func _check_night_ready() -> void:
	if GameState.flags.get("night_summon_done", false):
		return
	if GameState.flags.get("first_harvest", false) and GameState.flags.get("has_seed_bag", false) and GameState.flags.get("crisis_done", false):
		await get_tree().create_timer(0.8).timeout
		_start_night_summon()

func _start_night_summon() -> void:
	if GameState.flags.get("night_summon_done", false):
		return
	GameState.set_flag("night_summon_done", true)
	GameState.add_memory("MF_A1_NIGHT_SUMMON")
	get_tree().call_group("act1_world", "begin_night_tint")
	var sugar_line: Dictionary
	if GameState.flags.get("aen_sugar", false):
		sugar_line = {"speaker": "阿恩", "text": "糖……另一半，也带上。宫里未必有这种粗的。"}
	else:
		sugar_line = {"speaker": "阿恩", "text": "带上。旧谷种。"}
	var zhou_echo: Dictionary = {"speaker": "阿恩", "text": "王妃说，人不是折子。……奴婢只会重复这句话。"}
	var lines: Array = [
		{"narration": true, "text": "冬夜。马蹄。灯笼的冷青，压过府里的暖黄。"},
		{"speaker": "中使", "text": "信王接旨——兄台龙驭宾天。请王爷即刻入宫。"},
		{"speaker": "你", "text": "……阿恩。"},
		sugar_line,
	]
	if GameState.flags.get("met_zhou", false):
		lines.append(zhou_echo)
	if GameState.guards > 0:
		lines.append({"narration": true, "text": "亲随守着门。门还在。——灯笼冷青里，这句比圣旨轻，也比圣旨真。"})
		lines.append({"speaker": "吴伯", "text": "有人看家，王爷才能走。这就是收人的用处。"})
	if GameState.flags.get("shen_joined", false):
		lines.append({"speaker": "沈戍", "text": "王爷——棚里的人，小人留下。王妃与柳姑娘，有我。"})
		if GameState.flags.get("lovers_sugar", false):
			lines.append({"speaker": "柳筝", "text": "……糖，我们还欠着。王爷走稳。"})
	lines.append_array([
		{"speaker": "你", "text": "宫里用得着？"},
		{"speaker": "阿恩", "text": "用不着。王爷看着，会记得自己不是从龙椅里长出来的。"},
		{"speaker": "中使", "text": "请。"},
		{"narration": true, "text": "自此无回头。"},
	])
	Dialogue.play(lines)
	Dialogue.dialogue_finished.connect(_go_act1_end, CONNECT_ONE_SHOT)

func _go_act1_end() -> void:
	get_tree().change_scene_to_file("res://scenes/act1/act1_end.tscn")
