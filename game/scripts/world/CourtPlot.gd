extends Node3D
# 王府菜圃：可交互地块，状态机驱动经营。

var plot_id := "plot"
var state := "fallow"   # fallow -> tilled -> growing -> ripe
var near := false
var _cd := 0.0

var soil: MeshInstance3D
var crops: Node3D

func _ready():
	var s := MeshInstance3D.new()
	s.name = "Soil"
	var box := BoxMesh.new()
	box.size = Vector3(3, 0.3, 3)
	s.mesh = box
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.3, 0.22, 0.16)
	s.material_override = sm
	s.position.y = 0.15
	add_child(s)
	soil = s

	var c := Node3D.new()
	c.name = "Crops"
	# 低模菜苗：细茎 + 顶叶（圆锥），土绿
	for k in range(5):
		var stem := MeshInstance3D.new()
		var smesh := CylinderMesh.new()
		smesh.top_radius = 0.04; smesh.bottom_radius = 0.06; smesh.height = 0.5
		stem.mesh = smesh
		var stem_mat := StandardMaterial3D.new()
		stem_mat.albedo_color = Color(0.34, 0.42, 0.22)
		stem.material_override = stem_mat
		stem.position = Vector3((k % 3 - 1) * 0.8, 0.25, (k / 3 - 0.5) * 0.8)
		c.add_child(stem)
		var leaf := MeshInstance3D.new()
		var lm := CylinderMesh.new()
		lm.top_radius = 0.02; lm.bottom_radius = 0.22; lm.height = 0.5
		leaf.mesh = lm
		var lmt := StandardMaterial3D.new()
		lmt.albedo_color = Color(0.46, 0.6, 0.28)
		leaf.material_override = lmt
		leaf.position = Vector3((k % 3 - 1) * 0.8, 0.62, (k / 3 - 0.5) * 0.8)
		c.add_child(leaf)
	add_child(c)
	crops = c

	var area := Area3D.new()
	area.name = "Detect"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 2.2
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	_refresh()

func _on_body_entered(b):
	if b.is_in_group("player"):
		near = true
		EventBus.interact_prompt.emit("按 E 照料菜圃（%s）" % _zh(state))

func _on_body_exited(b):
	if b.is_in_group("player"):
		near = false
		EventBus.interact_hide.emit()

func _process(delta):
	if IssueManager.night_council_active:
		return
	_cd = max(0.0, _cd - delta)
	if near and Input.is_key_pressed(KEY_E) and _cd <= 0.0:
		tend()
		_cd = 0.4

func tend():
	match state:
		"fallow":
			state = "tilled"
			ResourceManager.add("treasury", -0.5)   # 种子与人力之费
		"tilled":
			state = "growing"
		"growing":
			state = "ripe"
		"ripe":
			state = "fallow"
			_harvest()
	_refresh()
	EventBus.interact_prompt.emit("按 E 照料菜圃（%s）" % _zh(state))

# 收获：受季节与天时调制，杜绝「无成本无限刷资源」。
# 春播高产、夏秋平、冬寒歉收；若已逢旱象旗标则再减半。
func _harvest():
	var mult: float = [1.5, 1.0, 1.25, 0.4][ResourceManager.season]   # 春夏秋冬
	if IssueManager.flags.get("drought", false):
		mult *= 0.5
	var r := randf_range(0.85, 1.15)
	ResourceManager.add("treasury", 4.0 * mult * r)
	ResourceManager.add("people", 1.0 * mult * r)

func _refresh():
	match state:
		"fallow", "tilled":
			crops.visible = false
		"growing":
			crops.visible = true
			crops.scale = Vector3(0.5, 0.5, 0.5)
		"ripe":
			crops.visible = true
			crops.scale = Vector3(1, 1, 1)

func _zh(s: String) -> String:
	return {"fallow": "荒芜", "tilled": "已翻土", "growing": "生长中", "ripe": "成熟"}[s]
