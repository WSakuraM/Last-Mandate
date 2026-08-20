extends CanvasLayer
## 对话 UI + 资源条 + 目标提示 + Toast（风格 C 正式木框）。

@onready var panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/Speaker
@onready var body_label: Label = $DialoguePanel/Margin/VBox/Body
@onready var hint_label: Label = $DialoguePanel/Margin/VBox/Hint
@onready var choice_box: VBoxContainer = $DialoguePanel/Margin/VBox/Choices
@onready var money_label: Label = $HudRoot/PanelMoney/VBox/Money
@onready var veg_label: Label = $HudRoot/PanelMoney/VBox/Veggies
@onready var fish_label: Label = $HudRoot/PanelMoney/VBox/Fish
@onready var herb_label: Label = $HudRoot/PanelMoney/VBox/Herbs
@onready var stock_label: Label = $HudRoot/PanelMoney/VBox/Stock
@onready var hearts_label: Label = $HudRoot/PanelMoney/VBox/Hearts
@onready var guards_label: Label = $HudRoot/PanelMoney/VBox/Guards
@onready var objective_label: Label = $HudRoot/Objective
@onready var toast_label: Label = $HudRoot/Toast
@onready var tip_label: Label = $HudRoot/Tip

var _side_label: Label
var _clock_label: Label
var _toast_left: float = 0.0
var _portrait_swatch: ColorRect
var _portrait_tex: TextureRect
var _toast_panel: PanelContainer

func _ready() -> void:
	add_to_group("dialogue_ui")
	panel.visible = false
	toast_label.visible = false
	_apply_ui_frames()
	_ensure_extra_labels()
	GameState.money_changed.connect(_on_money)
	GameState.veggies_changed.connect(_on_veg)
	GameState.fish_changed.connect(_on_fish)
	GameState.herbs_changed.connect(_on_herbs)
	GameState.hearts_changed.connect(_on_hearts)
	GameState.guards_changed.connect(_on_guards)
	GameState.flags_changed.connect(_refresh_all)
	GameState.objective_changed.connect(_refresh_objective)
	GameState.toast_requested.connect(show_toast)
	WorldClock.stamina_changed.connect(_refresh_objective)
	WorldClock.day_changed.connect(_refresh_objective)
	WorldClock.weather_changed.connect(_refresh_objective)
	WorldClock.disaster_changed.connect(_refresh_objective)
	Dialogue.dialogue_finished.connect(hide_dialogue)
	_refresh_all()
	_refresh_objective()
	tip_label.text = "WASD 移动 · E/空格 互动 · 署名：schwarnhild · Oddblot · Kenney"

func _apply_ui_frames() -> void:
	var money := $HudRoot/PanelMoney as PanelContainer
	if money:
		money.add_theme_stylebox_override("panel", StyleC.wood_panel())
		money.offset_bottom = 210.0
	panel.add_theme_stylebox_override("panel", StyleC.dialogue_panel())
	speaker_label.add_theme_color_override("font_color", StyleC.UI_ZHU)
	body_label.add_theme_color_override("font_color", StyleC.UI_INK)
	hint_label.add_theme_color_override("font_color", Color(0.5, 0.42, 0.35, 1))

	## 目标木条
	StyleC.wrap_in_panel($HudRoot, objective_label, StyleC.slim_panel(), Vector2(260, 12), Vector2(700, 38), "ObjectivePanel")
	objective_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0))
	objective_label.add_theme_constant_override("outline_size", 0)

	## Toast 木框
	_toast_panel = StyleC.wrap_in_panel($HudRoot, toast_label, StyleC.toast_panel(), Vector2(440, 300), Vector2(400, 52), "ToastPanel")
	_toast_panel.visible = false
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	## 底栏提示
	StyleC.wrap_in_panel($HudRoot, tip_label, StyleC.tip_panel(), Vector2(18, 668), Vector2(640, 32), "TipPanel")
	tip_label.add_theme_constant_override("outline_size", 0)

	_setup_portrait_row()

