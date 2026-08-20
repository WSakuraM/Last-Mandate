extends CharacterBody2D
## 信王玩家：WASD/方向键移动，E/空格互动。

@export var speed: float = 180.0

@onready var _prompt: Label = $InteractPrompt
@onready var _anim_pulse: ColorRect = $Body

var _nearby: Array[Node] = []

func _ready() -> void:
	_prompt.visible = false
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	if Dialogue.is_busy():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	velocity = dir.normalized() * speed if dir != Vector2.ZERO else Vector2.ZERO
	move_and_slide()
	_update_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if Dialogue.is_busy():
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.keycode == KEY_SPACE)):
			Dialogue.notify_continue()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			_try_interact()
			get_viewport().set_input_as_handled()

func register_nearby(node: Node) -> void:
	if node not in _nearby:
		_nearby.append(node)
	_update_prompt()

func unregister_nearby(node: Node) -> void:
	_nearby.erase(node)
	_update_prompt()

func _update_prompt() -> void:
	_prompt.visible = not _nearby.is_empty() and not Dialogue.is_busy()
	if _prompt.visible:
		var target = _nearby[_nearby.size() - 1]
		if target.has_method("get_prompt"):
			_prompt.text = "E · " + str(target.get_prompt())
		else:
			_prompt.text = "E · 互动"

func _try_interact() -> void:
	if _nearby.is_empty():
		return
	var target = _nearby[_nearby.size() - 1]
	if target.has_method("interact"):
		target.interact()
