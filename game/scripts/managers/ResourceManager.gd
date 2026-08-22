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
var total_day := 0         # 单调递增天数，用于第一幕收束判定（day 每季归零，此值不减）
var season := 0            # 0春 1夏 2秋 3冬
var year := 1627           # 天启七年，信王时期
const ACT1_SPAN_DAYS := 150  # 第一幕跨度（信王时期压缩为 150 游戏日），届时触发入继收束

signal resources_changed(state: Dictionary)
signal mandate_changed(value: float)
signal day_passed(day: int, season: int, year: int)
signal game_over()

func get_state() -> Dictionary:
	var s := r.duplicate()
	s["mandate_decay"] = mandate_decay
	s["day"] = day
	s["total_day"] = total_day
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
	total_day += 1
	day += 1
	if day > 90:
		day = 1
		season = (season + 1) % 4
		if season == 0:
			year += 1
	# 王朝衰势：气数硬性缓增，且随 elapsed 时间抬升「命运下限」。
	# 即便玩家夜召全选善政，气数也只能被延缓、无法长期压在 4——时间本身即亡国之势（悲剧定轨）。
	var floor := 4.0 + (year - 1627) * 15.0 + float(total_day) * 0.03
	floor = clampf(floor, 4.0, 100.0)
	mandate_decay = max(mandate_decay + 0.4, floor)
	mandate_decay = clampf(mandate_decay, 4.0, 100.0)
	mandate_changed.emit(mandate_decay)
	if mandate_decay >= 100.0:
		game_over.emit()
	add("people", -0.1)      # 封地小民艰难，民心缓降
	day_passed.emit(day, season, year)
	resources_changed.emit(get_state())
