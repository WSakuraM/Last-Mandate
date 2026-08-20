extends Interactable
## 售卖点：把菜换成铜钱。

@export var price_per_veggie: int = 5

func _ready() -> void:
	prompt_text = "售卖菜蔬"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	if GameState.veggies <= 0:
		Dialogue.play([
			{"speaker": "吴伯", "text": "王爷，筐是空的。先去畦里拔几棵。"},
		])
		return
	var sold := GameState.veggies
	var gain := sold * price_per_veggie
	GameState.add_veggies(-sold)
	GameState.add_money(gain)
	GameState.bump_trait("thrift")
	Dialogue.play([
		{"speaker": "吴伯", "text": "卖了 %d 畦菜，换得 %d 文。够买锄头，也够过日子。" % [sold, gain]},
	])
