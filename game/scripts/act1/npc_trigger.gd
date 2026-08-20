extends Interactable
## NPC 互动入口。

@export var npc_id: String = "aen"

func _ready() -> void:
	interact_priority = 5
	match npc_id:
		"aen":
			prompt_text = "与阿恩说话"
		"wu_bo":
			prompt_text = "与吴伯说话"
		"qiushui":
			prompt_text = "与秋穗说话"
		"gate_child":
			prompt_text = "询问门外孩子"
			add_to_group("gate_visitor")
		"gate_soldier":
			prompt_text = "询问门外老兵"
			add_to_group("gate_visitor")
		"eunuch":
			prompt_text = "面对中使"
			add_to_group("court_visitor")
		"weaver":
			prompt_text = "询问织妇"
			add_to_group("weaver_visitor")
		"lin_sheng":
			prompt_text = "与林生说话"
		"zhou":
			prompt_text = "与王妃说话"
		"relief":
			prompt_text = "面对求赈流民"
			add_to_group("relief_visitor")
		"shen":
			prompt_text = "与沈戍说话"
			add_to_group("lover_npc")
		"liu":
			prompt_text = "与柳筝说话"
			add_to_group("lover_npc")
		_:
			prompt_text = "交谈"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	get_tree().call_group("act1_director", "on_npc_talk", npc_id)