func _setup_portrait_row() -> void:
	var vbox := $DialoguePanel/Margin/VBox as VBoxContainer
	var existing := vbox.get_node_or_null("PortraitRow")
	if existing != null:
		_portrait_tex = existing.get_node_or_null("PortraitFrame/PortraitTex") as TextureRect
		_portrait_swatch = existing.get_node_or_null("PortraitFrame/Portrait") as ColorRect
		return
	var row := HBoxContainer.new()
	row.name = "PortraitRow"
	row.add_theme_constant_override("separation", 14)
	vbox.add_child(row)
	vbox.move_child(row, 0)

	var frame := PanelContainer.new()
	frame.name = "PortraitFrame"
	frame.custom_minimum_size = Vector2(96, 96)
	frame.add_theme_stylebox_override("panel", StyleC.portrait_frame())
	row.add_child(frame)

	_portrait_tex = TextureRect.new()
	_portrait_tex.name = "PortraitTex"
	_portrait_tex.custom_minimum_size = Vector2(84, 96)
	_portrait_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(_portrait_tex)

	_portrait_swatch = ColorRect.new()
	_portrait_swatch.name = "Portrait"
	_portrait_swatch.custom_minimum_size = Vector2(84, 96)
	_portrait_swatch.color = Color(0.7, 0.62, 0.5, 1)
	_portrait_swatch.visible = false
	frame.add_child(_portrait_swatch)

	var title_wrap := VBoxContainer.new()
	title_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_wrap)
	vbox.remove_child(speaker_label)
	title_wrap.add_child(speaker_label)

func _ensure_extra_labels() -> void:
	_clock_label = get_node_or_null("HudRoot/Clock") as Label
	if _clock_label == null:
		_clock_label = Label.new()
		_clock_label.name = "Clock"
		$HudRoot.add_child(_clock_label)
		_clock_label.add_theme_font_size_override("font_size", 14)
		_clock_label.add_theme_color_override("font_color", StyleC.UI_INK)
	## 时钟木框（右上）
	if get_node_or_null("HudRoot/ClockPanel") == null:
		StyleC.wrap_in_panel($HudRoot, _clock_label, StyleC.slim_panel(), Vector2(980, 12), Vector2(280, 36), "ClockPanel")

	_side_label = get_node_or_null("HudRoot/SideHint") as Label
	if _side_label == null:
		_side_label = Label.new()
		_side_label.name = "SideHint"
		$HudRoot.add_child(_side_label)
		_side_label.position = Vector2(260, 56)
		_side_label.size = Vector2(700, 28)
		_side_label.add_theme_font_size_override("font_size", 13)
		_side_label.add_theme_color_override("font_color", Color(0.35, 0.28, 0.2, 1))

