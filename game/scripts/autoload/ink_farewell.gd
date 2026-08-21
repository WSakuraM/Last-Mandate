extends CanvasLayer
## 支线角色「水墨下线」短动画（凡人修仙传式宣纸水墨插页）。
## 帧：res://assets/models/characters/ink_farewell/{id}/01.png … 03.png

signal finished(character_id: String)

const FRAME_DIR := "res://assets/models/characters/ink_farewell/"
const HOLD_SEC := 0.9
const FADE_SEC := 0.45

var _busy: bool = false
var _skip_requested: bool = false
var _dim: ColorRect
var _frame: TextureRect
var _caption: Label
var _skip_hint: Label

const CAPTIONS := {
	"eunuch": "中使远去 · 账却留下",
	"gate_child": "童影入尘 · 脚印被风抹平",
	"weaver": "机杼声远 · 线头尚在门槛",
	"gate_soldier": "钝刀入夜 · 饷银仍在路上",
	"relief": "求赈人散 · 人心不散",
	"qiushui": "秋穗辞府 · 米记在膝上",
	"lin_sheng": "邸报成灰 · 字仍咬人",
	"zhou": "王妃袖上一点土",
	"shen": "刀上的锈 · 洗不掉",
	"liu": "半块粗糖 · 欠到太平",
}

func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_dim = ColorRect.new()
	_dim.name = "Dim"
	_dim.color = Color(0.08, 0.07, 0.06, 0.88)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)
	_frame = TextureRect.new()
	_frame.name = "Frame"
	_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	_frame.offset_left = 160.0
	_frame.offset_top = 40.0
	_frame.offset_right = -160.0
	_frame.offset_bottom = -90.0
	_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_frame.modulate = Color(1, 1, 1, 0)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_caption = Label.new()
	_caption.name = "Caption"
	_caption.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_caption.offset_top = -78.0
	_caption.offset_bottom = -42.0
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size", 22)
	_caption.add_theme_color_override("font_color", Color(0.92, 0.9, 0.86, 1))
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	_skip_hint = Label.new()
	_skip_hint.name = "SkipHint"
	_skip_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_skip_hint.offset_top = -36.0
	_skip_hint.offset_bottom = -10.0
	_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skip_hint.add_theme_font_size_override("font_size", 14)
	_skip_hint.add_theme_color_override("font_color", Color(0.7, 0.65, 0.58, 0.85))
	_skip_hint.text = "空格 / E 跳过"
	_skip_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_skip_hint)

func is_busy() -> bool:
	return _busy

func _input(event: InputEvent) -> void:
	if not _busy:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_skip_requested = true
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_skip_requested = true
		get_viewport().set_input_as_handled()

func play(character_id: String) -> void:
	if character_id.is_empty():
		return
	var flag := "ink_farewell_%s" % character_id
	if GameState.flags.get(flag, false):
		return
	if _busy:
		await finished
		return
	var frames := _load_frames(character_id)
	if frames.is_empty():
		push_warning("InkFarewell: missing frames for %s" % character_id)
		GameState.set_flag(flag, true)
		return
	_busy = true
	_skip_requested = false
	GameState.set_flag(flag, true)
	visible = true
	_caption.text = str(CAPTIONS.get(character_id, "人去 · 墨还在"))
	_frame.modulate.a = 0.0
	Sfx.play("toast")
	for i in frames.size():
		if _skip_requested:
			break
		_frame.texture = frames[i]
		var tw := create_tween()
		tw.tween_property(_frame, "modulate:a", 1.0, FADE_SEC)
		await tw.finished
		var hold := HOLD_SEC
		while hold > 0.0 and not _skip_requested:
			await get_tree().process_frame
			hold -= get_process_delta_time()
		if i < frames.size() - 1 and not _skip_requested:
			var tw2 := create_tween()
			tw2.tween_property(_frame, "modulate:a", 0.0, FADE_SEC * 0.7)
			await tw2.finished
	var tw_out := create_tween()
	tw_out.tween_property(_frame, "modulate:a", 0.0, FADE_SEC)
	await tw_out.finished
	visible = false
	_frame.texture = null
	_busy = false
	_skip_requested = false
	finished.emit(character_id)

func _load_frames(character_id: String) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	for n in range(1, 4):
		var path := "%s%s/%02d.png" % [FRAME_DIR, character_id, n]
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		if tex != null:
			out.append(tex)
	return out
