extends Node
## 全局存档灵魂（M1）。跨幕保留的数据放这里。

signal money_changed(value: int)
signal veggies_changed(value: int)
signal fish_changed(value: int)
signal herbs_changed(value: int)
signal hearts_changed(value: int)
signal guards_changed(value: int)
signal memory_added(id: String)
signal traits_changed
signal flags_changed
signal objective_changed
signal toast_requested(text: String)

var money: int = 20
var veggies: int = 0
var fish: int = 0
var herbs: int = 0
var hearts: int = 8
var guards: int = 0
var storage_level: int = 0
var act: int = 1
var memories: Array[String] = []
var traits := {
	"mercy": 0,
	"thrift": 0,
	"diligence": 0,
}

var drought: bool = false

var flags := {
	"met_aen": false,
	"first_harvest": false,
	"helped_qiushui": false,
	"crisis_done": false,
	"night_summon_done": false,
	"has_seed_bag": false,
	"learned_purse": false,
	"has_hoe": false,
	"has_net": false,
	"herb_unlocked": false,
	"vig_child_done": false,
	"vig_soldier_done": false,
	"vig_eunuch_done": false,
	"vig_well_done": false,
	"vig_weaver_done": false,
	"vig_gazette_done": false,
	"vig_drought_done": false,
	"vig_relief_done": false,
	"vig_locust_done": false,
	"vig_storm_done": false,
	"vig_flood_done": false,
	"shared_kitchen": false,
	"aen_sugar": false,
	"gate_open": false,
	"eunuch_open": false,
	"weaver_open": false,
	"relief_open": false,
	"lin_ready": false,
	"soldier_loyal": false,
	"guard_intro": false,
	"sold_once": false,
	"qiushui_resolved": false,
	"met_zhou": false,
	"shen_joined": false,
	"liu_met": false,
	"lovers_sugar": false,
	"rested_today": false,
	"purse_pressure_done": false,
}

## 售卖次数：越多单价越贱（防无限刷）
var sell_count: int = 0

func storage_cap() -> int:
	match storage_level:
		1:
			return 14
		2:
			return 22
		_:
			return 8

func inventory_count() -> int:
	return veggies + fish + herbs

func can_store(extra: int = 1) -> bool:
	return inventory_count() + extra <= storage_cap()

func add_money(delta: int, show_toast: bool = true) -> void:
	money = max(0, money + delta)
	money_changed.emit(money)
	if show_toast and delta != 0:
		toast_requested.emit(("+ %d 文" % delta) if delta > 0 else ("%d 文" % delta))
	_emit_objective()

func refresh_objective() -> void:
	_emit_objective()

func _try_add_stack(kind: String, delta: int) -> bool:
	if delta <= 0:
		match kind:
			"veg":
				veggies = max(0, veggies + delta)
				veggies_changed.emit(veggies)
			"fish":
				fish = max(0, fish + delta)
				fish_changed.emit(fish)
			"herb":
				herbs = max(0, herbs + delta)
				herbs_changed.emit(herbs)
		_emit_objective()
		return true
	if not can_store(delta):
		toast("仓储满了（%d/%d）——去售卖，或找吴伯扩仓" % [inventory_count(), storage_cap()])
		return false
	match kind:
		"veg":
			veggies += delta
			veggies_changed.emit(veggies)
			toast_requested.emit("+ 菜蔬 %d" % delta)
		"fish":
			fish += delta
			fish_changed.emit(fish)
			toast_requested.emit("+ 鱼 %d" % delta)
		"herb":
			herbs += delta
			herbs_changed.emit(herbs)
			toast_requested.emit("+ 药材 %d" % delta)
	_emit_objective()
	return true

func add_veggies(delta: int) -> void:
	_try_add_stack("veg", delta)

func add_fish(delta: int) -> void:
	_try_add_stack("fish", delta)

func add_herbs(delta: int) -> void:
	_try_add_stack("herb", delta)

