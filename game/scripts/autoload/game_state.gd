extends Node
## 全局存档灵魂（M1 最小集）。跨幕保留的数据放这里。

signal money_changed(value: int)
signal veggies_changed(value: int)
signal memory_added(id: String)
signal traits_changed

var money: int = 20
var veggies: int = 0
var act: int = 1
var memories: Array[String] = []
var traits := {
	"mercy": 0,
	"thrift": 0,
	"diligence": 0,
}

var flags := {
	"met_aen": false,
	"first_harvest": false,
	"helped_qiushui": false,
	"crisis_done": false,
	"night_summon_done": false,
	"has_seed_bag": false,
}

func add_money(delta: int) -> void:
	money = max(0, money + delta)
	money_changed.emit(money)

func add_veggies(delta: int) -> void:
	veggies = max(0, veggies + delta)
	veggies_changed.emit(veggies)

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
