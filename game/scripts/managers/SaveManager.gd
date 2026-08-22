extends Node
# 《末命》存档单例（自动加载）
# 跨幕保留 Traits / 关系 / MemoryFragments。本切片提供最小可用落盘。

const SAVE_PATH := "user://save.json"

func save_state(data: Dictionary):
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_state() -> Dictionary:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var p := JSON.new()
			if p.parse(txt) == OK:
				return p.data
	return {}
