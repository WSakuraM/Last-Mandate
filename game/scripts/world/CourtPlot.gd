extends Node3D
class_name CourtPlot
# 王府菜圃：按季节选种 → 分阶段生长（芽/苗/叶/熟）→ 收获。
# 生长按游戏日推进（ResourceManager.day_passed）；天数随菜种与季节变化。

var plot_id := "plot"
var plot_scene_path := "res://assets/models/props/plot_01.tscn"
## fallow → growing（含芽/苗/叶）→ ripe → fallow
var state := "fallow"
var near := false
var _cd := 0.0
var grow_days := 0
var grow_needed := 2
var crop_id := ""
var crop_name := ""
var _stage := ""   # "" | sprout | seedling | leafy | ripe
var _ring: MeshInstance3D
var _ring_a := 0.0
var _scale_target := Vector3.ONE
var _mark: InteractMark
var _ripe_pulse := 0.0
var _stage_label: Label3D

var soil: MeshInstance3D
var crops: Node3D

const BASE_TREASURY := 4.0
const BASE_PEOPLE := 1.0
const TILL_COST := 0.5
const HARVEST_PURSE_SHARE := 0.7
const HARVEST_TREASURY_SHARE := 0.3

## 菜种：base_days 基础生长日；season_affinity[春夏秋冬] 天数倍率（<1 更快）；yield_mult 产量
const CROPS := {
	"greens": {
		"name": "青菜",
		"base_days": 2,
		"season_affinity": [0.75, 1.0, 1.0, 1.35],
		"yield_mult": 0.9,
		"mesh": 0,
		"color": Color(0.42, 0.72, 0.32),
		"shadow": Color(0.22, 0.42, 0.18),
		"blurb": "春播最宜，长得快",
	},
	"radish": {
		"name": "萝卜",
		"base_days": 3,
		"season_affinity": [1.0, 1.15, 0.8, 1.1],
		"yield_mult": 1.15,
		"mesh": 1,
		"color": Color(0.88, 0.48, 0.18),
		"shadow": Color(0.62, 0.28, 0.10),
		"blurb": "秋收最肥",
	},
	"cabbage": {
		"name": "白菜",
		"base_days": 4,
		"season_affinity": [1.15, 1.25, 0.95, 0.85],
		"yield_mult": 1.3,
		"mesh": 2,
		"color": Color(0.86, 0.90, 0.72),
		"shadow": Color(0.55, 0.62, 0.42),
		"blurb": "冬藏耐寒，产量高",
	},
}

## 生长阶段：进度阈值 → 显示名 / 缩放 / 色调
const STAGES := [
	{"id": "sprout", "zh": "出芽", "min": 0.0, "scale": 0.28, "tint": Color(0.55, 0.78, 0.42)},
	{"id": "seedling", "zh": "青苗", "min": 0.34, "scale": 0.52, "tint": Color(0.45, 0.72, 0.34)},
	{"id": "leafy", "zh": "成叶", "min": 0.67, "scale": 0.82, "tint": Color(0.40, 0.68, 0.30)},
	{"id": "ripe", "zh": "成熟", "min": 1.0, "scale": 1.05, "tint": Color(1.15, 1.05, 0.7)},
]

static var _last_ripe_announce_day := -1

func _ready():
	add_to_group("court_plot")
	var path := plot_scene_path if plot_scene_path != "" else "res://assets/models/props/plot_01.tscn"
	var inst: Node3D = load(path).instantiate()
	inst.scale = Vector3(0.86, 0.86, 0.86)
	add_child(inst)
	CourtyardProps.enhance_plot(inst)
	soil = inst.get_node("Soil")
	crops = inst.get_node("Crops")

	var area := Area3D.new()
	area.name = "Detect"
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.45
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
	_mark.show_mode = "near"
	_mark.important = false
	_mark.activated.connect(tend)
	add_child(_mark)

	_stage_label = Label3D.new()
	_stage_label.font_size = 36
	_stage_label.pixel_size = 0.01
	_stage_label.position = Vector3(0, 1.05, 0)
	_stage_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_stage_label.no_depth_test = true
	_stage_label.outline_size = 6
	_stage_label.outline_modulate = Color(0.12, 0.08, 0.04, 0.85)
	_stage_label.visible = false
	add_child(_stage_label)

	ResourceManager.day_passed.connect(_on_day_passed)
	_refresh()
	_sync_mark_mode()
	_broadcast_farm()

func _on_body_entered(b):
	if b.is_in_group("player"):
		near = true
		EventBus.interact_prompt.emit(_prompt_text())
		_update_stage_label()

