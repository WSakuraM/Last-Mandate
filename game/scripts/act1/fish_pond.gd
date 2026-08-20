extends Interactable
## 浅鱼塘：需捞网；冷却后可捞鱼。

@export var cooldown_seconds: float = 7.0

var _cooldown: float = 0.0

func _ready() -> void:
	interact_priority = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.flags_changed.connect(_refresh_prompt)
	_refresh_prompt()

func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = max(0.0, _cooldown - delta)
		if GameState.flags.get("has_net", false):
			if _cooldown > 0.0:
				prompt_text = "鱼塘歇息 %d 秒" % int(ceil(_cooldown))
			else:
				prompt_text = "捞鱼"

func _refresh_prompt() -> void:
	if not GameState.flags.get("has_net", false):
		prompt_text = "鱼塘（需捞网）"
	elif _cooldown > 0.0:
		prompt_text = "鱼塘歇息 %d 秒" % int(ceil(_cooldown))
	else:
		prompt_text = "捞鱼"

func interact() -> void:
	if not GameState.flags.get("has_net", false):
		Dialogue.play([
			{"narration": true, "text": "塘水轻轻晃。吴伯说，没有捞网，只能看。"},
			{"speaker": "吴伯", "text": "捞网三十五文。稳，少，不发财——但能换粥。"},
		])
		return
	if _cooldown > 0.0:
		GameState.toast("鱼还在躲，稍候")
		return
	if not WorldClock.spend_stamina(1):
		return
	_cooldown = cooldown_seconds
	if WorldClock.disaster == "flood" or WorldClock.disaster == "storm":
		GameState.toast("水浑浪急，网空空")
		_refresh_prompt()
		Dialogue.play([
			{"narration": true, "text": "暴雨灌塘。鱼都散了。"},
			{"speaker": "吴伯", "text": "涝年塘不稳。等天晴再捞。"},
		])
		return
	GameState.add_fish(1)
	GameState.bump_trait("diligence")
	Sfx.play("fish")
	_refresh_prompt()
	var line := "网起。一条银白的活物扑腾两下，进了筐。"
	if WorldClock.weather == WorldClock.Weather.RAIN:
		line = "雨里下网，鱼倒肯上钩。"
	Dialogue.play([
		{"narration": true, "text": line},
	])
