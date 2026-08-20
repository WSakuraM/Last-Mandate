extends Interactable
## 护卫棚：收拢亲随（藩王私卫，非锦衣卫）。

func _ready() -> void:
	interact_priority = 4
	prompt_text = "护卫棚"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.hearts_changed.connect(_refresh)
	GameState.guards_changed.connect(_refresh)
	GameState.flags_changed.connect(_refresh)
	_refresh()

func _refresh(_v: int = 0) -> void:
	prompt_text = "护卫棚·亲随 %d" % GameState.guards

func interact() -> void:
	get_tree().call_group("act1_director", "on_guard_post")