func _on_body_exited(b):
	if b.is_in_group("player"):
		near = false
		if _stage_label:
			_stage_label.visible = false
		call_deferred("_sync_plot_prompt")

func _sync_plot_prompt() -> void:
	var tree := get_tree()
	if tree == null:
		return
	for n in tree.get_nodes_in_group("court_plot"):
		if n.near:
			EventBus.interact_prompt.emit(n._prompt_text())
			return
	EventBus.interact_hide.emit()

static func wilt_all_crops() -> void:
	var tree := Engine.get_main_loop()
	if tree == null or not (tree is SceneTree):
		return
	for n in (tree as SceneTree).get_nodes_in_group("court_plot"):
		n.wilt_to_fallow()

func wilt_to_fallow() -> void:
	if state in ["growing", "ripe", "tilled"]:
		state = "fallow"
		grow_days = 0
		_stage = ""
		crop_id = ""
		crop_name = ""
		_clear_plants()
		_refresh()
		_sync_mark_mode()
	_broadcast_farm()

func _process(delta):
	if IssueManager.night_council_active:
		return
	_cd = max(0.0, _cd - delta)
	if near and Input.is_key_pressed(KEY_E) and _cd <= 0.0 and _can_tend():
		tend()
		_cd = 0.45
	var want := 0.0
	if near and _can_tend():
		want = 0.62 if state == "ripe" else 0.48
	elif near and state == "growing":
		want = 0.18
	_ring_a = lerpf(_ring_a, want, 1.0 - exp(-10.0 * delta))
	if _ring:
		_ring.visible = _ring_a > 0.02
		(_ring.material_override as StandardMaterial3D).albedo_color.a = _ring_a
		_ring.rotation.y += delta * 0.8
	if crops and crops.visible:
		if state == "ripe":
			_ripe_pulse += delta * 3.2
			var pulse := 1.0 + 0.06 * sin(_ripe_pulse)
			crops.scale = _scale_target * pulse
		else:
			crops.scale = crops.scale.lerp(_scale_target, 1.0 - exp(-8.0 * delta))

func _on_day_passed(_day: int, _season: int, _year: int) -> void:
	if state != "growing":
		return
	grow_days += 1
	_apply_growth_progress()
	if grow_days >= grow_needed:
		state = "ripe"
		_stage = "ripe"
		_ripe_pulse = 0.0
		_refresh()
		_sync_mark_mode()
		if ResourceManager.total_day != _last_ripe_announce_day:
			_last_ripe_announce_day = ResourceManager.total_day
			var cn := crop_name if crop_name != "" else "菜"
			EventBus.narration.emit("%s熟了——走近金色 ?，按 E 收获。" % cn)
	if near:
		EventBus.interact_prompt.emit(_prompt_text())
		_update_stage_label()
	_broadcast_farm()

func tend():
	if state == "growing":
		var left := maxi(0, grow_needed - grow_days)
		var stage_zh := _stage_zh()
		EventBus.narration.emit("%s·%s · 再等 %d 日（%d/%d）。" % [
			crop_name if crop_name != "" else "菜", stage_zh, left, grow_days, grow_needed])
		return
	if not _can_tend():
		return
	match state:
		"fallow", "tilled":
			if ResourceManager.r["treasury"] < TILL_COST:
				EventBus.narration.emit("国库不足，无法开垦（需 %.1f）。" % TILL_COST)
				return
			ResourceManager.add("treasury", -TILL_COST)
			_pick_crop_for_season()
			state = "growing"
			grow_days = 0
			grow_needed = _growth_days_for_crop()
			_stage = "sprout"
			_rebuild_plants_for_crop()
			_check_sow_hooks()
			var aff := _season_fit_note()
			EventBus.narration.emit("下种%s · %s · 约 %d 游戏日后成熟%s" % [
				crop_name, String(CROPS[crop_id].get("blurb", "")), grow_needed, aff])
		"ripe":
			state = "fallow"
			_harvest()
			crop_id = ""
			crop_name = ""
			_stage = ""
			_clear_plants()
	_refresh()
	_sync_mark_mode()
	if crops and state == "growing":
		crops.scale = _scale_target * 1.12
	if near:
		EventBus.interact_prompt.emit(_prompt_text())
		_update_stage_label()
	_broadcast_farm()

func _can_tend() -> bool:
	return state in ["fallow", "tilled", "ripe"]

