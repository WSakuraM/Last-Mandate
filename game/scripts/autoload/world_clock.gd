extends Node
## 四季 / 天气 / 天灾 / 日行动点（M1 轻量）。

signal day_changed(day: int)
signal season_changed(season: int)
signal weather_changed(weather: int)
signal disaster_changed(kind: String)
signal stamina_changed(value: int)

enum Season { SPRING, SUMMER, AUTUMN, WINTER }
enum Weather { CLEAR, RAIN, SNOW, WIND }

const SEASON_NAMES := ["春", "夏", "秋", "冬"]
const WEATHER_NAMES := ["晴", "雨", "雪", "风"]
const DAYS_PER_SEASON := 3
const STAMINA_MAX := 5
## 夜召前私囊软上限：超过则触发中使眼线压力
const PURSE_SOFT_CAP := 48

var day: int = 1
var season: int = Season.SPRING
var weather: int = Weather.CLEAR
## "" | drought | locust | storm | flood
var disaster: String = ""
var stamina: int = STAMINA_MAX
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_roll_weather(false)
	stamina_changed.emit(stamina)
	weather_changed.emit(weather)
	season_changed.emit(season)

func season_name() -> String:
	return SEASON_NAMES[clampi(season, 0, 3)]

func weather_name() -> String:
	return WEATHER_NAMES[clampi(weather, 0, 3)]

func clock_label() -> String:
	var d := disaster_name()
	if d != "":
		return "%s · 第%d日 · %s · %s" % [season_name(), day, weather_name(), d]
	return "%s · 第%d日 · %s" % [season_name(), day, weather_name()]

func disaster_name() -> String:
	match disaster:
		"drought":
			return "旱灾"
		"locust":
			return "蝗灾"
		"storm":
			return "暴雨"
		"flood":
			return "内涝"
		_:
			return ""

func reset_stamina() -> void:
	stamina = STAMINA_MAX
	stamina_changed.emit(stamina)

func spend_stamina(cost: int = 1, reason: String = "") -> bool:
	if cost <= 0:
		return true
	if stamina < cost:
		GameState.toast("今日气力不足——可到井边歇息，或等日尽")
		return false
	stamina -= cost
	stamina_changed.emit(stamina)
	if reason != "":
		GameState.toast("%s（气力 %d/%d）" % [reason, stamina, STAMINA_MAX])
	if stamina <= 0:
		advance_day("气力用尽，日影西斜")
	return true

func try_rest_at_well() -> void:
	if GameState.flags.get("rested_today", false):
		GameState.toast("今日已在井边歇过——气力要留到明日")
		return
	if stamina >= STAMINA_MAX:
		GameState.toast("气力尚足")
		return
	GameState.set_flag("rested_today", true)
	stamina = mini(STAMINA_MAX, stamina + 2)
	stamina_changed.emit(stamina)
	GameState.toast("井边歇了一歇（气力 %d/%d）" % [stamina, STAMINA_MAX])

func advance_day(reason: String = "") -> void:
	day += 1
	GameState.set_flag("rested_today", false)
	reset_stamina()
	_update_season()
	_clear_short_disaster()
	_roll_weather(true)
	_maybe_start_disaster()
	## 无亲随：夜静时可能丢一点菜（护仓效益）
	if GameState.guards <= 0 and GameState.veggies >= 2 and _rng.randf() < 0.28:
		GameState.add_veggies(-1)
		GameState.toast("夜里畦边缺人看……少了一棵菜")
	elif GameState.guards >= 1 and GameState.veggies >= 1 and _rng.randf() < 0.12:
		GameState.toast("亲随守夜，畦安然")
	day_changed.emit(day)
	if reason != "":
		GameState.toast(reason)
	else:
		GameState.toast("新的一日 · %s" % clock_label())
	get_tree().call_group("act1_director", "on_new_day")
	## 软上限压力：日更时若钱太多，中使眼线
	if GameState.money > effective_soft_cap() and not GameState.flags.get("night_summon_done", false):
		get_tree().call_group("act1_director", "on_purse_pressure")

func effective_soft_cap() -> int:
	## 节俭 Traits 略抬软上限；显得「做得有用」
	var cap := PURSE_SOFT_CAP
	if int(GameState.traits.get("thrift", 0)) >= 3:
		cap += 12
	return cap

func _update_season() -> void:
	var idx := int((day - 1) / DAYS_PER_SEASON) % 4
	if idx != season:
		season = idx
		season_changed.emit(season)
		GameState.toast("入%s了" % season_name())

