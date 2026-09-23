extends Node3D
class_name InteractMark
# 可点击问号。默认「走近才显示」，重要目标可常显，夜召等可按需激活。
# Area3D 仅点选，不挡走路。

const CLICK_LAYER := 2
const NEAR_DIST := 7.5

@export var dialogue_id := ""
@export var one_shot := false
@export var height := 2.15
@export var click_radius := 0.55
@export var mark_text := "?"
## always=常显（当前目标）· near=走近才显（闲聊）· when_active=外部 set_active 控制
@export var show_mode := "near"
@export var important := false

var used := false
var _cd := 0.0
var _label: Label3D
var _body: Area3D
var _active := true
var _want_visible := false

signal activated


static func bind(
	host: Node3D,
	dlg_id: String,
	mark_height: float = 2.15,
	once: bool = false,
	radius: float = 0.55,
	mode: String = "near",
	is_important: bool = false
) -> InteractMark:
	var m := InteractMark.new()
	m.dialogue_id = dlg_id
	m.height = mark_height
	m.one_shot = once
	m.click_radius = radius
	m.show_mode = mode
	m.important = is_important
	host.add_child(m)
	return m


func _ready() -> void:
	add_to_group("click_talk")
	_label = Label3D.new()
	_label.text = mark_text
	_label.font_size = 64 if important else 52
	_label.pixel_size = 0.012
	if important:
		_label.modulate = Color(1.0, 0.78, 0.22)
	else:
		_label.modulate = Color(0.92, 0.82, 0.48)
	_label.outline_size = 10
	_label.outline_modulate = Color(0.18, 0.08, 0.04)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.position.y = height
	_label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_label)

	_body = Area3D.new()
	_body.collision_layer = 0
	_body.collision_mask = 0
	_body.monitoring = false
	_body.monitorable = false
	_body.input_ray_pickable = true
	var col := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = click_radius
	col.shape = sphere
	col.position.y = height * 0.55
	_body.add_child(col)
	add_child(_body)

	if show_mode == "when_active":
		_active = false
	_apply_visibility(false)


func set_important(v: bool) -> void:
	important = v
	if _label:
		_label.font_size = 64 if important else 52
		_label.modulate = Color(1.0, 0.78, 0.22) if important else Color(0.92, 0.82, 0.48)


func set_show_mode(mode: String) -> void:
	show_mode = mode
	if mode == "when_active":
		_active = false
	elif mode == "always":
		_active = true
	_refresh_visibility()


func set_active(v: bool) -> void:
	_active = v
	_refresh_visibility()


func _process(delta: float) -> void:
	_cd = maxf(0.0, _cd - delta)
	_refresh_visibility()
	if _label == null or not _want_visible:
		return
	var t := Time.get_ticks_msec() * 0.004
	_label.position.y = height + sin(t + float(get_instance_id() % 11)) * 0.12
	var base_a := 0.95 if important else 0.78
	_label.modulate.a = base_a + 0.12 * sin(t * 1.25)


func _refresh_visibility() -> void:
	if used and one_shot:
		_apply_visibility(false)
		return
	var show := false
	match show_mode:
		"always":
			show = true
		"when_active":
			show = _active
		_:
			show = _active and _player_near()
	_apply_visibility(show)


func _player_near() -> bool:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return false
	var p: Node3D = players[0] as Node3D
	if p == null:
		return false
	var d := global_position.distance_to(p.global_position)
	return d <= NEAR_DIST


func on_click_talk() -> bool:
	if IssueManager.night_council_active:
		return false
	if used and one_shot:
		return false
	if _cd > 0.0:
		return false
	if not _want_visible:
		return false
	if one_shot:
		used = true
		_apply_visibility(false)
	else:
		_cd = 1.6
	activated.emit()
	if dialogue_id != "":
		EventBus.dialogue_request.emit(dialogue_id)
	return true


func _apply_visibility(v: bool) -> void:
	_want_visible = v
	if _label:
		_label.visible = v
	if _body:
		_body.collision_layer = CLICK_LAYER if v else 0
