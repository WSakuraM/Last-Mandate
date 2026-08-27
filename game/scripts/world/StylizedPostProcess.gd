extends CanvasLayer
# 风格化后处理管理器：色彩分级 + 暗角 + 颗粒噪声。
# 由 Act1Director 在 _ready() 末尾实例化。
# 参考：Two Point Hospital 暖色调 / 版画质感独立游戏后处理。

var _overlay: ColorRect
var _material: ShaderMaterial

func _ready():
	layer = 5   # 3D 之上、HUD 之下
	# 根节点：全屏 Control，不拦截鼠标
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.name = "StylizedRoot"
	add_child(root)

	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 不拦截点击

	_material = ShaderMaterial.new()
	_material.shader = load("res://shaders/stylized_post.gdshader")
	# 默认参数：暗调厚涂基调
	_material.set_shader_parameter("color_steps", 5.0)
	_material.set_shader_parameter("posterize_strength", 0.12)
	_material.set_shader_parameter("vignette_intensity", 0.22)
	_material.set_shader_parameter("vignette_opacity", 0.16)
	_material.set_shader_parameter("grain_intensity", 0.0)
	_material.set_shader_parameter("grain_speed", 0.4)
	_material.set_shader_parameter("tint_color", Color(0.98, 0.93, 0.82))
	_material.set_shader_parameter("tint_strength", 0.10)
	_overlay.material = _material
	root.add_child(_overlay)

# ── 运行时可调参数（供 Act1Director / 夜召 / 煤山 调用） ──

func set_color_steps(steps: float):
	if _material:
		_material.set_shader_parameter("color_steps", steps)

func set_posterize(strength: float):
	if _material:
		_material.set_shader_parameter("posterize_strength", strength)

func set_grain(intensity: float):
	if _material:
		_material.set_shader_parameter("grain_intensity", intensity)

func set_vignette(intensity: float, opacity: float):
	if _material:
		_material.set_shader_parameter("vignette_intensity", intensity)
		_material.set_shader_parameter("vignette_opacity", opacity)

func set_tint(color: Color, strength: float) -> void:
	if _material:
		_material.set_shader_parameter("tint_color", color)
		_material.set_shader_parameter("tint_strength", strength)

# 夜召模式：加深暗角、减少色阶、增加颗粒（烛光聚焦感）
func enter_night_mode():
	set_vignette(0.7, 0.55)
	set_color_steps(3.0)
	set_grain(0.1)

# 日间模式：恢复默认（对齐 M1 暖亮参考）
func enter_day_mode():
	set_vignette(0.28, 0.22)
	set_color_steps(5.0)
	set_grain(0.035)
	set_posterize(0.28)

# 煤山终章：极暗、强暗角、高颗粒
func enter_meishan_mode():
	set_vignette(0.9, 0.7)
	set_color_steps(2.0)
	set_grain(0.15)
	set_posterize(0.8)