func _roll_weather(announce: bool) -> void:
	## 季节偏置：春雨、夏晴热、秋风、冬雪
	var weights: Array[float] = [0.45, 0.25, 0.05, 0.25]
	match season:
		Season.SPRING:
			weights = [0.35, 0.4, 0.0, 0.25]
		Season.SUMMER:
			weights = [0.5, 0.3, 0.0, 0.2]
		Season.AUTUMN:
			weights = [0.4, 0.15, 0.05, 0.4]
		Season.WINTER:
			weights = [0.25, 0.1, 0.45, 0.2]
	if disaster == "drought":
		weights = [0.75, 0.05, 0.0, 0.2]
	elif disaster == "storm" or disaster == "flood":
		weights = [0.1, 0.7, 0.0, 0.2]
	elif disaster == "locust":
		weights = [0.55, 0.1, 0.0, 0.35]
	weather = _weighted_pick(weights)
	weather_changed.emit(weather)
	if announce:
		GameState.toast("%s了" % weather_name())

func _weighted_pick(weights: Array[float]) -> int:
	var total := 0.0
	for w in weights:
		total += w
	var r := _rng.randf() * total
	var acc := 0.0
	for i in weights.size():
		acc += weights[i]
		if r <= acc:
			return i
	return 0

func _clear_short_disaster() -> void:
	## 蝗/暴雨/涝：持续 1～2 日；旱由导演剧情管，不在此清
	if disaster in ["locust", "storm", "flood"]:
		if _rng.randf() < 0.55:
			_set_disaster("")

func _maybe_start_disaster() -> void:
	if disaster != "":
		return
	## 低概率，且第 3 日后才可能随机天灾（旱仍可由剧情强制）
	if day < 3:
		return
	var roll := _rng.randf()
	if season == Season.SUMMER and roll < 0.18:
		_set_disaster("locust")
	elif season == Season.SPRING and weather == Weather.RAIN and roll < 0.14:
		_set_disaster("storm")
	elif season == Season.AUTUMN and weather == Weather.RAIN and roll < 0.12:
		_set_disaster("flood")
	elif season == Season.SUMMER and weather == Weather.CLEAR and roll < 0.1 and not GameState.flags.get("vig_drought_done", false):
		_set_disaster("drought")
		GameState.set_drought(true)

func force_disaster(kind: String) -> void:
	_set_disaster(kind)
	if kind == "drought":
		GameState.set_drought(true)

func clear_disaster() -> void:
	if disaster == "drought":
		GameState.set_drought(false)
	_set_disaster("")

func _set_disaster(kind: String) -> void:
	if disaster == kind:
		return
	disaster = kind
	disaster_changed.emit(kind)
	if kind != "":
		GameState.toast("天灾将至：%s" % disaster_name())

## —— 对玩法的轻微数值影响 ——

func grow_multiplier() -> float:
	var m := 1.0
	match weather:
		Weather.RAIN:
			m *= 0.85
		Weather.SNOW:
			m *= 1.35
		Weather.WIND:
			m *= 1.05
		_:
			pass
	match disaster:
		"drought":
			m *= 1.45
		"locust":
			m *= 1.25
		"flood", "storm":
			m *= 1.2
		_:
			pass
	if GameState.traits.get("diligence", 0) >= 3:
		m *= 0.92
	return m

func price_mod_veg() -> float:
	if disaster == "drought":
		return 1.6
	if disaster == "locust":
		return 1.35
	if disaster == "flood" or disaster == "storm":
		return 0.85
	if weather == Weather.RAIN:
		return 0.95
	return 1.0

func price_mod_herb() -> float:
	if disaster == "drought":
		return 1.75
	if disaster == "locust":
		return 1.2
	if weather == Weather.SNOW:
		return 1.15
	return 1.0

func price_mod_fish() -> float:
	if disaster == "flood" or disaster == "storm":
		return 0.7
	if weather == Weather.RAIN:
		return 1.1
	return 1.0

func forage_bonus() -> int:
	## 春雨多野菜；蝗灾灌木空
	if disaster == "locust":
		return 0
	if season == Season.SPRING and weather == Weather.RAIN:
		return 1
	return 0

func shop_discount() -> int:
	## 节俭 Traits：店价少 2 文
	return 2 if int(GameState.traits.get("thrift", 0)) >= 2 else 0
