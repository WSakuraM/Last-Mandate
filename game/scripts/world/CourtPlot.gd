extends Node3D
# 王府菜圃：可交互地块，状态机驱动经营。

var plot_id := "plot"
var state := "fallow"   # fallow -> tilled -> growing -> ripe
var near := false
var _cd := 0.0

var soil: MeshInstance3D
var crops: Node3D

func _ready():
	# 菜畦占位模型（规范资产，节点 Soil/Crops 匹配状态机；后续可换精模不改代码）
	var inst: Node3D = preload("res://assets/models/props/plot_01.tscn").instantiate()
	add_child(inst)
	soil = inst.get_node("Soil")
	crops = inst.get_node("Crops")

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
			_check_sow_hooks()
		"tilled":
			state = "growing"
		"growing":
			state = "ripe"
		"ripe":
			state = "fallow"
			_harvest()
	_refresh()
	EventBus.interact_prompt.emit("按 E 照料菜圃（%s）" % _zh(state))

# M1A3：首次播种 → 通知阿恩递种夜谈（仅触发一次）
# M1A2：后期播种 → 写入「最后的播种」回忆碎片（终章对照空畦/日出）
func _check_sow_hooks():
	if not IssueManager.flags.get("first_sow_done", false):
		IssueManager.flags["first_sow_done"] = true
		EventBus.first_sow.emit()
	if ResourceManager.total_day >= 120 and not IssueManager.flags.get("last_sow_done", false):
		IssueManager.flags["last_sow_done"] = true
		IssueManager.add_memory("MF_A1_LAST_SOW", 8, \
			"最后的播种——旁白：你或许看不见收成", "Ⅰ")

# 收获：受季节与天时调制，杜绝「无成本无限刷资源」。
# 春播高产、夏秋平、冬寒歉收；若已逢旱象旗标则再减半。
# 区块二：加旱象减产旁白 + 丰收分邻回忆钩（纯数值经营也绑剧情）。
func _harvest():
	var mult: float = [1.5, 1.0, 1.25, 0.4][ResourceManager.season]   # 春夏秋冬
	var drought_active := bool(IssueManager.flags.get("drought", false))
	if drought_active:
		mult *= 0.5
	var r := randf_range(0.85, 1.15)
	ResourceManager.add("treasury", 4.0 * mult * r)
	ResourceManager.add("people", 1.0 * mult * r)
	# 旱象减产旁白——天灾钩子（Ⅲ类人民疾苦，weight 6）
	if drought_active:
		IssueManager.add_memory("MF_A1_DROUGHT_HARVEST", 6, \
			"旱象之下，菜畦瘦得可怜——几近颗粒无收", "Ⅲ")
		EventBus.narration.emit("旱象连年，这畦菜瘦得可怜……")
	# 丰收分邻——仁慈钩子（Ⅰ类信王个人，weight 4）
	elif r > 1.1 and (ResourceManager.season == 0 or ResourceManager.season == 2):
		IssueManager.add_memory("MF_A1_BOUNTY_SHARE", 4, \
			"丰收时你让吴伯分些菜给街坊邻舍", "Ⅰ")
		EventBus.narration.emit("丰收了，你让吴伯分些给街坊。")

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
