extends Interactable
## 可采灌木：每局一次野菜（轻收集）。

@export var already_picked: bool = false

@onready var _visual: Node2D = get_node_or_null("Visual")

func _ready() -> void:
	interact_priority = 1
	prompt_text = "采野菜"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_visual()

func interact() -> void:
	if already_picked:
		Dialogue.play([
			{"narration": true, "text": "枝叶空了。要等下一季。"},
		])
		return
	if WorldClock.disaster == "locust":
		Dialogue.play([
			{"narration": true, "text": "蝗过之处，灌木也被啃光。"},
		])
		already_picked = true
		prompt_text = "空枝"
		_refresh_visual()
		return
	if not WorldClock.spend_stamina(1):
		return
	already_picked = true
	prompt_text = "空枝"
	var n := 1 + WorldClock.forage_bonus()
	GameState.add_veggies(n)
	GameState.bump_trait("diligence")
	Sfx.play("forage")
	var rain_note := "春雨润过，野菜更肥。" if n > 1 else "不值钱，但能填一口锅。"
	Dialogue.play([
		{"narration": true, "text": "墙根野菜一握。" + rain_note},
	])
	_refresh_visual()

func _refresh_visual() -> void:
	if _visual and _visual.has_method("set_picked"):
		_visual.call("set_picked", already_picked)
	elif _visual:
		_visual.queue_redraw()
