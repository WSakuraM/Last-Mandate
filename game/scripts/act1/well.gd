extends Interactable
## 井：打水 / 井边 vignette。

func _ready() -> void:
	interact_priority = 1
	prompt_text = "井边打水"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	if Dialogue.is_busy():
		return
	get_tree().call_group("act1_director", "on_well_interact")
