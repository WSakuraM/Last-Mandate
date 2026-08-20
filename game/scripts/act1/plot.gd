extends Interactable
## 菜畦：空 → 已种 → 成熟 → 收获。

enum Stage { EMPTY, PLANTED, READY }

@export var grow_seconds: float = 4.0

var stage: Stage = Stage.EMPTY
var _timer: float = 0.0

@onready var _soil: ColorRect = $Soil
@onready var _crop: ColorRect = $Crop

func _ready() -> void:
	prompt_text = "播种"
	_refresh_visual()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if stage != Stage.PLANTED:
		return
	_timer += delta
	if _timer >= grow_seconds:
		stage = Stage.READY
		_timer = 0.0
		prompt_text = "收获"
		_refresh_visual()

func interact() -> void:
	match stage:
		Stage.EMPTY:
			stage = Stage.PLANTED
			_timer = 0.0
			prompt_text = "等待生长…"
			GameState.bump_trait("diligence")
			_refresh_visual()
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
			_refresh_visual()

func _refresh_visual() -> void:
	match stage:
		Stage.EMPTY:
			_soil.color = Color(0.45, 0.32, 0.18)
			_crop.visible = false
		Stage.PLANTED:
			_soil.color = Color(0.38, 0.28, 0.14)
			_crop.visible = true
			_crop.color = Color(0.55, 0.7, 0.35)
			_crop.size = Vector2(18, 18)
			_crop.position = Vector2(15, 20)
		Stage.READY:
			_soil.color = Color(0.4, 0.3, 0.16)
			_crop.visible = true
			_crop.color = Color(0.25, 0.55, 0.22)
			_crop.size = Vector2(28, 28)
			_crop.position = Vector2(10, 10)