func add_hearts(delta: int) -> void:
	hearts = clampi(hearts + delta, 0, 100)
	hearts_changed.emit(hearts)
	if delta > 0:
		toast_requested.emit("+ 人心 %d" % delta)
	_emit_objective()

func add_guards(delta: int) -> void:
	guards = clampi(guards + delta, 0, 6)
	guards_changed.emit(guards)
	if delta > 0:
		toast_requested.emit("+ 亲随 %d" % delta)
	_emit_objective()

func add_memory(id: String) -> void:
	if id in memories:
		return
	memories.append(id)
	memory_added.emit(id)

func bump_trait(key: String, amount: int = 1) -> void:
	if not traits.has(key):
		traits[key] = 0
	traits[key] = int(traits[key]) + amount
	traits_changed.emit()

func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value
	flags_changed.emit()
	_emit_objective()

func set_drought(on: bool) -> void:
	drought = on
	_emit_objective()

func get_grow_multiplier() -> float:
	var m := 0.65 if flags.get("has_hoe", false) else 1.0
	m *= WorldClock.grow_multiplier()
	return m

func _sell_fatigue() -> float:
	## 第 1 次全价；之后每次约 -12%，下限 0.55
	return maxf(0.55, 1.0 - float(sell_count) * 0.12)

func price_veggie() -> int:
	var base := 3
	var p := int(round(float(base) * WorldClock.price_mod_veg() * _sell_fatigue()))
	return maxi(1, p)

func price_fish() -> int:
	var base := 4
	var p := int(round(float(base) * WorldClock.price_mod_fish() * _sell_fatigue()))
	return maxi(2, p)

func price_herb() -> int:
	var base := 7
	var p := int(round(float(base) * WorldClock.price_mod_herb() * _sell_fatigue()))
	return maxi(3, p)

func toast(text: String) -> void:
	toast_requested.emit(text)

func _emit_objective() -> void:
	objective_changed.emit()

## 主线只钉：私囊 → 首获 → 阿恩谷种 → 秋穗 → 夜召
func get_objective() -> String:
	if flags.get("night_summon_done", false):
		return "夜召已至……"
	if not flags.get("learned_purse", false):
		return "主线：找吴伯，问清私囊与官银"
	if not flags.get("first_harvest", false):
		return "主线：菜畦播种并收获"
	if not flags.get("has_seed_bag", false):
		return "主线：与阿恩深谈，收下谷种"
	if not flags.get("crisis_done", false):
		return "主线：回应秋穗的家书"
	return "主线：再走一走——夜召将至"

func get_side_hint() -> String:
	if flags.get("night_summon_done", false):
		return ""
	var tips: PackedStringArray = []
	var d := WorldClock.disaster_name()
	if d != "":
		tips.append(d)
	if money > WorldClock.effective_soft_cap() and not flags.get("purse_pressure_done", false):
		tips.append("私囊过厚·眼线")
	if flags.get("gate_open", false) and (not flags.get("vig_child_done", false) or not flags.get("vig_soldier_done", false)):
		tips.append("府门")
	if flags.get("relief_open", false) and not flags.get("vig_relief_done", false):
		tips.append("求赈")
	if WorldClock.disaster == "locust" and not flags.get("vig_locust_done", false):
		tips.append("护蝗")
	if drought and not flags.get("herb_unlocked", false):
		tips.append("药圃")
	if inventory_count() >= storage_cap() - 1 and storage_level < 2:
		tips.append("扩仓")
	if hearts >= 18 and guards < 2 and flags.get("guard_intro", false):
		tips.append("亲随")
	if flags.get("has_seed_bag", false) and not flags.get("aen_sugar", false):
		tips.append("阿恩糖")
	var clock := "气力%d/%d · %s" % [WorldClock.stamina, WorldClock.STAMINA_MAX, WorldClock.clock_label()]
	if tips.is_empty():
		return "可选不挡结局 · " + clock
	return "可选·不挡结局：" + "·".join(tips) + " │ " + clock
