extends Interactable
## 灶口：分粮给下人（仁慈）。

func _ready() -> void:
	interact_priority = 2
	prompt_text = "灶口·分粮"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	if Dialogue.is_busy():
		return
	if GameState.veggies <= 0 and GameState.fish <= 0 and GameState.herbs <= 0:
		Dialogue.play([
			{"speaker": "阿恩", "text": "灶上锅空着。王爷若有收成，分一棵，他们会记在心里。"},
		])
		return
	Dialogue.choice_made.connect(_on_share, CONNECT_ONE_SHOT)
	Dialogue.play([
		{"speaker": "阿恩", "text": "灶上人在等。……王爷要分一点吗？"},
		{
			"prompt": "分粮会少私囊，但人心会暖。",
			"choices": [
				{"id": "veg", "label": "分一棵菜" if GameState.veggies > 0 else "分菜（无菜）"},
				{"id": "fish", "label": "分一条鱼" if GameState.fish > 0 else "分鱼（无鱼）"},
				{"id": "herb", "label": "分一点药熬粥" if GameState.herbs > 0 else "分药（无药）"},
				{"id": "no", "label": "先留着"},
			],
		},
	])

func _on_share(choice_id: String) -> void:
	match choice_id:
		"veg":
			if GameState.veggies <= 0:
				Dialogue.play([{"speaker": "阿恩", "text": "……筐里没有菜。"}])
				return
			GameState.add_veggies(-1)
			GameState.bump_trait("mercy", 1)
			GameState.set_flag("shared_kitchen", true)
			GameState.add_memory("MF_A1_SHARE_KITCHEN")
			GameState.add_hearts(2)
			Dialogue.play([
				{"speaker": "阿恩", "text": "他们会记得王爷亲手拔的那棵。"},
				{"narration": true, "text": "灶烟里有一点笑。"},
			])
		"fish":
			if GameState.fish <= 0:
				Dialogue.play([{"speaker": "阿恩", "text": "没有鱼。"}])
				return
			GameState.add_fish(-1)
			GameState.bump_trait("mercy", 1)
			GameState.set_flag("shared_kitchen", true)
			GameState.add_memory("MF_A1_SHARE_KITCHEN")
			GameState.add_hearts(2)
			Dialogue.play([{"speaker": "阿恩", "text": "汤会鲜一点。人也会。"}])
		"herb":
			if GameState.herbs <= 0:
				Dialogue.play([{"speaker": "阿恩", "text": "没有药。"}])
				return
			GameState.add_herbs(-1)
			GameState.bump_trait("mercy", 2)
			GameState.set_flag("shared_kitchen", true)
			GameState.add_memory("MF_A1_SHARE_KITCHEN")
			GameState.add_hearts(3)
			Dialogue.play([
				{"speaker": "阿恩", "text": "井边那咳……或许能暖一碗。"},
				{"narration": true, "text": "药香很淡，像一句没说完的话。"},
			])
		"no":
			Dialogue.play([{"speaker": "阿恩", "text": "……是。先顾畦。"}])
