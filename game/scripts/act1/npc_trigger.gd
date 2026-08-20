extends Interactable
## NPC 互动入口。

@export var npc_id: String = "aen"

func _ready() -> void:
	match npc_id:
		"aen":
			prompt_text = "与阿恩说话"
		"wu_bo":
			prompt_text = "与吴伯说话"
		"qiushui":
			prompt_text = "与秋穗说话"
		_:
			prompt_text = "交谈"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	get_tree().call_group("act1_director", "on_npc_talk", npc_id)
