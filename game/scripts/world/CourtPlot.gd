extends Node3D
# 王府菜圃：可交互地块，状态机 + 跨日生长。

var plot_id := "plot"
var state := "fallow"   # fallow -> tilled -> growing -> ripe -> 收获 -> fallow
var near := false
var _cd := 0.0
var grow_days := 0
var grow_needed := 2
var _ring: MeshInstance3D
var _ring_a := 0.0
var _scale_target := Vector3.ONE
var _mark: InteractMark

var soil: MeshInstance3D
var crops: Node3D

const BASE_TREASURY := 4.0
const BASE_PEOPLE := 1.0
const TILL_COST := 0.5
const HARVEST_PURSE_SHARE := 0.7
const HARVEST_TREASURY_SHARE := 0.3

func _ready():
	add_to_group("court_plot")
	var inst: Node3D = preload("res://assets/models/props/plot_01.tscn").instantiate()
	inst.scale = Vector3(0.86, 0.86, 0.86)
	add_child(inst)
	CourtyardProps.enhance_plot(inst)
	soil = inst.get_node("Soil")
	crops = inst.get_node("Crops")
	_build_crop_plants()

	var area := Area3D.new()
	area.name = "Detect"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.85
	shape.height = 2.0
	col.shape = shape
	area.add_child(col)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	_ring = CourtyardProps.make_interact_ring(1.35)
	add_child(_ring)
	_mark = InteractMark.new()
	_mark.height = 1.42
	_mark.click_radius = 1.22
	_mark.activated.connect(tend)
	add_child(_mark)
	ResourceManager.day_passed.connect(_on_day_passed)
	_refresh()
	_broadcast_farm()

func _on_body_entered(b):
	if b.is_in_group("player"):
		near = true
		EventBus.interact_prompt.emit(_prompt_text())

func _on_body_exited(b):
	if b.is_in_group("player"):
		near = false
		EventBus.interact_hide.emit()

func _process(delta):
	if IssueManager.night_council_active:
		return
	_cd = max(0.0, _cd - delta)
	if near and Input.is_key_pressed(KEY_E) and _cd <= 0.0 and _can_tend():
		tend()
		_cd = 0.4
	var want := 0.55 if near and _can_tend() else (0.28 if state == "growing" and near else 0.0)
	_ring_a = lerpf(_ring_a, want, 1.0 - exp(-10.0 * delta))
	if _ring:
		_ring.visible = _ring_a > 0.02
		(_ring.material_override as StandardMaterial3D).albedo_color.a = _ring_a
		_ring.rotation.y += delta * 0.8
	if crops:
		crops.scale = crops.scale.lerp(_scale_target, 1.0 - exp(-8.0 * delta))

func _on_day_passed(_day: int, season: int, _year: int) -> void:
	if state != "growing":
		return
	grow_days += 1
	var prog := clampf(float(grow_days) / float(grow_needed), 0.0, 1.0)
	_scale_target = Vector3.ONE * lerpf(0.28, 0.92, prog)
	if grow_days >= grow_needed:
		state = "ripe"
		_refresh()
		EventBus.narration.emit("有一畦菜成熟了。")
	_broadcast_farm()

func tend():
	if not _can_tend() and state == "growing":
		EventBus.narration.emit("尚未成熟，还需 %d 日。" % maxi(0, grow_needed - grow_days))
		return
	match state:
		"fallow":
			if ResourceManager.r["treasury"] < TILL_COST:
				EventBus.narration.emit("国库不足，无力翻土（需 %.1f）。" % TILL_COST)
				return
			state = "tilled"
			ResourceManager.add("treasury", -TILL_COST)
		"tilled":
			state = "growing"
			grow_days = 0
			grow_needed = _growth_days()
			_check_sow_hooks()
		"ripe":
			state = "fallow"
			_harvest()
	_refresh()
	if crops:
		crops.scale = _scale_target * 1.12
	if near:
		EventBus.interact_prompt.emit(_prompt_text())
	_broadcast_farm()

func _can_tend() -> bool:
	return state in ["fallow", "tilled", "ripe"]

func _growth_days() -> int:
	var base: int
	match ResourceManager.season:
		0: base = 2
		1: base = 3
		2: base = 2
		_: base = 4
	if IssueManager.flags.get("farm_growth_boost", false):
		base = maxi(1, base - 1)
	return base

func _prompt_text() -> String:
	if state == "growing":
		return "菜圃生长中（%d/%d 日）· 问号可查看" % [grow_days, grow_needed]
	return "点击问号照料菜圃（%s）" % _zh(state)

# M1A3：首次播种 → 通知阿恩递种夜谈（仅触发一次）
func _check_sow_hooks():
	if not IssueManager.flags.get("first_sow_done", false):
		IssueManager.flags["first_sow_done"] = true
		EventBus.first_sow.emit()
	if ResourceManager.total_day >= 120 and not IssueManager.flags.get("last_sow_done", false):
		IssueManager.flags["last_sow_done"] = true
		IssueManager.add_memory("MF_A1_LAST_SOW", 8, \
			"最后的播种——旁白：你或许看不见收成", "Ⅰ")