func _process(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		var a := clampf(_toast_left / 0.4, 0.0, 1.0)
		if _toast_panel:
			_toast_panel.modulate.a = a
		toast_label.modulate.a = a
		if _toast_left <= 0.0:
			toast_label.visible = false
			if _toast_panel:
				_toast_panel.visible = false

func _on_money(_v: int = 0) -> void:
	_refresh_money_label()

func _refresh_all(_v: int = 0) -> void:
	_refresh_money_label()
	_on_veg(GameState.veggies)
	_on_fish(GameState.fish)
	_on_herbs(GameState.herbs)
	_on_hearts(GameState.hearts)
	_on_guards(GameState.guards)
	_refresh_stock()
	_refresh_objective()

func _refresh_money_label() -> void:
	var prefix := "私囊铜钱" if GameState.flags.get("learned_purse", false) else "铜钱"
	money_label.text = "%s %d" % [prefix, GameState.money]

func _refresh_stock() -> void:
	stock_label.text = "仓储 %d/%d" % [GameState.inventory_count(), GameState.storage_cap()]

func _on_veg(v: int) -> void:
	veg_label.text = "菜蔬 %d" % v
	_refresh_stock()

func _on_fish(v: int) -> void:
	fish_label.text = "鱼 %d" % v
	_refresh_stock()

func _on_herbs(v: int) -> void:
	herb_label.text = "药材 %d" % v
	_refresh_stock()

func _on_hearts(v: int) -> void:
	hearts_label.text = "人心 %d" % v

func _on_guards(v: int) -> void:
	guards_label.text = "亲随 %d" % v

func _refresh_objective() -> void:
	objective_label.text = GameState.get_objective()
	if _side_label:
		_side_label.text = GameState.get_side_hint()
	if _clock_label:
		_clock_label.text = WorldClock.clock_label()

func show_toast(text: String) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_label.modulate.a = 1.0
	if _toast_panel:
		_toast_panel.visible = true
		_toast_panel.modulate.a = 1.0
	_toast_left = 1.6

func show_line(item: Dictionary) -> void:
	panel.visible = true
	_clear_choices()
	Sfx.play("dialogue")
	var narration: bool = bool(item.get("narration", false))
	var speaker: String = str(item.get("speaker", ""))
	if narration or speaker == "":
		speaker_label.text = "旁白"
		speaker_label.modulate = Color(0.45, 0.4, 0.35)
		_set_portrait_for_speaker("")
	else:
		speaker_label.text = speaker
		speaker_label.modulate = Color(0.25, 0.2, 0.15)
		_set_portrait_for_speaker(speaker)
	body_label.text = str(item.get("text", ""))
	hint_label.text = "空格 / E 继续"
	hint_label.visible = true

func show_choices(prompt: String, choices: Array) -> void:
	panel.visible = true
	Sfx.play("click")
	speaker_label.text = "抉择"
	speaker_label.modulate = Color(0.5, 0.15, 0.1)
	_set_portrait_for_speaker("")
	_set_portrait_color(StyleC.UI_ZHU)
	body_label.text = prompt
	hint_label.visible = false
	_clear_choices()
	for c in choices:
		var btn := Button.new()
		btn.text = str(c.get("label", c.get("id", "?")))
		var cid := str(c.get("id", ""))
		StyleC.apply_button(btn)
		btn.pressed.connect(func(): Dialogue.notify_choice(cid))
		choice_box.add_child(btn)

func hide_dialogue() -> void:
	panel.visible = false
	_clear_choices()

func _clear_choices() -> void:
	for c in choice_box.get_children():
		c.queue_free()

func _set_portrait_for_speaker(speaker: String) -> void:
	var id := _speaker_id(speaker)
	var tex: Texture2D = null
	if id != "":
		tex = AssetBank.load_texture("characters", id + ".png")
	if _portrait_tex:
		if tex:
			_portrait_tex.texture = tex
			_portrait_tex.visible = true
			if _portrait_swatch:
				_portrait_swatch.visible = false
			return
		_portrait_tex.texture = null
		_portrait_tex.visible = false
	_set_portrait_color(_speaker_color(speaker) if speaker != "" else Color(0.75, 0.7, 0.62, 1))

func _set_portrait_color(c: Color) -> void:
	if _portrait_swatch:
		_portrait_swatch.visible = true
		_portrait_swatch.color = c

func _speaker_id(speaker: String) -> String:
	match speaker:
		"阿恩", "王承恩":
			return "aen"
		"吴伯":
			return "wu_bo"
		"王妃", "周氏":
			return "zhou"
		"秋穗":
			return "qiushui"
		"林生":
			return "lin_sheng"
		"中使":
			return "eunuch"
		"沈戍":
			return "shen"
		"柳筝":
			return "liu"
		"你", "信王", "王爷":
			return "wang"
		"孩子", "流民童":
			return "gate_child"
		"老兵":
			return "gate_soldier"
		"流民男", "求赈":
			return "relief"
		"织坊", "织女":
			return "weaver"
		_:
			return ""

func _speaker_color(speaker: String) -> Color:
	match speaker:
		"阿恩", "王承恩":
			return Color(0.55, 0.48, 0.42, 1)
		"吴伯":
			return Color(0.42, 0.48, 0.55, 1)
		"王妃", "周氏":
			return Color(0.48, 0.42, 0.55, 1)
		"秋穗":
			return Color(0.62, 0.45, 0.48, 1)
		"林生":
			return Color(0.4, 0.45, 0.55, 1)
		"中使":
			return Color(0.55, 0.35, 0.4, 1)
		"沈戍":
			return Color(0.32, 0.36, 0.34, 1)
		"柳筝":
			return Color(0.55, 0.42, 0.4, 1)
		"你", "信王", "王爷":
			return Color(0.38, 0.32, 0.55, 1)
		_:
			return Color(0.7, 0.62, 0.5, 1)
