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
var private_purse := 0.0     # 私囊结余：M1 经营积累，第一幕末充入 M2 国库初值
var day := 1
var total_day := 0         # 单调递增天数，用于第一幕收束判定（day 每季归零，此值不减）
var season := 0            # 0春 1夏 2秋 3冬
var year := 1627           # 天启七年，信王时期
const ACT1_SPAN_DAYS := 150  # 第一幕跨度（信王时期压缩为 150 游戏日），届时触发入继收束

## 季初岁禄 / 季例（≈ 90 日一季，对标原「三月」）
const SEASON_PURSE := 36.0
const SEASON_TREASURY := 12.0
const SEASON_PURSE_EDICT_MULT := 0.45   # 圣旨后藩王季例折减
const SEASON_TREASURY_EDICT_MULT := 0.40
const STIPEND_TREASURY_CUT := 0.65      # 拒中使后户部拨银折减

## 圣旨：藩王纳赋（所得越高，纳赋越多，比例一致）
const PRINCE_TAX_RATE := 0.18

## 第一幕末：私囊 → 第二幕登基国库种子
const PURSE_TO_ACT2_TREASURY := 0.15
const ACT2_TREASURY_SEED_CAP := 40.0
const KIND_TRAIT_SEED_BONUS := 5.0

## 月例（补季间节奏，比季例小）
const MIDMONTH_PURSE := 8.0
const MIDMONTH_INTERVAL := 30

signal resources_changed(state: Dictionary)
signal mandate_changed(value: float)
signal day_passed(day: int, season: int, year: int)
signal game_over()

func get_state() -> Dictionary:
	var s := r.duplicate()
	s["mandate_decay"] = mandate_decay
	s["private_purse"] = private_purse
	s["day"] = day
	s["total_day"] = total_day
	s["season"] = season
	s["year"] = year
	s["prince_tax_edict"] = is_prince_tax_active()
	return s

func is_prince_tax_active() -> bool:
	return bool(IssueManager.flags.get("prince_tax_edict", false))

func add(key: String, amount: float):
	if r.has(key):
		r[key] = clampf(r[key] + amount, 0.0, 100.0)
		resources_changed.emit(get_state())

## 正向增量受 [0,100] 钳制；返回实际入账与溢出（供旁白反馈）。
func add_capped(key: String, amount: float) -> Dictionary:
	if not r.has(key):
		return {"applied": 0.0, "overflow": maxf(amount, 0.0)}
	if amount <= 0.0:
		add(key, amount)
		return {"applied": amount, "overflow": 0.0}
	var before: float = r[key]
	var after: float = clampf(before + amount, 0.0, 100.0)
	var applied: float = after - before
	r[key] = after
	resources_changed.emit(get_state())
	return {"applied": applied, "overflow": maxf(amount - applied, 0.0)}

func consume(key: String, amount: float):
	add(key, -amount)

func add_private_purse(amount: float):
	private_purse += amount
	resources_changed.emit(get_state())

func add_mandate(amount: float):
	mandate_decay = clampf(mandate_decay + amount, 4.0, 100.0)
	mandate_changed.emit(mandate_decay)
	if mandate_decay >= 100.0:
		game_over.emit()

## 藩王所得（岁禄、菜畦等）：圣旨后按统一税率纳赋。
func add_prince_income(treasury_gross: float, purse_gross: float = 0.0, announce_tax: bool = true) -> Dictionary:
	if treasury_gross < 0.0:
		add("treasury", treasury_gross)
		treasury_gross = 0.0
	if purse_gross < 0.0:
		add_private_purse(purse_gross)
		purse_gross = 0.0
	var tax_t := 0.0
	var tax_p := 0.0
	if is_prince_tax_active():
		if treasury_gross > 0.0:
			tax_t = treasury_gross * PRINCE_TAX_RATE
		if purse_gross > 0.0:
			tax_p = purse_gross * PRINCE_TAX_RATE
	var net_t := treasury_gross - tax_t
	var net_p := purse_gross - tax_p
	var treasury_applied := 0.0
	var treasury_overflow := 0.0
	if net_t > 0.0:
		var cap: Dictionary = add_capped("treasury", net_t)
		treasury_applied = float(cap.applied)
		treasury_overflow = float(cap.overflow)
	elif net_t < 0.0:
		add("treasury", net_t)
		treasury_applied = net_t
	if net_p > 0.0:
		add_private_purse(net_p)
	if announce_tax and (tax_t + tax_p) > 0.05:
		EventBus.narration.emit("藩王纳赋 −%.1f 国库 · −%.0f 两" % [tax_t, tax_p])
	return {
		"treasury": treasury_applied,
		"purse": net_p,
		"tax_t": tax_t,
		"tax_p": tax_p,
		"treasury_overflow": treasury_overflow,
	}