func _harvest():
	var mult: float = [1.5, 1.0, 1.25, 0.4][ResourceManager.season]
	var drought_active := bool(IssueManager.flags.get("drought", false))
	if drought_active:
		mult *= 0.5
	var r := randf_range(0.85, 1.15)
	var gross: float = BASE_TREASURY * mult * r
	if int(IssueManager.flags.get("farm_yield_boost_season", -1)) == ResourceManager.season:
		gross *= 1.1
	var purse_gross: float = gross * HARVEST_PURSE_SHARE
	var treasury_gross: float = gross * HARVEST_TREASURY_SHARE
	var people_gross: float = BASE_PEOPLE * mult * r
	var net: Dictionary = ResourceManager.add_prince_income(treasury_gross, purse_gross, true)
	var t_gain: float = float(net.treasury)
	var p_gain: float = float(net.purse)
	var people_cap: Dictionary = ResourceManager.add_capped("people", people_gross)
	var people_gain: float = float(people_cap.applied)
	var overflow_notes: Array[String] = []
	if float(net.get("treasury_overflow", 0.0)) > 0.05:
		overflow_notes.append("官银已满，余数充赈")
	if float(people_cap.overflow) > 0.05:
		overflow_notes.append("民心已极，余惠分邻")
	var overflow_suffix := ""
	if not overflow_notes.is_empty():
		overflow_suffix = " · " + " · ".join(overflow_notes)
	var seasons: Array = ["春", "夏", "秋", "冬"]
	var sn: String = String(seasons[ResourceManager.season])
	if drought_active:
		IssueManager.add_memory("MF_A1_DROUGHT_HARVEST", 6, \
			"旱象之下，菜畦瘦得可怜——几近颗粒无收", "Ⅲ")
		EventBus.narration.emit("旱象减产：+%.0f 两私囊 · +%.1f 国库 · +%.1f 民心%s" % [
			p_gain, t_gain, people_gain, overflow_suffix])
	elif r > 1.1 and (ResourceManager.season == 0 or ResourceManager.season == 2):
		IssueManager.add_memory("MF_A1_BOUNTY_SHARE", 4, \
			"丰收时你让吴伯分些菜给街坊邻舍", "Ⅰ")
		EventBus.narration.emit("%s丰收：+%.0f 两私囊 · +%.1f 国库 · +%.1f 民心%s" % [
			sn, p_gain, t_gain, people_gain, overflow_suffix])
	else:
		EventBus.narration.emit("收获：+%.0f 两私囊 · +%.1f 国库 · +%.1f 民心（%s×%.0f%%）%s" % [
			p_gain, t_gain, people_gain, sn, mult * 100.0, overflow_suffix])

static func _broadcast_farm() -> void:
	var tree := Engine.get_main_loop()
	if tree == null or not (tree is SceneTree):
		return
	var ripe := 0
	var growing := 0
	var total := 0
	for n in (tree as SceneTree).get_nodes_in_group("court_plot"):
		total += 1
		match n.state:
			"ripe":
				ripe += 1
			"growing":
				growing += 1
	EventBus.farm_status.emit(ripe, growing, total)

func _build_crop_plants() -> void:
	if crops is MeshInstance3D:
		(crops as MeshInstance3D).mesh = null
	var kind: int = absi(plot_id.hash()) % 3
	for z in 3:
		for x in 3:
			var p := Vector3((float(x) - 1.0) * 0.62, 0.10, (float(z) - 1.0) * 0.62)
			crops.add_child(_make_plant(kind, p))

func _make_plant(kind: int, pos: Vector3) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.position = pos
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	match kind:
		0:
			var s := SphereMesh.new()
			s.radius = 0.20
			s.height = 0.28
			m.mesh = s
			CourtyardVisuals.apply_toon(m, Color(0.42, 0.72, 0.32), Color(0.22, 0.42, 0.18))
		1:
			var c := CylinderMesh.new()
			c.top_radius = 0.04
			c.bottom_radius = 0.11
			c.height = 0.38
			m.mesh = c
			CourtyardVisuals.apply_toon(m, Color(0.88, 0.48, 0.18), Color(0.62, 0.28, 0.10))
		_:
			var s2 := SphereMesh.new()
			s2.radius = 0.16
			s2.height = 0.24
			m.mesh = s2
			CourtyardVisuals.apply_toon(m, Color(0.92, 0.90, 0.82), Color(0.70, 0.62, 0.50))
	return m

func _refresh():
	match state:
		"fallow":
			crops.visible = false
			_scale_target = Vector3(0.18, 0.18, 0.18)
			CourtyardVisuals.apply_toon(soil, Color(0.50, 0.40, 0.28))
		"tilled":
			crops.visible = false
			_scale_target = Vector3(0.18, 0.18, 0.18)
			CourtyardVisuals.apply_toon(soil, Color(0.38, 0.26, 0.16))
		"growing":
			crops.visible = true
			var prog := clampf(float(grow_days) / float(maxi(grow_needed, 1)), 0.0, 1.0)
			_scale_target = Vector3.ONE * lerpf(0.28, 0.92, prog)
			CourtyardVisuals.apply_toon(soil, Color(0.40, 0.28, 0.18))
		"ripe":
			crops.visible = true
			_scale_target = Vector3(1.02, 1.02, 1.02)
			CourtyardVisuals.apply_toon(soil, Color(0.40, 0.28, 0.18))

func _zh(s: String) -> String:
	if s == "growing":
		return "生长 %d/%d 日" % [grow_days, grow_needed]
	return {"fallow": "荒芜", "tilled": "已翻土", "ripe": "可收获"}[s]
