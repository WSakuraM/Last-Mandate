extends Interactable
## 菜畦：多种作物轮换；提示随生长进度更新。

enum Stage { EMPTY, PLANTED, READY }

const CROP_POOL: Array[String] = [
	"cabbage", "carrot", "wheat", "tomato", "corn", "potato", "onion", "lettuce", "radish"
]

@export var grow_seconds: float = 4.0
## cabbage / carrot / wheat / tomato / corn / potato / onion / lettuce / radish
@export var crop_kind: String = "cabbage"
## 每次播种从池中换一种（视觉多样；库存仍是统一「菜蔬」）
@export var rotate_on_plant: bool = true

var stage: Stage = Stage.EMPTY
var _timer: float = 0.0
var _pool_idx: int = 0

@onready var _visual: Node2D = $Visual

func _ready() -> void:
	interact_priority = 2
	prompt_text = "播种"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_pool_idx = maxi(0, CROP_POOL.find(crop_kind))
	if _visual and _visual.has_method("set_crop"):
		_visual.call("set_crop", crop_kind)
	_refresh()

func _process(delta: float) -> void:
	if stage != Stage.PLANTED:
		return
	_timer += delta
	var need := grow_seconds * GameState.get_grow_multiplier()
	var pct := clampi(int((_timer / need) * 100.0), 0, 99)
	prompt_text = "生长中 %d%%（稍候）" % pct
	if _timer >= need:
		stage = Stage.READY
		_timer = 0.0
		prompt_text = "收获"
		GameState.toast("%s熟了" % _crop_label())
		_refresh()

func interact() -> void:
	match stage:
		Stage.EMPTY:
			if not WorldClock.spend_stamina(1):
				return
			stage = Stage.PLANTED
			_timer = 0.0
			prompt_text = "生长中 0%（稍候）"
			GameState.bump_trait("diligence")
			GameState.toast("已播：%s" % _crop_label())
			Sfx.play("plant")
			_refresh()
		Stage.PLANTED:
			GameState.toast("还在长，再等等")
		Stage.READY:
			if WorldClock.disaster == "locust" and not GameState.flags.get("vig_locust_done", false):
				GameState.toast("蝗虫啃着叶——先去护卫棚或听吴伯说一声")
				return
			if not WorldClock.spend_stamina(1):
				return
			stage = Stage.EMPTY
			prompt_text = "播种"
			var n := 1
			if WorldClock.disaster == "locust":
				n = 0 if GameState.guards < 1 else 1
				if n == 0:
					GameState.toast("蝗过之后，只剩空杆")
				else:
					GameState.toast("亲随拍网护畦，仍收得一棵")
			if n > 0:
				Sfx.play("harvest")
			GameState.add_veggies(n)
			if n > 0 and not GameState.flags.get("first_harvest", false):
				GameState.set_flag("first_harvest", true)
				GameState.add_memory("MF_A1_FIRST_HARVEST")
				get_tree().call_group("act1_director", "on_first_harvest")
			## 收完轮换下一种，下次播种才换样
			if rotate_on_plant:
				_advance_crop()
			_refresh()

func _advance_crop() -> void:
	_pool_idx = (_pool_idx + 1) % CROP_POOL.size()
	crop_kind = CROP_POOL[_pool_idx]
	if _visual and _visual.has_method("set_crop"):
		_visual.call("set_crop", crop_kind)

func _crop_label() -> String:
	match crop_kind:
		"cabbage":
			return "白菜"
		"carrot":
			return "胡萝卜"
		"wheat":
			return "麦"
		"tomato":
			return "番茄"
		"corn":
			return "玉米"
		"potato":
			return "土豆"
		"onion":
			return "葱"
		"lettuce":
			return "生菜"
		"radish":
			return "萝卜"
		_:
			return "菜"

func _refresh() -> void:
	if _visual and _visual.has_method("set_stage"):
		_visual.call("set_stage", stage)
	elif _visual:
		_visual.queue_redraw()
