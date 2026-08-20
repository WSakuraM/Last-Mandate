extends CharacterBody2D
## 信王玩家：WASD 移动；E/空格互动（优先最近可交互物）。

@export var speed: float = 190.0

@onready var _prompt: Label = $InteractPrompt

var _nearby: Array[Node] = []
var _prompt_pulse: float = 0.0

func _ready() -> void:
	_prompt.visible = false
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if Dialogue.is_busy():
		velocity = Vector2.ZERO
		move_and_slide()
		_prompt.visible = false
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
	_update_prompt(delta)

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

func unregister_nearby(node: Node) -> void:
	_nearby.erase(node)

func _valid_targets() -> Array[Node]:
	var out: Array[Node] = []
	for n in _nearby:
		if not is_instance_valid(n):
			continue
		if n.has_method("can_interact") and not n.can_interact():
			continue
		out.append(n)
	return out

func _pick_best(targets: Array[Node]) -> Node:
	if targets.is_empty():
		return null
	var best: Node = targets[0]
	var best_score := -INF
	for t in targets:
		var dist := global_position.distance_squared_to(t.global_position)
		var pri := 0
		if t is Interactable:
			pri = (t as Interactable).interact_priority
		var score := float(pri) * 100000.0 - dist
		if score > best_score:
			best_score = score
			best = t
	return best

func _update_prompt(delta: float) -> void:
	_nearby = _nearby.filter(func(n): return is_instance_valid(n))
	var targets := _valid_targets()
	var target := _pick_best(targets)
	if target == null:
		_prompt.visible = false
		return
	_prompt.visible = true
	_prompt_pulse += delta * 4.0
	_prompt.modulate.a = 0.75 + 0.25 * sin(_prompt_pulse)
	if target.has_method("get_prompt"):
		_prompt.text = "E · " + str(target.get_prompt())
	else:
		_prompt.text = "E · 互动"

func _try_interact() -> void:
	var target := _pick_best(_valid_targets())
	if target and target.has_method("interact"):
		target.interact()
