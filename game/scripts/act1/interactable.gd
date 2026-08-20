extends Area2D
class_name Interactable
## 可互动物件基类。

@export var prompt_text: String = "查看"
@export var interact_priority: int = 0

func get_prompt() -> String:
	return prompt_text

func can_interact() -> bool:
	return visible and monitoring

func interact() -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("register_nearby"):
		body.register_nearby(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("unregister_nearby"):
		body.unregister_nearby(self)
