extends CanvasLayer
## 对话 UI + 顶部资源条。

@onready var panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/Speaker
@onready var body_label: Label = $DialoguePanel/Margin/VBox/Body
@onready var hint_label: Label = $DialoguePanel/Margin/VBox/Hint
@onready var choice_box: VBoxContainer = $DialoguePanel/Margin/VBox/Choices
@onready var money_label: Label = $HudRoot/Money
@onready var veg_label: Label = $HudRoot/Veggies
@onready var tip_label: Label = $HudRoot/Tip

func _ready() -> void:
	add_to_group("dialogue_ui")
	panel.visible = false
	GameState.money_changed.connect(_on_money)
	GameState.veggies_changed.connect(_on_veg)
	Dialogue.dialogue_finished.connect(hide_dialogue)
	_on_money(GameState.money)
	_on_veg(GameState.veggies)
	tip_label.text = "WASD 移动 · E/空格 互动 · 对话时按空格继续"

func _on_money(v: int) -> void:
	money_label.text = "铜钱 %d" % v

func _on_veg(v: int) -> void:
	veg_label.text = "菜蔬 %d" % v

func show_line(item: Dictionary) -> void:
	panel.visible = true
	_clear_choices()
	var narration: bool = bool(item.get("narration", false))
	var speaker: String = str(item.get("speaker", ""))
	if narration or speaker == "":
		speaker_label.text = "旁白"
		speaker_label.modulate = Color(0.45, 0.4, 0.35)
	else:
		speaker_label.text = speaker
		speaker_label.modulate = Color(0.25, 0.2, 0.15)
	body_label.text = str(item.get("text", ""))
	hint_label.text = "空格 / E 继续"
	hint_label.visible = true

func show_choices(prompt: String, choices: Array) -> void:
	panel.visible = true
	speaker_label.text = "抉择"
	speaker_label.modulate = Color(0.5, 0.15, 0.1)
	body_label.text = prompt
	hint_label.visible = false
	_clear_choices()
	for c in choices:
		var btn := Button.new()
		btn.text = str(c.get("label", c.get("id", "?")))
		var cid := str(c.get("id", ""))
		btn.pressed.connect(func(): Dialogue.notify_choice(cid))
		choice_box.add_child(btn)

func _clear_choices() -> void:
	for child in choice_box.get_children():
		child.queue_free()

func hide_dialogue() -> void:
	panel.visible = false
	_clear_choices()
