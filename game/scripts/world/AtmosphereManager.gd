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
var _butterflies: GPUParticles3D
var _leaves: GPUParticles3D
var _birds: Node3D
var _current_weather: int = Weather.CLEAR
var _is_night: bool = false
var _pulse_t := 0.0

# 夜召堂（与 CourtyardLayout 对齐）
const HALL_POS := CourtyardLayout.NIGHT_HALL
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
	_butterflies = _create_butterflies()
	add_child(_butterflies)
	_leaves = _create_leaves()
	add_child(_leaves)
	_birds = _create_birds()
	add_child(_birds)
	_refresh_visibility()

func _process(delta: float) -> void:
	# 根据夜召状态切换昼夜粒子
	var was_night := _is_night
	_is_night = IssueManager.night_council_active
	if _is_night != was_night:
		_refresh_visibility()
	_pulse_t += delta
	_pulse_lanterns()
	if _birds:
		_birds.rotation.y += delta * 0.22

# ── 天气控制 ──

func set_weather(w: int):
	if w == _current_weather:
		return
	_current_weather = w
	_refresh_visibility()

func refresh() -> void:
	_refresh_visibility()

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
	if _butterflies:
		_butterflies.emitting = (not _is_night) and (season == 0 or season == 1)
	if _leaves:
		_leaves.emitting = (not _is_night) and season == 2
	if _birds:
		_birds.visible = not _is_night

func _pulse_lanterns() -> void:
	if not _is_night:
		return
	var energy: float = 0.7 + 0.35 * sin(_pulse_t * 2.2)
	for n in get_tree().get_nodes_in_group("lantern_glow"):
		if n is MeshInstance3D and (n as MeshInstance3D).material_override is StandardMaterial3D:
			((n as MeshInstance3D).material_override as StandardMaterial3D).emission_energy = energy

# ── 粒子工厂 ──

func _create_dust_motes() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "DustMotes"
	p.amount = 20
	p.lifetime = 8.0
	p.explosiveness = 0.0
	p.randomness = 1.0
	p.visibility_aabb = AABB(Vector3(-30, -2, -30), Vector3(60, 7, 60))

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
	p.randomness = 1.0
	p.visibility_aabb = AABB(Vector3(-30, 0, -30), Vector3(60, 6, 60))

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
	p.randomness = 0.8

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
	# 灶房烟囱
	var kitchen := CourtyardLayout.WEST_WING
	p.position = Vector3(kitchen.x + 4.2, 5.0, kitchen.z + 1.5)
	p.emitting = true
	return p

func _create_rain() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "Rain"
	p.amount = 300
	p.lifetime = 1.5
	p.explosiveness = 0.0
	p.randomness = 1.0
	p.visibility_aabb = AABB(Vector3(-35, 0, -35), Vector3(70, 20, 70))

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
	p.randomness = 1.0
	p.visibility_aabb = AABB(Vector3(-35, 0, -35), Vector3(70, 20, 70))

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

func _create_butterflies() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "Butterflies"
	p.amount = 8
	p.lifetime = 7.0
	p.randomness = 1.0
	p.visibility_aabb = AABB(Vector3(-22, 0, -22), Vector3(44, 8, 44))
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 80.0
	mat.initial_velocity_min = 0.4
	mat.initial_velocity_max = 1.1
	mat.gravity = Vector3(0, 0.02, 0)
	mat.scale_min = 0.05
	mat.scale_max = 0.10
	mat.color = Color(0.95, 0.55, 0.72, 0.85)
	p.process_material = mat
	var mesh := SphereMesh.new()
	mesh.radius = 0.04
	mesh.height = 0.06
	p.draw_pass_1 = mesh
	p.position = Vector3(0, 1.4, -6)
	p.emitting = false
	return p

func _create_leaves() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "AutumnLeaves"
	p.amount = 36
	p.lifetime = 8.0
	p.randomness = 1.0
	p.visibility_aabb = AABB(Vector3(-28, 0, -28), Vector3(56, 12, 56))
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.4, -1, 0.1)
	mat.spread = 40.0
	mat.initial_velocity_min = 0.4
	mat.initial_velocity_max = 1.2
	mat.gravity = Vector3(0, -0.18, 0)
	mat.scale_min = 0.06
	mat.scale_max = 0.14
	mat.color = Color(0.82, 0.42, 0.16, 0.8)
	p.process_material = mat
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.12, 0.02, 0.08)
	p.draw_pass_1 = mesh
	p.position = Vector3(0, 6, 0)
	p.emitting = false
	return p

func _create_birds() -> Node3D:
	var flock := Node3D.new()
	flock.name = "Birds"
	flock.position = Vector3(0, 9.5, 0)
	for i: int in range(4):
		var b := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.09
		s.height = 0.12
		b.mesh = s
		var ang := float(i) / 4.0 * TAU
		b.position = Vector3(cos(ang) * 11.0, sin(float(i)) * 0.6, sin(ang) * 11.0)
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.18, 0.18, 0.2)
		b.material_override = mat
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flock.add_child(b)
	return flock
