extends Node
# 《末命》全局资源管理单例（自动加载）
# 五核心资源 + 气数(MandateDecay) + 时间轴。逻辑内核与视觉无关。

var r := {
	"treasury": 50.0,      # 国库
	"people": 50.0,        # 民心
	"border_army": 50.0,   # 边军
	"court_order": 50.0,   # 朝堂秩序
	"emperor_heart": 50.0  # 君心
}
var mandate_decay := 12.0   # 气数：0=天命尚存, 100=气数已尽（不可清零，最低维持4）
var day := 1
var season := 0            # 0春 1夏 2秋 3冬
var year := 1627           # 天启七年，信王时期

signal resources_changed(state: Dictionary)
signal mandate_changed(value: float)
signal day_passed(day: int, season: int, year: int)
signal game_over()

func get_state() -> Dictionary:
	var s := r.duplicate()
	s["mandate_decay"] = mandate_decay
	s["day"] = day
	s["season"] = season
	s["year"] = year
	return s

func add(key: String, amount: float):
	if r.has(key):
		r[key] = clampf(r[key] + amount, 0.0, 100.0)
		resources_changed.emit(get_state())

func consume(key: String, amount: float):
	add(key, -amount)

func add_mandate(amount: float):
	mandate_decay = clampf(mandate_decay + amount, 4.0, 100.0)
	mandate_changed.emit(mandate_decay)
	if mandate_decay >= 100.0:
		game_over.emit()

func tick_day():
	day += 1
	if day > 90:
		day = 1
		season = (season + 1) % 4
		if season == 0:
			year += 1
	add_mandate(0.4)        # 王朝衰势，气数缓增
	add("people", -0.1)      # 苛政之下民心缓降（示例）
	day_passed.emit(day, season, year)
	resources_changed.emit(get_state())
