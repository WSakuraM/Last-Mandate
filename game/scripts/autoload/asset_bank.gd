extends Node
## 资源库路径表：模型 / 贴图 / 声音统一从这里取。

const ROOT := "res://assets"
const MODELS := ROOT + "/models"
const AUDIO := ROOT + "/audio"

const MODEL_CATS := {
	"materials": MODELS + "/materials",
	"vegetation": MODELS + "/vegetation",
	"creatures": MODELS + "/creatures",
	"characters": MODELS + "/characters",
	"props": MODELS + "/props",
	"ui": MODELS + "/ui",
}

## 逻辑名 → 优先 ogg（Kenney），回退 wav 占位
const SFX := {
	"click": ["sfx/ui/click.ogg", "sfx/ui/click.wav"],
	"toast": ["sfx/ui/toast.ogg", "sfx/ui/toast.wav"],
	"plant": ["sfx/interact/plant.ogg", "sfx/interact/plant.wav"],
	"harvest": ["sfx/interact/harvest.ogg", "sfx/interact/harvest.wav"],
	"sell": ["sfx/interact/sell.ogg", "sfx/interact/sell.wav"],
	"forage": ["sfx/interact/forage.ogg", "sfx/interact/forage.wav"],
	"fish": ["sfx/interact/fish.ogg", "sfx/interact/fish.wav"],
	"dialogue": ["dialogue/blip.ogg", "dialogue/blip.wav"],
	"rain": ["weather/rain.ogg", "weather/rain.wav"],
	"wind": ["weather/wind.ogg", "weather/wind.wav"],
	"snow": ["weather/snow.ogg", "weather/snow.wav"],
	"ambient_yard": ["ambient/yard_day.ogg", "ambient/yard_day.wav"],
	"music_manor": ["music/manor_soft.ogg", "music/manor_soft.wav"],
}

func model_path(category: String, filename: String) -> String:
	var base: String = str(MODEL_CATS.get(category, MODELS))
	return "%s/%s" % [base, filename]

func has_model(category: String, filename: String) -> bool:
	return ResourceLoader.exists(model_path(category, filename))

func load_texture(category: String, filename: String) -> Texture2D:
	var p := model_path(category, filename)
	if not ResourceLoader.exists(p):
		return null
	return load(p) as Texture2D

func audio_path(key: String) -> String:
	if not SFX.has(key):
		return ""
	var candidates: Array = SFX[key]
	for rel in candidates:
		var p := "%s/%s" % [AUDIO, rel]
		if ResourceLoader.exists(p):
			return p
	## 尚未导入时也返回首选路径，便于编辑器首次导入
	if candidates.size() > 0:
		return "%s/%s" % [AUDIO, candidates[0]]
	return ""

func has_audio(key: String) -> bool:
	return audio_path(key) != ""

func load_stream(key: String) -> AudioStream:
	var p := audio_path(key)
	if p == "":
		return null
	if not ResourceLoader.exists(p):
		return null
	return load(p) as AudioStream
