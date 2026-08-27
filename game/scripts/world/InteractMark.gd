extends Node3D
class_name InteractMark
# 可点击问号：对话/交互物头顶标记。碰撞在 layer 2，不挡走路。

const CLICK_LAYER := 2

@export var dialogue_id := ""
@export var one_shot := false
@export var height := 2.15
@export var click_radius := 0.72
@export var mark_text := "?"

var used := false
var _cd := 0.0
var _label: Label3D
var _body: StaticBody3D

signal activated


static func bind(host: Node3D, dlg_id: String, mark_height: float = 2.15, once: bool = false, radius: float = 0.72) -> InteractMark:
	var m := InteractMark.new()
	m.dialogue_id = dlg_id
	m.height = mark_height
	m.one_shot = once
	m.click_radius = radius
	host.add_child(m)
	return m


func _ready() -> void:
	add_to_group("click_talk")
	_label = Label3D.new()
	_label.text = mark_text
	_label.font_size = 72
	_label.pixel_size = 0.012
	_label.modulate = Color(1.0, 0.84, 0.28)
	_label.outline_size = 12
	_label.outline_modulate = Color(0.18, 0.08, 0.04)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.position.y = height
	_label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_label)

	_body = StaticBody3D.new()
	_body.collision_layer = CLICK_LAYER
	_body.collision_mask = 0
	_body.input_ray_pickable = true
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = click_radius
	cyl.height = maxf(height + 0.5, 1.8)
	col.shape = cyl
	col.position.y = cyl.height * 0.42
	_body.add_child(col)
	add_child(_body)


func _process(delta: float) -> void:
	_cd = maxf(0.0, _cd - delta)
	if _label == null or not _label.visible:
		return
	var t := Time.get_ticks_msec() * 0.004
	_label.position.y = height + sin(t + float(get_instance_id() % 11)) * 0.14
	_label.modulate.a = 0.82 + 0.18 * sin(t * 1.25)


func on_click_talk() -> bool:
	if IssueManager.night_council_active:
		return false
	if used and one_shot:
		return false
	if _cd > 0.0:
		return false
	if one_shot:
		used = true
		_set_mark_visible(false)
	else:
		_cd = 1.6
	activated.emit()
	if dialogue_id != "":
		EventBus.dialogue_request.emit(dialogue_id)
	return true


func _set_mark_visible(v: bool) -> void:
	if _label:
		_label.visible = v
	if _body:
		_body.collision_layer = CLICK_LAYER if v else 0
