extends Node
## 声音总控：动效 / 天气 / 场景环境 / 对话提示音。
## 资源来自 res://assets/audio/（见 AssetBank）。

var _sfx: AudioStreamPlayer
var _sfx2: AudioStreamPlayer
var _weather: AudioStreamPlayer
var _ambient: AudioStreamPlayer
var _music: AudioStreamPlayer
var _weather_key: String = ""

func _ready() -> void:
	_sfx = _make_player("Sfx")
	_sfx2 = _make_player("Sfx2")
	_weather = _make_player("Weather")
	_ambient = _make_player("Ambient")
	_music = _make_player("Music")
	_weather.volume_db = -8.0
	_ambient.volume_db = -14.0
	_music.volume_db = -18.0
	await get_tree().process_frame
	play_ambient("ambient_yard")
	play_music("music_manor")
	if has_node("/root/WorldClock"):
		WorldClock.weather_changed.connect(_on_weather)
		WorldClock.disaster_changed.connect(_on_disaster)
		_on_weather(WorldClock.weather)
	GameState.toast_requested.connect(_on_toast)

func _on_toast(text: String) -> void:
	## 只对关键收益提示响一声，避免天气旁白刷屏
	if text.begins_with("+") or "文" in text or "气力" in text:
		play("toast")

func _make_player(p_name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = p_name
	add_child(p)
	return p

func play(key: String) -> void:
	var stream := AssetBank.load_stream(key)
	if stream == null:
		return
	var player := _sfx if not _sfx.playing else _sfx2
	player.stream = stream
	player.play()

func play_ambient(key: String) -> void:
	var stream := AssetBank.load_stream(key)
	if stream == null:
		return
	_enable_loop(stream)
	_ambient.stream = stream
	_ambient.play()

func play_music(key: String) -> void:
	var stream := AssetBank.load_stream(key)
	if stream == null:
		return
	_enable_loop(stream)
	_music.stream = stream
	_music.play()

func _enable_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

func _on_weather(weather: int) -> void:
	var key := ""
	match weather:
		WorldClock.Weather.RAIN:
			key = "rain"
		WorldClock.Weather.WIND:
			key = "wind"
		WorldClock.Weather.SNOW:
			key = "snow"
		_:
			key = ""
	_set_weather_loop(key)

func _on_disaster(kind: String) -> void:
	if kind == "storm":
		_set_weather_loop("rain")
		_weather.volume_db = -4.0
	elif kind == "locust":
		play("toast")
	else:
		_weather.volume_db = -8.0
		_on_weather(WorldClock.weather)

func _set_weather_loop(key: String) -> void:
	if key == _weather_key:
		return
	_weather_key = key
	if key == "":
		_weather.stop()
		return
	var stream := AssetBank.load_stream(key)
	if stream == null:
		_weather.stop()
		return
	## 氛围循环（ogg / wav）
	_enable_loop(stream)
	_weather.stream = stream
	_weather.play()
