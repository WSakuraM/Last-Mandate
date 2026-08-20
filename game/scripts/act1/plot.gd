extends Interactable
## 非像素柔和菜畦。

enum Stage { EMPTY, PLANTED, READY }

@export var grow_seconds: float = 4.0

var stage: Stage = Stage.EMPTY
var _timer: float = 0.0

@onready var _visual: Node2D = $Visual

func _ready() -> void:
	prompt_text = "播种"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_visual.queue_redraw()
	if not _visual.has_method("set_stage"):
		pass
	_refresh()

func _process(delta: float) -> void:
	if stage != Stage.PLANTED:
		return
	_timer += delta
	if _timer >= grow_seconds:
		stage = Stage.READY
		_timer = 0.0
		prompt_text = "收获"
		_refresh()

func interact() -> void:
	match stage:
		Stage.EMPTY:
			stage = Stage.PLANTED
			_timer = 0.0
			prompt_text = "等待生长…"
			GameState.bump_trait("diligence")
			_refresh()
		Stage.PLANTED:
			pass
		Stage.READY:
			stage = Stage.EMPTY
			prompt_text = "播种"
			GameState.add_veggies(1)
			if not GameState.flags["first_harvest"]:
				GameState.set_flag("first_harvest", true)
				GameState.add_memory("MF_A1_FIRST_HARVEST")
				get_tree().call_group("act1_director", "on_first_harvest")
			_refresh()

func _refresh() -> void:
	if _visual.has_method("set_stage"):
		_visual.call("set_stage", stage)
	else:
		_visual.queue_redraw()
