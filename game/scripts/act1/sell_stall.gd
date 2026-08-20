extends Interactable
## 售卖：菜 / 鱼 / 药；旱年涨价。

func _ready() -> void:
	interact_priority = 3
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.veggies_changed.connect(_refresh_prompt)
	GameState.fish_changed.connect(_refresh_prompt)
	GameState.herbs_changed.connect(_refresh_prompt)
	GameState.objective_changed.connect(_refresh_prompt)
	_refresh_prompt()

func _refresh_prompt(_v: int = 0) -> void:
	var parts: PackedStringArray = []
	if GameState.veggies > 0:
		parts.append("菜×%d(%d文)" % [GameState.veggies, GameState.price_veggie()])
	if GameState.fish > 0:
		parts.append("鱼×%d(%d文)" % [GameState.fish, GameState.price_fish()])
	if GameState.herbs > 0:
		parts.append("药×%d(%d文)" % [GameState.herbs, GameState.price_herb()])
	if parts.is_empty():
		prompt_text = "售卖（筐空）"
	else:
		var drought_tag := ""
		if GameState.drought or WorldClock.disaster == "drought":
			drought_tag = "·旱价"
		elif WorldClock.disaster == "locust":
			drought_tag = "·蝗价"
		elif WorldClock.disaster == "storm" or WorldClock.disaster == "flood":
			drought_tag = "·涝价"
		prompt_text = "售卖" + drought_tag + " " + " · ".join(parts)

func interact() -> void:
	if GameState.veggies <= 0 and GameState.fish <= 0 and GameState.herbs <= 0:
		Dialogue.play([
			{"speaker": "吴伯", "text": "筐是空的。菜畦、药圃、鱼塘、墙根野菜——都可收。也可去灶口看下人。"},
		])
		return
	var sold_v := GameState.veggies
	var sold_f := GameState.fish
	var sold_h := GameState.herbs
	var gain := sold_v * GameState.price_veggie() + sold_f * GameState.price_fish() + sold_h * GameState.price_herb()
	GameState.add_veggies(-sold_v)
	GameState.add_fish(-sold_f)
	GameState.add_herbs(-sold_h)
	GameState.add_money(gain, false)
	GameState.sell_count += 1
	GameState.bump_trait("thrift")
	GameState.set_flag("sold_once", true)
	GameState.toast("+ %d 文（售出）" % gain)
	Sfx.play("sell")
	_refresh_prompt()
	get_tree().call_group("act1_director", "on_sold")
	var purse := "私囊" if GameState.flags.get("learned_purse", false) else "袋中"
	var detail: PackedStringArray = []
	if sold_v > 0:
		detail.append("%d 菜" % sold_v)
	if sold_f > 0:
		detail.append("%d 鱼" % sold_f)
	if sold_h > 0:
		detail.append("%d 药" % sold_h)
	var drought_note := ""
	if WorldClock.disaster == "drought" or GameState.drought:
		drought_note = "天旱，价高。"
	elif WorldClock.disaster == "locust":
		drought_note = "蝗后粮紧，价也紧。"
	elif WorldClock.disaster == "flood" or WorldClock.disaster == "storm":
		drought_note = "涝年货不好出手。"
	if GameState.sell_count >= 2:
		drought_note += "市面见多了，价软了。"
	if GameState.money > WorldClock.effective_soft_cap():
		drought_note += "私囊厚了——中使的眼会亮。"
	Dialogue.play([
		{"speaker": "吴伯", "text": "卖了%s，换得 %d 文，入%s。%s" % ["、".join(detail), gain, purse, drought_note]},
	])
	if GameState.money > WorldClock.effective_soft_cap() and not GameState.flags.get("purse_pressure_done", false):
		Dialogue.dialogue_finished.connect(func(): get_tree().call_group("act1_director", "on_purse_pressure"), CONNECT_ONE_SHOT)
