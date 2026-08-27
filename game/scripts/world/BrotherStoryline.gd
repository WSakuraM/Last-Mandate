extends Node
# 朱由检 × 朱由校（天启）兄弟线：第一幕三拍。
# 【史】兄崩弟继、天启无嗣、木匠皇帝；【戏】情感铺垫「为何是信王」。
# b1 御信木样 → b2 御驾亲访（府内对话）→ b3 病榻嘱咐。

signal beat_completed(beat_id: String)

const GOLD := Color(0.95, 0.8, 0.4)

var overlay: CanvasLayer
var _current_beat := ""
var _emperor_node: Node3D

var _beats := {
	"b1": {
		"title": "御信 · 木样小雀",
		"text": "府门前来的是内廷司礼监的牌子，不是中使，是送东西的。\n\n漆盒里卧着一只木雕小雀，翅纹是按着御制木样刻的——毛羽不齐，刀口却极细。\n\n信里只有寥寥数行，是兄长的笔，略歪，像一边写字一边还在掂量刨子：\n\n「五弟：朕在养心殿又刻坏了一只。这只给你。你在府里种你的菜，别学朕把天下当榫卯。——校」\n\n吴伯捧着盒子，半晌才说：「……皇上还惦记您。」",
		"memory_id": "MF_A1_BROTHER_GIFT",
		"memory_weight": 6,
		"memory_pillar": "Ⅰ",
		"memory_text": "兄长按木样雕的小雀——「别学朕把天下当榫卯」",
		"flag": "brother_b1_done",
	},
	"b2": {
		"title": "御驾 · 至府",
		"text": "仲夏午后，府门外忽然静了。\n\n不是没声音，是所有人都不敢出声。吴伯跪在阶下，沈戍把棍提得笔直，连畜栏里的鸡都不叫了。\n\n内侍滚下来报：「信王，圣驾到了——皇上要亲自来看您的园子。」\n\n你整理衣冠出迎时，远远看见黄绫在府门内一闪。这一回，不是信，也不是召你入宫。是兄长本人，踏进了你这座小小的信王府。",
		"flag": "",
	},
	"b3": {
		"title": "病榻 · 托付",
		"text": "这一次不是信，是急召。你入乾清宫时，殿里药气很苦。\n\n兄长朱由校躺在枕上，脸瘦得脱了形，却仍强撑着那副熟悉的、有点孩子气的笑：\n\n「五弟来了？……朕知道你在怕什么。诸弟之中，朕从未想过把江山交给旁人。」\n\n他咳了一阵，攥住你的腕：\n\n「皇子……都早夭了。祖制在此，朕崩之后，当由你入继。不是朕赐，是大明只剩下这条路。」\n\n「魏阉在侧，你须小心。可你……比朕更像一个皇帝。朕只会做木匠。你把天下……接稳了。」\n\n你想说什么，他先摆摆手：「去。回府。把园子里的菜种好。朕……还想再吃你府上送的一次春菜。」\n\n那是你最后一次听见他叫你的名字。",
		"memory_id": "MF_A1_BROTHER_WORSE",
		"memory_weight": 9,
		"memory_pillar": "Ⅰ",
		"memory_text": "病榻托付——「皇子早夭，祖制只剩你这条路」",
		"flag": "brother_b3_done",
	},
}


func _ready() -> void:
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func trigger(beat_id: String) -> void:
	if _current_beat != "":
		return
	if IssueManager.flags.get("brother_%s_done" % beat_id, false) and beat_id != "b2":
		return
	if beat_id == "b2" and IssueManager.flags.get("brother_b2_done", false):
		return
	if not _beats.has(beat_id):
		return
	var b: Dictionary = _beats[beat_id]
	if beat_id != "b2" and IssueManager.flags.get(b.get("flag", ""), false):
		return
	_current_beat = beat_id
	_show_card(beat_id)


func _show_card(beat_id: String) -> void:
	var b: Dictionary = _beats[beat_id]
	IssueManager.night_council_active = true
	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.custom_minimum_size = Vector2(580, 320)
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.12, 0.1, 0.08, 0.97)
	cs.border_color = GOLD
	cs.border_width_left = 2
	cs.border_width_top = 2
	cs.border_width_right = 2
	cs.border_width_bottom = 2
	cs.corner_radius_top_left = 6
	cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_left = 6
	cs.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", cs)
	root.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.add_theme_constant_override("margin_left", 22)
	vb.add_theme_constant_override("margin_top", 22)
	vb.add_theme_constant_override("margin_right", 22)
	vb.add_theme_constant_override("margin_bottom", 22)
	card.add_child(vb)

	var title := Label.new()
	title.text = b.get("title", "")
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	vb.add_child(title)

	vb.add_child(HSeparator.new())

	var txt := Label.new()
	txt.text = b.get("text", "")
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 16)
	txt.add_theme_color_override("font_color", Color(0.85, 0.82, 0.78))
	vb.add_child(txt)

	var hint := Label.new()
	hint.text = "（按 E 继续）"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.58, 0.55))
	vb.add_child(hint)

	if beat_id != "b2":
		var mid: String = b.get("memory_id", "")
		if mid != "":
			IssueManager.add_memory(mid, int(b.get("memory_weight", 5)), \
				b.get("memory_text", ""), b.get("memory_pillar", "Ⅰ"))
		var fl: String = b.get("flag", "")
		if fl != "":
			IssueManager.flags[fl] = true

	var t := Timer.new()
	t.wait_time = 12.0
	t.one_shot = true
	t.timeout.connect(_dismiss)
	add_child(t)
	t.start()
	set_process(true)


func _process(_delta: float) -> void:
	if overlay and Input.is_key_pressed(KEY_E):
		_dismiss()


func _dismiss() -> void:
	if overlay:
		overlay.queue_free()
		overlay = null
	set_process(false)
	var b := _current_beat
	_current_beat = ""
	if b == "b2":
		_begin_b2_dialogue()
		return
	if b != "":
		IssueManager.night_council_active = false
		beat_completed.emit(b)


func _begin_b2_dialogue() -> void:
	_spawn_emperor()
	EventBus.zone_entered.emit("御驾在府")
	EventBus.dialogue_request.emit("DLG_A1_BROTHER_VISIT")


func _spawn_emperor() -> void:
	_despawn_emperor()
	var world := get_parent()
	if world == null:
		return
	_emperor_node = CourtyardProps.make_emperor_visit(CourtyardLayout.BROTHER_VISIT, -12.0)
	world.add_child(_emperor_node)


func _despawn_emperor() -> void:
	if _emperor_node and is_instance_valid(_emperor_node):
		_emperor_node.queue_free()
	_emperor_node = null


func _on_dialogue_finished(dialogue_id: String, result: Dictionary) -> void:
	if dialogue_id != "DLG_A1_BROTHER_VISIT":
		return
	if IssueManager.flags.get("brother_b2_done", false):
		return
	if result.get("choice", "") == "share_quiet":
		IssueManager.flags["farm_yield_boost_season"] = (ResourceManager.season + 1) % 4
		EventBus.narration.emit("兄长记下了你的园——下一季菜收 +10%")
	IssueManager.flags["brother_b2_done"] = true
	_despawn_emperor()
	beat_completed.emit("b2")
