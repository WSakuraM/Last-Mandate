extends Node3D
# 氛围特效管理器：统一管理所有粒子系统（灰尘/萤火虫/炊烟/雨雪）。
# 由 Act1Director 在 _ready() 中实例化并 add_child。
# 参考：Planet Zoo 场景氛围音层 / Two Point Hospital 环境粒子。

enum Weather { CLEAR, RAIN, SNOW }

var _dust: GPUParticles3D
var _fireflies: GPUParticles3D
var _smoke: GPUParticles3D
var _rain: GPUParticles3D
var _snow: GPUParticles3D
var _current_weather: int = Weather.CLEAR
var _is_night: bool = false

# 夜召堂位置（与 Act1Director._setup_night_council_hall 对齐）
const HALL_POS := Vector3(18, 0, -18)
# 四角暖灯位置（与 Act1Director._build_courtyard 对齐）
const LAMP_POSITIONS := [
	Vector3(-26, 4, -26), Vector3(26, 4, -26),
	Vector3(-26, 4, 26),  Vector3(26, 4, 26)
]

func _ready():
	_dust = _create_dust_motes()
	add_child(_dust)
	_fireflies = _create_fireflies()
	add_child(_fireflies)
	_smoke = _create_chimney_smoke()
	add_child(_smoke)
	_rain = _create_rain()
	add_child(_rain)
	_snow = _create_snow()
	add_child(_snow)
	_refresh_visibility()

func _process(_delta):
	# 根据夜召状态切换昼夜粒子
	var was_night := _is_night
	_is_night = IssueManager.night_council_active
	if _is_night != was_night:
		_refresh_visibility()

# ── 天气控制 ──

func set_weather(w: int):
	if w == _current_weather:
		return
	_current_weather = w
	_refresh_visibility()

func get_weather() -> int:
	return _current_weather

# ── 可见性刷新 ──

func _refresh_visibility():
	# 季节 → 天气粒子（0春/1夏/2秋/3冬）
	var season: int = ResourceManager.season
	if _rain:
		_rain.emitting = (season == 1 and _current_weather == Weather.RAIN)
	if _snow:
		_snow.emitting = (season == 3 and _current_weather == Weather.SNOW)
	# 昼夜 → 氛围粒子
	if _dust:
		_dust.emitting = not _is_night
	if _fireflies:
		_fireflies.emitting = _is_night
	if _smoke:
		_smoke.emitting = true   # 炊烟常驻

# ── 粒子工厂 ──

func _create_dust_motes() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "DustMotes"
	p.amount = 80
	p.lifetime = 8.0
	p.explosiveness = 0.0
	p.particle_randomness_ratio = 1.0
	p.visibility_rect = AABB(Vector3(-30, 0, -30), Vector3(60, 5, 60))

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.05
	mat.initial_velocity_max = 0.15
	mat.gravity = Vector3(0, 0.02, 0)
	mat.scale_min = 0.03
	mat.scale_max = 0.08
	mat.color = Color(0.6, 0.52, 0.42, 0.35)
	p.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.02
	mesh.height = 0.04
	p.draw_pass_1 = mesh
	p.position = Vector3(0, 1.5, 0)
	p.emitting = true
	return p

func _create_fireflies() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "Fireflies"
	p.amount = 40
	p.lifetime = 6.0
	p.explosiveness = 0.0
	p.particle_randomness_ratio = 1.0
	p.visibility_rect = AABB(Vector3(-30, 0, -30), Vector3(60, 6, 60))

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.1
	mat.initial_velocity_max = 0.3
	mat.gravity = Vector3(0, 0.05, 0)
	mat.scale_min = 0.04
	mat.scale_max = 0.1
	# 暖黄自发光
	mat.color = Color(1.0, 0.8, 0.3, 0.8)
	p.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 0.06
	var mmat := StandardMaterial3D.new()
	mmat.albedo_color = Color(1.0, 0.85, 0.3)
	mmat.emission_enabled = true
	mmat.emission = Color(1.0, 0.8, 0.3)
	mmat.emission_energy = 3.0
	mesh.material = mmat
	p.draw_pass_1 = mesh
	p.position = Vector3(0, 2.0, 0)
	p.emitting = false   # 默认关闭，夜间开启
	return p

func _create_chimney_smoke() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "ChimneySmoke"
	p.amount = 30
	p.lifetime = 5.0
	p.explosiveness = 0.0
	p.particle_randomness_ratio = 0.8

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 15.0
	mat.initial_velocity_min = 0.3
	mat.initial_velocity_max = 0.6
	mat.gravity = Vector3(0, 0.1, 0)
	mat.scale_min = 0.1
	mat.scale_max = 0.3
	mat.color = Color(0.5, 0.45, 0.4, 0.25)
	p.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.08
	mesh.height = 0.16
	p.draw_pass_1 = mesh
	# 夜召堂屋顶位置
	p.position = Vector3(HALL_POS.x, 5.5, HALL_POS.z)
	p.emitting = true
	return p

func _create_rain() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "Rain"
	p.amount = 300
	p.lifetime = 1.5
	p.explosiveness = 0.0
	p.particle_randomness_ratio = 1.0
	p.visibility_rect = AABB(Vector3(-35, 0, -35), Vector3(70, 20, 70))

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 5.0
	mat.initial_velocity_min = 8.0
	mat.initial_velocity_max = 12.0
	mat.gravity = Vector3(0, -2.0, 0)
	mat.scale_min = 0.01
	mat.scale_max = 0.02
	mat.color = Color(0.6, 0.65, 0.7, 0.4)
	p.process_material = mat

	# 雨丝：细长盒
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.01, 0.15, 0.01)
	p.draw_pass_1 = mesh
	p.position = Vector3(0, 15, 0)
	p.emitting = false   # 默认关闭，夏季雨天开启
	return p

func _create_snow() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "Snow"
	p.amount = 150
	p.lifetime = 6.0
	p.explosiveness = 0.0
	p.particle_randomness_ratio = 1.0
	p.visibility_rect = AABB(Vector3(-35, 0, -35), Vector3(70, 20, 70))

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.5
	mat.gravity = Vector3(0, -0.3, 0)
	mat.scale_min = 0.02
	mat.scale_max = 0.06
	mat.color = Color(0.9, 0.9, 0.95, 0.6)
	p.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.02
	mesh.height = 0.04
	p.draw_pass_1 = mesh
	p.position = Vector3(0, 15, 0)
	p.emitting = false   # 默认关闭，冬季雪天开启
	return p
