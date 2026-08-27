extends RefCounted
class_name CourtyardVisuals
# 信王府庭院视觉：程序地面分区 + toon 材质（GTX 960 友好，无外部贴图依赖）。

const TOON_SHADER := preload("res://shaders/toon_lighting.gdshader")
const WATER_SHADER := preload("res://shaders/water_simple.gdshader")

static func make_toon(albedo: Color, shadow: Color = Color(0.38, 0.32, 0.26), wind: float = 0.0) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = TOON_SHADER
	mat.set_shader_parameter("albedo_color", albedo)
	mat.set_shader_parameter("shadow_color", shadow)
	mat.set_shader_parameter("steps", 5.0)
	mat.set_shader_parameter("wind_strength", wind)
	return mat

static func make_water(shallow: Color = Color(0.52, 0.78, 0.80, 0.82), deep: Color = Color(0.22, 0.46, 0.54, 0.88)) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = WATER_SHADER
	mat.set_shader_parameter("color_shallow", shallow)
	mat.set_shader_parameter("color_deep", deep)
	return mat

static func make_tiled_ground(name: String, size: Vector2, pos: Vector3, albedo: Color, variation: Color, seed: int, uv_scale: Vector2 = Vector2(8.0, 8.0)) -> MeshInstance3D:
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	mesh_inst.mesh = plane
	mesh_inst.position = pos
	var mat := make_toon(albedo)
	var tex := _noise_texture(albedo, variation, seed)
	mat.set_shader_parameter("albedo_tex", tex)
	mat.set_shader_parameter("use_texture", true)
	mat.set_shader_parameter("uv_scale", uv_scale)
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mesh_inst

