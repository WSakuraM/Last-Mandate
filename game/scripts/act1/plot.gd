extends Interactable
## 菜畦：空 → 已种 → 成熟 → 收获（Kenney CC0 精灵）。

enum Stage { EMPTY, PLANTED, READY }

@export var grow_seconds: float = 4.0

var stage: Stage = Stage.EMPTY
var _timer: float = 0.0

@onready var _soil: Sprite2D = $Soil
@onready var _crop: Sprite2D = $Crop

func _ready() -> void:
	prompt_text = "播种"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_visual()

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
			_crop.visible = false
			_soil.modulate = Color(1, 1, 1, 1)
		Stage.PLANTED:
			_crop.visible = true
			_crop.texture = preload("res://assets/tiles/crop_young.png")
			_soil.modulate = Color(0.9, 0.85, 0.7, 1)
		Stage.READY:
			_crop.visible = true
			_crop.texture = preload("res://assets/tiles/crop_ready.png")
			_soil.modulate = Color(1, 1, 1, 1)
