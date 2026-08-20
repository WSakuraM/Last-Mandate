extends Interactable
## 药圃：解锁后可种；旱年更值钱。

enum Stage { LOCKED, EMPTY, PLANTED, READY }

@export var grow_seconds: float = 5.5

var stage: Stage = Stage.LOCKED
var _timer: float = 0.0

@onready var _visual: Node2D = $Visual

func _ready() -> void:
	interact_priority = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.flags_changed.connect(_sync_lock)
	_sync_lock()

func _sync_lock() -> void:
	if GameState.flags.get("herb_unlocked", false):
		if stage == Stage.LOCKED:
			stage = Stage.EMPTY
		visible = true
		monitoring = true
		prompt_text = "药圃·播种"
	else:
		stage = Stage.LOCKED
		prompt_text = "药圃（未开垦）"
		## 仍可互动以听到提示
		visible = true
		monitoring = true
	_refresh()

func _process(delta: float) -> void:
	if stage != Stage.PLANTED:
		return
	_timer += delta
	var need := grow_seconds * GameState.get_grow_multiplier()
	var pct := clampi(int((_timer / need) * 100.0), 0, 99)
	prompt_text = "药材生长 %d%%" % pct
	if _timer >= need:
		stage = Stage.READY
		_timer = 0.0
		prompt_text = "采药"
		GameState.toast("药材熟了")
		_refresh()

func interact() -> void:
	if stage == Stage.LOCKED:
		Dialogue.play([
			{"narration": true, "text": "这块土还荒着。吴伯说，开药圃要银子，也要方子。"},
			{"speaker": "吴伯", "text": "四十文开垦。旱年药贵——值得。"},
		])
		return
	match stage:
		Stage.EMPTY:
			if not WorldClock.spend_stamina(1):
				return
			stage = Stage.PLANTED
			_timer = 0.0
			prompt_text = "药材生长 0%"
			GameState.bump_trait("diligence")
			GameState.toast("已下药种")
			Sfx.play("plant")
			_refresh()
		Stage.PLANTED:
			GameState.toast("药还在长")
		Stage.READY:
			if not WorldClock.spend_stamina(1):
				return
			stage = Stage.EMPTY
			prompt_text = "药圃·播种"
			GameState.add_herbs(1)
			Sfx.play("harvest")
			_refresh()

func _refresh() -> void:
	var vis_stage := 0
	match stage:
		Stage.LOCKED, Stage.EMPTY:
			vis_stage = 0
		Stage.PLANTED:
			vis_stage = 1
		Stage.READY:
			vis_stage = 2
	if _visual and _visual.has_method("set_herb_tint"):
		_visual.call("set_herb_tint", true)
	if _visual and _visual.has_method("set_stage"):
		_visual.call("set_stage", vis_stage)
	elif _visual:
		_visual.queue_redraw()