func tick_day():
	total_day += 1
	var season_turn := false
	day += 1
	if day > 90:
		day = 1
		season = (season + 1) % 4
		if season == 0:
			year += 1
		season_turn = true
	var floor := 4.0 + (year - 1627) * 15.0 + float(total_day) * 0.03
	floor = clampf(floor, 4.0, 100.0)
	mandate_decay = max(mandate_decay + 0.4, floor)
	mandate_decay = clampf(mandate_decay, 4.0, 100.0)
	mandate_changed.emit(mandate_decay)
	if mandate_decay >= 100.0:
		game_over.emit()
	add("people", -0.1)
	if season_turn:
		pay_season_stipend()
	if total_day > 0 and total_day % MIDMONTH_INTERVAL == 0:
		pay_midmonth_allowance()
	if day % 7 == 0:
		add("treasury", -1.2)
		EventBus.narration.emit("本周府邸开销 −1.2 国库")
	day_passed.emit(day, season, year)
	resources_changed.emit(get_state())

## 季初：户部岁禄（公）+ 王府季例（私）。M1A1 教程结束后由 Act1Director 触发首季。
func pay_season_stipend() -> void:
	var seasons: Array = ["春", "夏", "秋", "冬"]
	var sn: String = String(seasons[season])
	var purse_gross: float = SEASON_PURSE
	var treasury_gross: float = SEASON_TREASURY
	var cuts: Array[String] = []
	if IssueManager.flags.get("prince_tax_edict", false):
		purse_gross *= SEASON_PURSE_EDICT_MULT
		treasury_gross *= SEASON_TREASURY_EDICT_MULT
		cuts.append("岁禄折减")
	if bool(IssueManager.flags.get("eunuch_refused", false)):
		treasury_gross *= STIPEND_TREASURY_CUT
		cuts.append("户部克扣")
	var net: Dictionary = add_prince_income(treasury_gross, purse_gross, false)
	var cut_note := ""
	if not cuts.is_empty():
		cut_note = "（%s）" % " · ".join(cuts)
	var tax_note := ""
	if float(net.get("tax_t", 0.0)) + float(net.get("tax_p", 0.0)) > 0.05:
		tax_note = " · 纳赋 %.0f%%" % (PRINCE_TAX_RATE * 100.0)
	EventBus.narration.emit("%s季岁禄 +%.1f 国库 · 季例 +%.0f 两%s%s" % [
		sn, float(net.treasury), float(net.purse), cut_note, tax_note
	])

## 月例：每 30 游戏日补一小笔私囊（走纳赋规则）。
func pay_midmonth_allowance() -> void:
	var net: Dictionary = add_prince_income(0.0, MIDMONTH_PURSE, false)
	var tax_note := ""
	if float(net.get("tax_p", 0.0)) > 0.05:
		tax_note = " · 纳赋 %.0f%%" % (PRINCE_TAX_RATE * 100.0)
	EventBus.narration.emit("月例 +%.0f 两私囊%s" % [float(net.purse), tax_note])

## 天灾后圣旨：藩王岁禄折减 + 开征纳赋（由 CalamityEvent 触发一次）。
func apply_prince_tax_edict() -> void:
	if IssueManager.flags.get("prince_tax_edict", false):
		return
	IssueManager.flags["prince_tax_edict"] = true
	resources_changed.emit(get_state())

## 第一幕收束：私囊折算为第二幕登基国库种子（有上限）；仁慈 Trait 额外加成。
func finalize_act1_treasury_seed() -> float:
	var seed: float = minf(private_purse * PURSE_TO_ACT2_TREASURY, ACT2_TREASURY_SEED_CAP)
	if bool(IssueManager.flags.get("kind_likely", false)):
		seed = minf(seed + KIND_TRAIT_SEED_BONUS, ACT2_TREASURY_SEED_CAP)
	seed = maxf(seed, 0.0)
	IssueManager.flags["act2_treasury_seed"] = seed
	return seed