func _sync_mark_mode() -> void:
	if _mark == null:
		return
	match state:
		"ripe":
			_mark.set_important(true)
			_mark.set_show_mode("always")
			_mark.set_active(true)
		"fallow", "tilled":
			_mark.set_important(false)
			_mark.set_show_mode("near")
			_mark.set_active(true)
		"growing":
			_mark.set_important(false)
			_mark.set_show_mode("when_active")
			_mark.set_active(false)

## 按当前季节推荐菜种（同季略有轮换，避免六畦全一样）
func _pick_crop_for_season() -> void:
	var season: int = ResourceManager.season
	var preferred: Array[String] = []
	match season:
		0: preferred = ["greens", "greens", "radish"]
		1: preferred = ["greens", "radish", "cabbage"]
		2: preferred = ["radish", "radish", "cabbage"]
		_: preferred = ["cabbage", "cabbage", "radish"]
	var idx: int = absi(plot_id.hash() + ResourceManager.total_day) % preferred.size()
	crop_id = preferred[idx]
	crop_name = String(CROPS[crop_id]["name"])

func _growth_days_for_crop() -> int:
	var def: Dictionary = CROPS.get(crop_id, CROPS["greens"])
	var base: float = float(def.get("base_days", 2))
	var aff: Array = def.get("season_affinity", [1.0, 1.0, 1.0, 1.0])
	var si: int = clampi(ResourceManager.season, 0, 3)
	var days: int = int(round(base * float(aff[si])))
	days = clampi(days, 1, 6)
	if IssueManager.flags.get("farm_growth_boost", false):
		days = maxi(1, days - 1)
	return days

func _season_fit_note() -> String:
	var def: Dictionary = CROPS.get(crop_id, {})
	var aff: Array = def.get("season_affinity", [1.0, 1.0, 1.0, 1.0])
	var si: int = clampi(ResourceManager.season, 0, 3)
	var m: float = float(aff[si])
	if m <= 0.85:
		return "（当季宜种，长得快）"
	if m >= 1.2:
		return "（非当季，略慢）"
	return ""

func _apply_growth_progress() -> void:
	var prog := clampf(float(grow_days) / float(maxi(grow_needed, 1)), 0.0, 0.99)
	var new_stage := "sprout"
	var sc := 0.28
	for s in STAGES:
		if String(s["id"]) == "ripe":
			continue
		if prog >= float(s["min"]):
			new_stage = String(s["id"])
			sc = float(s["scale"])
	if new_stage != _stage:
		_stage = new_stage
		_apply_stage_visual()
	_scale_target = Vector3.ONE * sc

func _stage_zh() -> String:
	for s in STAGES:
		if String(s["id"]) == _stage:
			return String(s["zh"])
	return "生长"

func _prompt_text() -> String:
	var seasons: Array = ["春", "夏", "秋", "冬"]
	var sn: String = String(seasons[clampi(ResourceManager.season, 0, 3)])
	match state:
		"growing":
			return "%s·%s %d/%d 日 · 日过自长（%s）" % [
				crop_name if crop_name != "" else "菜", _stage_zh(),
				grow_days, grow_needed, sn]
		"ripe":
			return "%s已熟！按 E 或点金色 ?" % (crop_name if crop_name != "" else "菜")
		"fallow", "tilled":
			var tip := _season_sow_hint()
			return "按 E 开垦播种（耗 %.1f）· %s" % [TILL_COST, tip]
		_:
			return "照料菜圃"

func _season_sow_hint() -> String:
	match ResourceManager.season:
		0: return "今春宜青菜"
		1: return "今夏可种青菜/萝卜"
		2: return "今秋宜萝卜"
		_: return "今冬宜白菜"

func _update_stage_label() -> void:
	if _stage_label == null:
		return
	if not near or state == "fallow" or state == "tilled":
		_stage_label.visible = false
		return
	if state == "ripe":
		_stage_label.text = "%s·可收" % crop_name
		_stage_label.modulate = Color(1.0, 0.86, 0.35)
	else:
		_stage_label.text = "%s·%s" % [crop_name, _stage_zh()]
		_stage_label.modulate = Color(0.92, 0.88, 0.72)
	_stage_label.visible = true

func _check_sow_hooks():
	if not IssueManager.flags.get("first_sow_done", false):
		IssueManager.flags["first_sow_done"] = true
		EventBus.first_sow.emit()
	if ResourceManager.total_day >= 120 and not IssueManager.flags.get("last_sow_done", false):
		IssueManager.flags["last_sow_done"] = true
		IssueManager.add_memory("MF_A1_LAST_SOW", 8, \
			"最后的播种——旁白：你或许看不见收成", "Ⅰ")