static func build_ground(parent: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Ground"
	parent.add_child(root)

	# 主草地（暖绿，对齐 ref_C）
	root.add_child(make_tiled_ground(
		"GrassMain", Vector2(58, 58), Vector3(0, 0, 0),
		Color(0.46, 0.66, 0.34), Color(0.38, 0.54, 0.28), 101, Vector2(14.0, 14.0)
	))

	# 中轴石土路：府门 → 井 → 菜畦 → 正堂
	root.add_child(make_tiled_ground(
		"PathSpine", Vector2(4.2, 46), Vector3(0, 0.012, 2),
		Color(0.60, 0.48, 0.34), Color(0.50, 0.40, 0.28), 202, Vector2(2.0, 18.0)
	))
	root.add_child(make_tiled_ground(
		"PlazaWell", Vector2(8.5, 8.5), Vector3(0, 0.018, 3.2),
		Color(0.66, 0.62, 0.54), Color(0.56, 0.52, 0.46), 707, Vector2(4.5, 4.5)
	))
	root.add_child(make_tiled_ground(
		"SoilPlots", Vector2(12.5, 8.5), Vector3(0, 0.016, -5.8),
		Color(0.48, 0.36, 0.24), Color(0.40, 0.28, 0.18), 505, Vector2(6.0, 4.0)
	))
	root.add_child(make_tiled_ground(
		"PathHall", Vector2(12, 2.4), Vector3(7, 0.014, -11.5),
		Color(0.56, 0.44, 0.30), Color(0.46, 0.36, 0.24), 404, Vector2(6.0, 2.0)
	))
	root.add_child(make_tiled_ground(
		"PathWest", Vector2(10, 2.4), Vector3(-7.5, 0.014, -5.5),
		Color(0.56, 0.44, 0.30), Color(0.46, 0.36, 0.24), 808, Vector2(5.0, 2.0)
	))
	root.add_child(make_tiled_ground(
		"PathEast", Vector2(10, 2.4), Vector3(7.5, 0.014, 9),
		Color(0.56, 0.44, 0.30), Color(0.46, 0.36, 0.24), 909, Vector2(5.0, 2.0)
	))
	root.add_child(make_tiled_ground(
		"StoneGate", Vector2(12, 8), Vector3(0, 0.02, 23),
		Color(0.70, 0.68, 0.62), Color(0.58, 0.56, 0.50), 606, Vector2(6.0, 4.0)
	))
	root.add_child(make_tiled_ground(
		"PenDirt", Vector2(8, 7), Vector3(-18, 0.016, 14),
		Color(0.50, 0.42, 0.30), Color(0.42, 0.34, 0.24), 111, Vector2(4.0, 3.0)
	))
	root.add_child(make_tiled_ground(
		"StallYard", Vector2(7, 6), Vector3(14, 0.016, 14),
		Color(0.58, 0.48, 0.34), Color(0.48, 0.38, 0.26), 212, Vector2(3.5, 3.0)
	))
	root.add_child(make_tiled_ground(
		"PathNight", Vector2(10, 2.4), Vector3(10, 0.014, -16),
		Color(0.56, 0.44, 0.30), Color(0.46, 0.36, 0.24), 313, Vector2(5.0, 2.0)
	))
	root.add_child(make_tiled_ground(
		"PathKitchen", Vector2(10, 2.4), Vector3(-10, 0.014, -8),
		Color(0.56, 0.44, 0.30), Color(0.46, 0.36, 0.24), 414, Vector2(5.0, 2.0)
	))
	root.add_child(make_tiled_ground(
		"PathPond", Vector2(8, 2.2), Vector3(10, 0.014, 8),
		Color(0.56, 0.44, 0.30), Color(0.46, 0.36, 0.24), 515, Vector2(4.0, 2.0)
	))
	root.add_child(make_tiled_ground(
		"HallApron", Vector2(12, 4.0), Vector3(0, 0.018, -16.8),
		Color(0.68, 0.64, 0.56), Color(0.56, 0.52, 0.46), 616, Vector2(6.0, 3.0)
	))

static func apply_toon(mesh_inst: MeshInstance3D, albedo: Color, shadow: Color = Color(0.38, 0.32, 0.26), wind: float = 0.0) -> void:
	mesh_inst.material_override = make_toon(albedo, shadow, wind)

static func enable_wind(node: Node, strength: float = 0.12) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.material_override is ShaderMaterial:
			(mi.material_override as ShaderMaterial).set_shader_parameter("wind_strength", strength)
	for c in node.get_children():
		enable_wind(c, strength)

static func apply_season(world: Node3D, env: Environment, season: int) -> void:
	var grass_col := Color(0.46, 0.66, 0.34)
	var grass_var := Color(0.38, 0.54, 0.28)
	var sky_top := Color(0.42, 0.64, 0.94)
	var sky_hz := Color(0.86, 0.90, 0.96)
	var fog := Color(0.82, 0.86, 0.90)
	var fog_d := 0.0022
	match season:
		0:  # 春
			grass_col = Color(0.50, 0.72, 0.38)
			grass_var = Color(0.62, 0.78, 0.42)
			sky_top = Color(0.48, 0.70, 0.96)
		1:  # 夏
			grass_col = Color(0.32, 0.58, 0.28)
			grass_var = Color(0.26, 0.46, 0.22)
			sky_top = Color(0.28, 0.52, 0.90)
			fog_d = 0.0016
		2:  # 秋
			grass_col = Color(0.58, 0.52, 0.28)
			grass_var = Color(0.72, 0.48, 0.22)
			sky_top = Color(0.62, 0.58, 0.78)
			sky_hz = Color(0.94, 0.78, 0.58)
			fog = Color(0.90, 0.78, 0.62)
			fog_d = 0.0028
		3:  # 冬
			grass_col = Color(0.62, 0.66, 0.58)
			grass_var = Color(0.78, 0.80, 0.76)
			sky_top = Color(0.62, 0.70, 0.82)
			sky_hz = Color(0.88, 0.90, 0.92)
			fog = Color(0.88, 0.90, 0.94)
			fog_d = 0.0040
	var grass := world.get_node_or_null("Ground/GrassMain") as MeshInstance3D
	if grass and grass.material_override is ShaderMaterial:
		var gmat := grass.material_override as ShaderMaterial
		gmat.set_shader_parameter("albedo_color", grass_col)
		gmat.set_shader_parameter("albedo_tex", _noise_texture(grass_col, grass_var, 101 + season * 17))
	if env and env.sky and env.sky.sky_material is ProceduralSkyMaterial:
		var proc := env.sky.sky_material as ProceduralSkyMaterial
		proc.sky_top_color = sky_top
		proc.sky_horizon_color = sky_hz
		proc.ground_bottom_color = grass_col.darkened(0.15)
		proc.ground_horizon_color = grass_col.lerp(sky_hz, 0.45)
	if env:
		env.fog_light_color = fog
		env.fog_density = fog_d
	_tint_group(world, "season_foliage", [
		Color(0.38, 0.62, 0.30),
		Color(0.26, 0.52, 0.24),
		Color(0.70, 0.42, 0.18),
		Color(0.55, 0.58, 0.50),
	][season])
	_tint_group(world, "season_blossom", [
		Color(0.92, 0.62, 0.72),
		Color(0.42, 0.62, 0.32),
		Color(0.86, 0.48, 0.38),
		Color(0.78, 0.80, 0.82),
	][season])

static func _tint_group(world: Node3D, group: String, col: Color) -> void:
	for n in world.get_tree().get_nodes_in_group(group):
		if n is MeshInstance3D and (n as MeshInstance3D).material_override is ShaderMaterial:
			((n as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter("albedo_color", col)
			((n as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter("shadow_color", col.darkened(0.22))

static func apply_toon_recursive(node: Node, skip_emissive: bool = true) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if skip_emissive and mi.material_override is StandardMaterial3D:
			var sm := mi.material_override as StandardMaterial3D
			if sm.emission_enabled:
				return
		if mi.mesh:
			var std: StandardMaterial3D = mi.material_override if mi.material_override is StandardMaterial3D else null
			var col: Color = std.albedo_color if std else Color(0.5, 0.45, 0.4)
			apply_toon(mi, col, col.darkened(0.25))
	for c in node.get_children():
		apply_toon_recursive(c, skip_emissive)

static func setup_warm_sky(env: Environment) -> void:
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var proc := ProceduralSkyMaterial.new()
	proc.sky_top_color = Color(0.42, 0.64, 0.94)
	proc.sky_horizon_color = Color(0.86, 0.90, 0.96)
	proc.ground_bottom_color = Color(0.40, 0.58, 0.32)
	proc.ground_horizon_color = Color(0.70, 0.78, 0.62)
	proc.sun_angle_max = 38.0
	sky.sky_material = proc
	env.sky = sky

static func _noise_texture(base: Color, variation: Color, seed: int) -> ImageTexture:
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.07
	for y in 128:
		for x in 128:
			var n: float = noise.get_noise_2d(float(x), float(y))
			var t: float = clampf((n + 1.0) * 0.5, 0.0, 1.0)
			img.set_pixel(x, y, base.lerp(variation, t * 0.38))
	return ImageTexture.create_from_image(img)
