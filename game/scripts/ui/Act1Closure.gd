extends CanvasLayer
# 第一幕收束画面：信王时期（压缩 150 游戏日）走到尽头，天启崩、信王入继。
# 展示本幕回忆碎片汇总与资源盘点，给出「重玩第一幕」与「预演煤山终章」两个去向。
# 第二幕（朝堂）与第三幕（煤山）在别处打磨，此处仅留占位说明。

const GOLD := Color(0.95, 0.8, 0.4)

func show_closure():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.92)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vb.add_theme_constant_override("separation", 14)
	root.add_child(vb)

	var t1 := Label.new()
	t1.text = "第一幕 · 信王府 · 终"
	t1.add_theme_font_size_override("font_size", 38)
	t1.add_theme_color_override("font_color", GOLD)
	vb.add_child(t1)

	var t2 := Label.new()
	t2.text = "天启七年冬。你走出信王府的那一夜，园子、夜召与门外的人，都已收进回忆。"
	t2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t2.add_theme_font_size_override("font_size", 17)
	t2.add_theme_color_override("font_color", Color(0.8, 0.77, 0.72))
	vb.add_child(t2)

	var sep := HSeparator.new()
	vb.add_child(sep)

	# 回忆碎片汇总（终章蒙太奇预览，8条，Ⅲ类优先 + 支柱着色）
	var mem_label := Label.new()
	var n := IssueManager.memories.size()
	mem_label.text = "本幕拾得回忆碎片 ×%d（终章蒙太奇抽 8 条）" % n
	mem_label.add_theme_font_size_override("font_size", 18)
	mem_label.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(mem_label)

	var montage := IssueManager.draw_montage(8)
	for m in montage:
		var ml := Label.new()
		ml.text = "· " + str(m.get("text", ""))
		ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ml.add_theme_font_size_override("font_size", 15)
		# 按支柱着色：Ⅲ人民疾苦（暖红）/ Ⅱ朝堂国事（冷灰）/ Ⅰ信王个人（暗灰）
		var pillar: String = str(m.get("pillar", "Ⅰ"))
		match pillar:
			"Ⅲ":
				ml.add_theme_color_override("font_color", Color(0.65, 0.48, 0.42))
			"Ⅱ":
				ml.add_theme_color_override("font_color", Color(0.5, 0.55, 0.62))
			_:
				ml.add_theme_color_override("font_color", Color(0.62, 0.6, 0.56))
		vb.add_child(ml)

	var sep2 := HSeparator.new()
	vb.add_child(sep2)

	# 资源盘点 + 私囊结余
	var st := ResourceManager.get_state()
	var res := "国库 %.0f · 民心 %.0f · 边军 %.0f · 朝堂 %.0f · 君心 %.0f · 气数 %.1f" % [
		st["treasury"], st["people"], st["border_army"], st["court_order"], st["emperor_heart"], st["mandate_decay"]
	]
	var rl := Label.new()
	rl.text = res
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rl.add_theme_font_size_override("font_size", 15)
	rl.add_theme_color_override("font_color", Color(0.7, 0.68, 0.64))
	vb.add_child(rl)

	# 私囊结余 → 第二幕登基国库种子
	var act2_seed: float = ResourceManager.finalize_act1_treasury_seed()
	var purse_label := Label.new()
	var kind_note := ""
	if IssueManager.flags.get("kind_likely", false):
		kind_note = "（含〔仁慈〕+%.0f）" % ResourceManager.KIND_TRAIT_SEED_BONUS
	purse_label.text = "私囊结余  %.0f 兩 · 登基充入国库  +%.1f%s" % [st["private_purse"], act2_seed, kind_note]
	purse_label.add_theme_font_size_override("font_size", 16)
	purse_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	vb.add_child(purse_label)

	var seed_note := Label.new()
	seed_note.text = "（第二幕起始国库将叠加此笔信王积蓄，上限 %.0f）" % ResourceManager.ACT2_TREASURY_SEED_CAP
	seed_note.add_theme_font_size_override("font_size", 13)
	seed_note.add_theme_color_override("font_color", Color(0.62, 0.58, 0.50))
	vb.add_child(seed_note)

	# 仁慈 Trait 显示（M1A4 秋穗家书选择借粮时获得）
	if IssueManager.flags.get("kind_likely", false):
		var trait_label := Label.new()
		trait_label.text = "〔仁慈〕——一幕的善念，会在二幕发芽"
		trait_label.add_theme_font_size_override("font_size", 15)
		trait_label.add_theme_color_override("font_color", Color(0.7, 0.82, 0.6))
		vb.add_child(trait_label)

	# 区块三·支线完成汇总
	var sl_b1 := "✓" if IssueManager.flags.get("shenliu_b1_done", false) else "—"
	var sl_b2 := "✓" if IssueManager.flags.get("shenliu_b2_done", false) else "—"
	var sl_b3 := "✓" if IssueManager.flags.get("shenliu_b3_done", false) else "—"
	var zs := "✓" if IssueManager.flags.get("zhoushi_met_act1", false) else "—"
	var eu := "✓" if (IssueManager.flags.get("eunuch_complied", false) or IssueManager.flags.get("eunuch_refused", false)) else "—"
	var cal := "✓" if IssueManager.flags.get("calamity_triggered", false) else "—"
	var br1 := "✓" if IssueManager.flags.get("brother_b1_done", false) else "—"
	var br2 := "✓" if IssueManager.flags.get("brother_b2_done", false) else "—"
	var br3 := "✓" if IssueManager.flags.get("brother_b3_done", false) else "—"
	var ss_label := Label.new()
	ss_label.text = "支线 · 沈柳[%s%s%s] · 周氏[%s] · 中使[%s] · 天灾[%s] · 兄弟[%s%s%s]" % [sl_b1, sl_b2, sl_b3, zs, eu, cal, br1, br2, br3]
	ss_label.add_theme_font_size_override("font_size", 14)
	ss_label.add_theme_color_override("font_color", Color(0.65, 0.63, 0.6))
	vb.add_child(ss_label)

	# ACT1_END 全量存档：Traits + 五资源快照 + 回忆标记 + 旗标 + 私囊结余 + 谷种道具 + 支线进度
	var save_data := {
		"act": 1,
		"resources": st,
		"memories": IssueManager.memories,
		"flags": IssueManager.flags,
		"private_purse": ResourceManager.private_purse,
		"act2_treasury_seed": act2_seed,
		"grain_seed": IssueManager.flags.get("aen_seed_given", false),
		"kind_likely": IssueManager.flags.get("kind_likely", false),
		"shenliu_progress": {
			"b1": IssueManager.flags.get("shenliu_b1_done", false),
			"b2": IssueManager.flags.get("shenliu_b2_done", false),
			"b3": IssueManager.flags.get("shenliu_b3_done", false),
		},
		"eunuch_refused": IssueManager.flags.get("eunuch_refused", false),
		"calamity": IssueManager.flags.get("calamity_triggered", false),
		"brother_progress": {
			"b1": IssueManager.flags.get("brother_b1_done", false),
			"b2": IssueManager.flags.get("brother_b2_done", false),
			"b3": IssueManager.flags.get("brother_b3_done", false),
		},
	}
	SaveManager.save_state(save_data)

	var note := Label.new()
	note.text = "（第二幕 · 朝堂 与 第三幕 · 煤山 尚在打磨中）"
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vb.add_child(note)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	vb.add_child(btn_row)

	var b_replay := Button.new()
	b_replay.text = "重玩第一幕"
	b_replay.custom_minimum_size = Vector2(160, 44)
	b_replay.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
	)
	btn_row.add_child(b_replay)

	var b_meishan := Button.new()
	b_meishan.text = "预演煤山终章"
	b_meishan.custom_minimum_size = Vector2(160, 44)
	b_meishan.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/world/Meishan.tscn")
	)
	btn_row.add_child(b_meishan)