func _harvest():
	var def: Dictionary = CROPS.get(crop_id, CROPS["greens"])
	var crop_yield: float = float(def.get("yield_mult", 1.0))
	var mult: float = [1.5, 1.0, 1.25, 0.4][ResourceManager.season] * crop_yield
	# 当季亲和再加成产量
	var aff: Array = def.get("season_affinity", [1.0, 1.0, 1.0, 1.0])
	var si: int = clampi(ResourceManager.season, 0, 3)
	var fit: float = float(aff[si])
	if fit <= 0.85:
		mult *= 1.12
	elif fit >= 1.2:
		mult *= 0.88
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
	var cn := crop_name if crop_name != "" else "菜"
	if drought_active:
		IssueManager.add_memory("MF_A1_DROUGHT_HARVEST", 6, \
			"旱象之下，菜畦瘦得可怜——几近颗粒无收", "Ⅲ")
		EventBus.narration.emit("旱象·%s减产：私囊 +%.0f · 国库 +%.1f · 民心 +%.1f%s" % [
			cn, p_gain, t_gain, people_gain, overflow_suffix])
	elif r > 1.1 and (ResourceManager.season == 0 or ResourceManager.season == 2):
		IssueManager.add_memory("MF_A1_BOUNTY_SHARE", 4, \
			"丰收时你让吴伯分些菜给街坊邻舍", "Ⅰ")
		EventBus.narration.emit("%s·%s丰收！私囊 +%.0f · 国库 +%.1f · 民心 +%.1f%s" % [
			sn, cn, p_gain, t_gain, people_gain, overflow_suffix])
	else:
		EventBus.narration.emit("收%s！私囊 +%.0f · 国库 +%.1f · 民心 +%.1f（%s）%s" % [
			cn, p_gain, t_gain, people_gain, sn, overflow_suffix])

static func _broadcast_farm() -> void:
	broadcast_farm_status()

static func broadcast_farm_status() -> void:
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

func _clear_plants() -> void:
	if crops == null:
		return
	for c in crops.get_children():
		c.queue_free()
	if crops is MeshInstance3D:
		(crops as MeshInstance3D).mesh = null

func _rebuild_plants_for_crop() -> void:
	_clear_plants()
	var def: Dictionary = CROPS.get(crop_id, CROPS["greens"])
	var kind: int = int(def.get("mesh", 0))
	var col: Color = def.get("color", Color(0.42, 0.72, 0.32))
	var sh: Color = def.get("shadow", Color(0.22, 0.42, 0.18))
	for z in 3:
		for x in 3:
			var p := Vector3((float(x) - 1.0) * 0.62, 0.10, (float(z) - 1.0) * 0.62)
			crops.add_child(_make_plant(kind, p, col, sh))
	_apply_stage_visual()

func _make_plant(kind: int, pos: Vector3, col: Color, sh: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.position = pos
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	match kind:
		0:
			var s := SphereMesh.new()
			s.radius = 0.20
			s.height = 0.28
			m.mesh = s
		1:
			var c := CylinderMesh.new()
			c.top_radius = 0.04
			c.bottom_radius = 0.12
			c.height = 0.42
			m.mesh = c
		_:
			var s2 := SphereMesh.new()
			s2.radius = 0.18
			s2.height = 0.26
			m.mesh = s2
	CourtyardVisuals.apply_toon(m, col, sh)
	return m

func _apply_stage_visual() -> void:
	if crops == null:
		return
	var tint := Color.WHITE
	for s in STAGES:
		if String(s["id"]) == _stage:
			tint = s.get("tint", Color.WHITE)
			break
	crops.modulate = tint if _stage != "ripe" else Color(1.2, 1.08, 0.72)

func _refresh():
	match state:
		"fallow", "tilled":
			if crops:
				crops.visible = false
				crops.modulate = Color.WHITE
			_scale_target = Vector3(0.18, 0.18, 0.18)
			CourtyardVisuals.apply_toon(soil, Color(0.50, 0.40, 0.28) if state == "fallow" else Color(0.38, 0.26, 0.16))
			if _stage_label:
				_stage_label.visible = false
		"growing":
			if crops:
				crops.visible = true
			_apply_growth_progress()
			CourtyardVisuals.apply_toon(soil, Color(0.40, 0.28, 0.18))
			_apply_stage_visual()
		"ripe":
			if crops:
				crops.visible = true
				crops.modulate = Color(1.2, 1.08, 0.72)
			_scale_target = Vector3(1.05, 1.05, 1.05)
			CourtyardVisuals.apply_toon(soil, Color(0.40, 0.28, 0.18))
	if near:
		_update_stage_label()
