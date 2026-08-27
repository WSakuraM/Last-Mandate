extends RefCounted
class_name CourtyardProps
# 信王府程序化道具与建筑（免费、GTX 960 友好；后续可同名 .tscn 替换）。

const WOOD := Color(0.52, 0.34, 0.24)
const WOOD_DARK := Color(0.38, 0.26, 0.18)
const WALL := Color(0.82, 0.78, 0.72)
const TILE := Color(0.42, 0.40, 0.38)
const TILE_DARK := Color(0.32, 0.28, 0.26)
const RED := Color(0.62, 0.18, 0.14)
const STONE := Color(0.58, 0.56, 0.52)
const FOLIAGE := Color(0.34, 0.58, 0.28)
const FOLIAGE_DARK := Color(0.26, 0.46, 0.22)
const BLOSSOM := Color(0.92, 0.62, 0.72)
const WATER := Color(0.38, 0.62, 0.68)

static func build_decorations(parent: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Decorations"
	parent.add_child(root)

	root.add_child(make_chinese_building("ZhengTang", CourtyardLayout.HALL, 10.5, 6.2, 5.2, "信王府"))
	root.add_child(make_chinese_building("ZaoFang", CourtyardLayout.WEST_WING, 6.2, 4.6, 3.6, "灶房"))
	var gate := make_gate_pavilion(CourtyardLayout.GATE)
	gate.scale = Vector3(0.94, 0.94, 0.94)
	root.add_child(gate)
	root.add_child(make_moon_gate(CourtyardLayout.MOON_GATE))
	root.add_child(make_stove(CourtyardLayout.WEST_WING + Vector3(4.2, 0, 1.5)))

	root.add_child(make_pond(CourtyardLayout.POND, 3.6))
	root.add_child(make_pier(CourtyardLayout.POND + Vector3(-3.8, 0, 0)))
	var stall := make_produce_stall(CourtyardLayout.STALL)
	stall.scale = Vector3(0.92, 0.92, 0.92)
	root.add_child(stall)
	var pen := make_animal_pen(CourtyardLayout.PEN)
	pen.scale = Vector3(0.95, 0.95, 0.95)
	root.add_child(pen)

	# 墙边树（≤30，现约 20）
	root.add_child(make_tree(Vector3(-22, 0, -16), 3.2, FOLIAGE))
	root.add_child(make_tree(Vector3(-23, 0, -4), 2.6, FOLIAGE_DARK))
	root.add_child(make_tree(Vector3(-24, 0, 20), 2.8, FOLIAGE_DARK))
	root.add_child(make_tree(Vector3(24, 0, -12), 3.0, FOLIAGE))
	root.add_child(make_tree(Vector3(23, 0, 20), 2.7, FOLIAGE))
	root.add_child(make_tree(Vector3(-8, 0, -22), 2.4, FOLIAGE))
	root.add_child(make_tree(Vector3(8, 0, -22), 2.5, FOLIAGE_DARK))
	root.add_child(make_cherry_tree(Vector3(22, 0, 2)))
	root.add_child(make_cherry_tree(Vector3(-21, 0, 6)))
	root.add_child(make_cherry_tree(Vector3(-12, 0, 16)))
	root.add_child(make_bamboo_grove(Vector3(-26, 0, -2)))
	root.add_child(make_bamboo_grove(Vector3(25, 0, -6)))
	root.add_child(make_tree(Vector3(-22, 0, 10), 2.7, FOLIAGE_DARK))
	root.add_child(make_tree(Vector3(22, 0, 16), 2.9, FOLIAGE))
	root.add_child(make_tree(Vector3(-10, 0, 8), 2.0, FOLIAGE_DARK))
	root.add_child(make_tree(Vector3(10, 0, 8), 2.1, FOLIAGE))
	root.add_child(make_tree(Vector3(16, 0, -8), 2.6, FOLIAGE))
	root.add_child(make_tree(Vector3(-6, 0, 16), 2.5, FOLIAGE_DARK))

	var lanterns: Array[Vector3] = [
		Vector3(0, 0, 14), Vector3(-3.6, 0, 5), Vector3(3.6, 0, 5),
		Vector3(-4.5, 0, -1), Vector3(4.5, 0, -1),
		Vector3(-8, 0, -12), Vector3(8, 0, -12),
		Vector3(12, 0, -16), Vector3(-12, 0, -8),
		Vector3(0, 0, 19), Vector3(-6, 0, 8), Vector3(6, 0, 8),
		Vector3(-16, 0, -12), Vector3(20, 0, -16),
	]
	for lp: Vector3 in lanterns:
		root.add_child(make_stone_lantern(lp))

	root.add_child(make_barrel(CourtyardLayout.STALL + Vector3(-2.4, 0, 1.6)))
	root.add_child(make_barrel(CourtyardLayout.STALL + Vector3(-1.2, 0, 1.8)))
	root.add_child(make_barrel(CourtyardLayout.WEST_WING + Vector3(2.8, 0, 2.4)))
	root.add_child(make_barrel(CourtyardLayout.WELL + Vector3(-2.4, 0, -1.2)))
	root.add_child(make_wood_pile(CourtyardLayout.WEST_WING + Vector3(3.4, 0, 3.2)))
	root.add_child(make_water_bucket(CourtyardLayout.WELL + Vector3(-1.6, 0, 1.4)))
	root.add_child(make_water_bucket(CourtyardLayout.WELL + Vector3(1.8, 0, 1.1)))
	root.add_child(make_water_bucket(CourtyardLayout.WEST_WING + Vector3(3.6, 0, 0.6)))

	root.add_child(make_bench(Vector3(-3.4, 0, 8.2), 0.0))
	root.add_child(make_bench(Vector3(3.4, 0, 8.2), 180.0))
	root.add_child(make_bench(CourtyardLayout.POND + Vector3(-2.2, 0, 3.4), 90.0))
	root.add_child(make_bench(Vector3(-4.2, 0, -16.5), 0.0))
	root.add_child(make_bench(Vector3(4.2, 0, -16.5), 180.0))
	root.add_child(make_bench(Vector3(-10.5, 0, 6.0), 90.0))

	var shrubs: Array[Vector3] = [
		Vector3(-10, 0, 18), Vector3(10, 0, 18), Vector3(-6, 0, 12),
		Vector3(6, 0, 12), Vector3(-12, 0, 2), Vector3(12, 0, 2),
		Vector3(-10, 0, -16), Vector3(10, 0, -16), Vector3(20, 0, -6),
		Vector3(-20, 0, -14), Vector3(6, 0, 22), Vector3(-6, 0, 22),
		Vector3(-4, 0, 16), Vector3(4, 0, 16), Vector3(-14, 0, 0),
		Vector3(16, 0, 0), Vector3(-16, 0, 20), Vector3(16, 0, 20),
		Vector3(-8, 0, -18), Vector3(8, 0, -18), Vector3(20, 0, -14),
		Vector3(-20, 0, 2), Vector3(4, 0, -14), Vector3(-4, 0, -14),
	]
	for sp: Vector3 in shrubs:
		root.add_child(make_shrub(sp))

	# 菜畦三面篱（南面开口通向井台；坐标随 CourtyardLayout 网格）
	var po := CourtyardLayout.PLOT_ORIGIN
	var cs := CourtyardLayout.PLOT_COL_SP
	var rs := CourtyardLayout.PLOT_ROW_SP
	var fx := po.x - cs - 1.0
	var tx := po.x + cs + 1.0
	var bz := po.z - 1.0
	var tz := po.z + rs + 1.0
	root.add_child(make_fence_row(Vector3(fx, 0, bz), Vector3(tx, 0, bz), 6))
	root.add_child(make_fence_row(Vector3(fx, 0, bz), Vector3(fx, 0, tz), 4))
	root.add_child(make_fence_row(Vector3(tx, 0, bz), Vector3(tx, 0, tz), 4))

	root.add_child(make_step_stones(Vector3(0, 0, 16), Vector3(0, 0, -16), 9))
	root.add_child(make_step_stones(Vector3(0, 0, 5), Vector3(14, 0, 13), 5))
	root.add_child(make_step_stones(Vector3(0, 0, 5), Vector3(-16, 0, -6), 5))
	root.add_child(make_clothesline(CourtyardLayout.WEST_WING + Vector3(5.2, 0, -1.8)))
	root.add_child(make_drying_rack(CourtyardLayout.WEST_WING + Vector3(1.6, 0, 3.8)))
	root.add_child(make_cart(CourtyardLayout.STALL + Vector3(3.4, 0, -0.6)))
	root.add_child(make_crate_stack(CourtyardLayout.STALL + Vector3(-2.8, 0, -1.4)))
	root.add_child(make_crate_stack(CourtyardLayout.WEST_WING + Vector3(4.6, 0, 0.2)))
	root.add_child(make_sack(CourtyardLayout.STALL + Vector3(1.6, 0, 1.4)))
	root.add_child(make_sack(CourtyardLayout.STALL + Vector3(2.1, 0, 1.1)))
	root.add_child(make_sack(CourtyardLayout.WEST_WING + Vector3(3.0, 0, 1.6)))
	root.add_child(make_scarecrow(Vector3(9.2, 0, -3.2)))
	root.add_child(make_flower_bed(Vector3(-5.5, 0, -16.2)))
	root.add_child(make_flower_bed(Vector3(5.5, 0, -16.2)))
	root.add_child(make_flower_bed(Vector3(-3.2, 0, -0.2)))
	root.add_child(make_flower_bed(Vector3(3.2, 0, -0.2)))
	root.add_child(make_trough(CourtyardLayout.PEN + Vector3(0.2, 0, -3.4)))
	root.add_child(make_millstone(Vector3(-11.5, 0, -3.5)))
	root.add_child(make_wash_basin(CourtyardLayout.WELL + Vector3(2.6, 0, 0.2)))

	var rocks: Array[Vector3] = [
		Vector3(-12, 0, 8), Vector3(9, 0, 18), Vector3(-7, 0, 19),
		Vector3(20, 0, -2), Vector3(-16, 0, -18), Vector3(4, 0, -14),
	]
	for rp: Vector3 in rocks:
		root.add_child(make_rock(rp, randf_range(0.55, 1.05)))

	var corners: Array[Vector3] = [
		Vector3(-28, 0, -28), Vector3(28, 0, -28), Vector3(-28, 0, 28), Vector3(28, 0, 28)
	]
	for cp: Vector3 in corners:
		root.add_child(make_corner_tower(cp))

	root.add_child(make_screen_walls())

static func make_chinese_building(build_name: String, pos: Vector3, width: float, depth: float, height: float, sign: String, yaw_deg: float = 0.0) -> Node3D:
	var hall := Node3D.new()
	hall.name = build_name
	hall.position = pos
	hall.rotation_degrees = Vector3(0, yaw_deg, 0)

	# 石阶
	for i in 3:
		var step := _box(Vector3(width + 1.6 - i * 0.4, 0.18, 0.7), Vector3(0, 0.09 + i * 0.18, depth * 0.5 + 0.8 + i * 0.35), STONE)
		hall.add_child(step)

	var base_y := 0.55
	hall.add_child(_box(Vector3(width, 0.35, depth), Vector3(0, base_y, 0), STONE))

	# 四柱
	var hx := width * 0.42
	var hz := depth * 0.38
	for c in [Vector3(-hx, 0, -hz), Vector3(hx, 0, -hz), Vector3(-hx, 0, hz), Vector3(hx, 0, hz)]:
		hall.add_child(_pillar(c + Vector3(0, base_y + height * 0.45, 0), height * 0.9))

	# 墙板
	hall.add_child(_box(Vector3(width - 0.8, height * 0.72, 0.25), Vector3(0, base_y + height * 0.5, -hz), WALL))
	hall.add_child(_box(Vector3(width - 0.8, height * 0.72, 0.25), Vector3(0, base_y + height * 0.5, hz), WALL))
	hall.add_child(_box(Vector3(0.25, height * 0.72, depth - 0.6), Vector3(-hx, base_y + height * 0.5, 0), WALL))
	hall.add_child(_box(Vector3(0.25, height * 0.72, depth - 0.6), Vector3(hx, base_y + height * 0.5, 0), WALL))

	# 门（朱漆，朝院心 / 本地 +Z）
	hall.add_child(_box(Vector3(width * 0.35, height * 0.55, 0.2), Vector3(0, base_y + height * 0.42, hz + 0.05), RED))

	# 屋顶（歇山简化为两层）
	var roof_y := base_y + height
	hall.add_child(_box(Vector3(width + 0.6, 0.35, depth + 0.5), Vector3(0, roof_y, 0), TILE))
	hall.add_child(_box(Vector3(width + 1.8, 0.28, depth + 1.6), Vector3(0, roof_y + 0.32, 0), TILE_DARK))
	hall.add_child(_box(Vector3(0.5, 0.45, depth + 1.8), Vector3(0, roof_y + 0.55, 0), TILE_DARK))

	# 匾额
	var plaque := _box(Vector3(width * 0.38, 0.28, 0.12), Vector3(0, roof_y - 0.15, hz + 0.18), RED)
	hall.add_child(plaque)
	hall.add_child(_sign_label(sign, Vector3(0, roof_y - 0.15, hz + 0.28)))

	# 檐下灯笼
	for lx: float in [-width * 0.32, width * 0.32]:
		hall.add_child(make_hanging_lantern(Vector3(lx, roof_y - 0.5, hz - 0.5)))

	add_blob_shadow(hall, width * 0.45)
	return hall

static func make_gate_pavilion(pos: Vector3) -> Node3D:
	var gate := Node3D.new()
	gate.name = "GatePavilion"
	gate.position = pos
	gate.rotation_degrees = Vector3(0, 180, 0)

	var platform_y := 0.12
	gate.add_child(_box(Vector3(10, 0.24, 4), Vector3(0, platform_y, 0), STONE))

	for side: float in [-1.0, 1.0]:
		var px: float = side * 3.6
		gate.add_child(_pillar(Vector3(px, 0, -0.8), 4.2))
		gate.add_child(_pillar(Vector3(px, 0, 0.8), 4.2))
		gate.add_child(_box(Vector3(1.0, 3.6, 2.0), Vector3(px, 2.2, 0), WALL))
		gate.add_child(_box(Vector3(1.3, 0.3, 2.3), Vector3(px, 4.1, 0), TILE_DARK))

	# 中门
	gate.add_child(_box(Vector3(2.8, 3.0, 0.25), Vector3(0, 1.9, 0), RED))
	gate.add_child(_box(Vector3(2.2, 0.18, 0.3), Vector3(0, 3.5, 0), WOOD_DARK))

	# 顶
	gate.add_child(_box(Vector3(9.5, 0.35, 3.2), Vector3(0, 4.35, 0), TILE))
	gate.add_child(_box(Vector3(11.0, 0.28, 4.0), Vector3(0, 4.65, 0), TILE_DARK))
	gate.add_child(_box(Vector3(0.6, 0.5, 4.2), Vector3(0, 4.9, 0), TILE_DARK))
	gate.add_child(_sign_label("府门", Vector3(0, 4.0, -1.6)))

	for lx: float in [-2.8, 2.8]:
		gate.add_child(make_hanging_lantern(Vector3(lx, 3.8, 1.2)))

	add_blob_shadow(gate, 4.5)
	return gate

## 优先用 Fab 精模（本地 `assets/fab/well/`）；没有则回退程序井。
static func spawn_well(pos: Vector3) -> Node3D:
	for path: String in [
		"res://assets/fab/well/low_poly_well.glb",
		"res://assets/fab/well/low_poly_well.gltf",
		"res://assets/fab/well/low_poly_well.fbx",
		"res://assets/fab/well/well.glb",
		"res://assets/fab/well/well.gltf",
		"res://assets/fab/well/well.fbx",
	]:
		if ResourceLoader.exists(path):
			var packed: PackedScene = load(path)
			var inst: Node3D = packed.instantiate()
			inst.name = "Well"
			var ground_y: float = _fit_prop_height(inst, 2.15)
			inst.position = Vector3(pos.x, pos.y + ground_y, pos.z)
			_disable_imported_collision(inst)
			add_blob_shadow(inst, 1.2)
			return inst
	return make_enhanced_well(pos)

static func _disable_imported_collision(n: Node) -> void:
	if n is CollisionObject3D:
		var co := n as CollisionObject3D
		co.collision_layer = 0
		co.collision_mask = 0
	for c in n.get_children():
		_disable_imported_collision(c)

static func make_enhanced_well(pos: Vector3) -> Node3D:
	var well := Node3D.new()
	well.name = "Well"
	well.position = pos

	well.add_child(_cylinder(1.1, 0.25, Vector3(0, 0.12, 0), STONE))
	well.add_child(_cylinder(0.75, 0.55, Vector3(0, 0.42, 0), Color(0.48, 0.42, 0.36)))
	well.add_child(_cylinder(0.82, 0.08, Vector3(0, 0.72, 0), WOOD_DARK))

	# 井亭四柱 + 顶
	for c in [Vector3(-0.9, 0, -0.9), Vector3(0.9, 0, -0.9), Vector3(-0.9, 0, 0.9), Vector3(0.9, 0, 0.9)]:
		well.add_child(_pillar(c + Vector3(0, 1.0, 0), 2.0))
	well.add_child(_box(Vector3(2.4, 0.18, 2.4), Vector3(0, 2.05, 0), TILE))
	well.add_child(_box(Vector3(2.8, 0.14, 2.8), Vector3(0, 2.22, 0), TILE_DARK))

	# 辘轳
	well.add_child(_box(Vector3(0.12, 0.12, 1.4), Vector3(0, 1.55, 0), WOOD))
	var axle := _cylinder(0.08, 1.35, Vector3(0, 1.55, 0), WOOD_DARK)
	axle.rotation_degrees = Vector3(90, 0, 0)
	well.add_child(axle)

	add_blob_shadow(well, 1.2)
	return well

static func enhance_plot(plot_root: Node3D) -> void:
	var soil: MeshInstance3D = plot_root.get_node("Soil")
	var crops: MeshInstance3D = plot_root.get_node("Crops")
	CourtyardVisuals.apply_toon(soil, Color(0.42, 0.32, 0.22))
	CourtyardVisuals.apply_toon(crops, Color(0.38, 0.62, 0.28), Color(0.24, 0.42, 0.18))

	# 木框围栏
	var half := 1.55
	for edge in [
		[Vector3(0, 0.22, -half), Vector3(3.2, 0.12, 0.12)],
		[Vector3(0, 0.22, half), Vector3(3.2, 0.12, 0.12)],
		[Vector3(-half, 0.22, 0), Vector3(0.12, 0.12, 3.2)],
		[Vector3(half, 0.22, 0), Vector3(0.12, 0.12, 3.2)],
	]:
		plot_root.add_child(_box(edge[1], edge[0], WOOD_DARK))

	# 角柱
	for c in [Vector3(-half, 0.35, -half), Vector3(half, 0.35, -half), Vector3(-half, 0.35, half), Vector3(half, 0.35, half)]:
		plot_root.add_child(_box(Vector3(0.14, 0.5, 0.14), c, WOOD))

	add_blob_shadow(plot_root, 1.6)

static func make_tree(pos: Vector3, height: float, leaf_color: Color) -> Node3D:
	var tree := Node3D.new()
	tree.name = "Tree"
	tree.position = pos
	tree.add_child(_cylinder(0.22, height * 0.45, Vector3(0, height * 0.22, 0), WOOD_DARK))
	var foliage := Node3D.new()
	foliage.position = Vector3(0, height * 0.55, 0)
	for i in 3:
		var s := 1.0 - i * 0.18
		var sphere := _sphere(height * 0.32 * s, Vector3(0, i * height * 0.12, 0), leaf_color, leaf_color.darkened(0.15))
		foliage.add_child(sphere)
	tree.add_child(foliage)
	CourtyardVisuals.enable_wind(foliage, 0.14)
	for c in foliage.get_children():
		if c is MeshInstance3D:
			(c as MeshInstance3D).add_to_group("season_foliage")
	add_blob_shadow(tree, 0.9)
	return tree

static func make_cherry_tree(pos: Vector3) -> Node3D:
	var tree := Node3D.new()
	tree.name = "CherryTree"
	tree.position = pos
	var h := 3.4
	tree.add_child(_cylinder(0.22, h * 0.45, Vector3(0, h * 0.22, 0), WOOD_DARK))
	var foliage := Node3D.new()
	foliage.position = Vector3(0, h * 0.55, 0)
	for i in 3:
		var s := 1.0 - i * 0.18
		foliage.add_child(_sphere(h * 0.32 * s, Vector3(0, i * h * 0.12, 0), BLOSSOM, BLOSSOM.darkened(0.2)))
	tree.add_child(foliage)
	CourtyardVisuals.enable_wind(foliage, 0.16)
	for c in foliage.get_children():
		if c is MeshInstance3D:
			(c as MeshInstance3D).add_to_group("season_blossom")
	for i in 6:
		tree.add_child(_sphere(0.06, Vector3(randf_range(-1.2, 1.2), 0.04, randf_range(-1.2, 1.2)), BLOSSOM, BLOSSOM))
	add_blob_shadow(tree, 0.9)
	return tree

static func make_bamboo_grove(pos: Vector3) -> Node3D:
	var grove := Node3D.new()
	grove.name = "BambooGrove"
	grove.position = pos
	for i in 8:
		var st := Node3D.new()
		st.position = Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
		var h := randf_range(2.5, 4.0)
		st.add_child(_cylinder(0.06, h, Vector3(0, h * 0.5, 0), Color(0.38, 0.58, 0.32)))
		st.add_child(_cylinder(0.04, h * 0.35, Vector3(0.08, h * 0.72, 0.05), Color(0.42, 0.62, 0.34)))
		grove.add_child(st)
	CourtyardVisuals.enable_wind(grove, 0.18)
	for st_n in grove.get_children():
		for c in st_n.get_children():
			if c is MeshInstance3D:
				(c as MeshInstance3D).add_to_group("season_foliage")
	add_blob_shadow(grove, 1.8)
	return grove

static func make_pond(pos: Vector3, radius: float) -> Node3D:
	var pond := Node3D.new()
	pond.name = "Pond"
	pond.position = pos
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(radius * 2, radius * 2)
	water.mesh = plane
	water.position = Vector3(0, 0.02, 0)
	water.material_override = CourtyardVisuals.make_water()
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pond.add_child(water)
	for i in 8:
		var ang := float(i) / 8.0 * TAU
		var rp := Vector3(cos(ang) * radius, 0.12, sin(ang) * radius)
		pond.add_child(_box(Vector3(0.55, 0.24, 0.4), rp, STONE))
	# 睡莲
	for i in 3:
		pond.add_child(_cylinder(0.18, 0.04, Vector3(randf_range(-1, 1), 0.05, randf_range(-1, 1)), Color(0.32, 0.68, 0.38)))
	add_blob_shadow(pond, radius * 0.8)
	return pond

static func make_stone_lantern(pos: Vector3) -> Node3D:
	var lan := Node3D.new()
	lan.position = pos
	lan.add_child(_box(Vector3(0.5, 0.2, 0.5), Vector3(0, 0.1, 0), STONE))
	lan.add_child(_box(Vector3(0.35, 0.5, 0.35), Vector3(0, 0.45, 0), STONE))
	var light_box := _box(Vector3(0.42, 0.35, 0.42), Vector3(0, 0.9, 0), Color(0.95, 0.88, 0.72))
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1.0, 0.82, 0.45)
	glow.emission_enabled = true
	glow.emission = Color(1.0, 0.7, 0.28)
	glow.emission_energy = 0.55
	light_box.material_override = glow
	light_box.add_to_group("lantern_glow")
	lan.add_child(light_box)
	lan.add_child(_box(Vector3(0.55, 0.15, 0.55), Vector3(0, 1.15, 0), STONE))
	add_blob_shadow(lan, 0.45)
	return lan

static func make_hanging_lantern(pos: Vector3) -> Node3D:
	var lan := Node3D.new()
	lan.position = pos
	var body := _sphere(0.22, Vector3.ZERO, Color(0.95, 0.35, 0.22))
	var em := StandardMaterial3D.new()
	em.albedo_color = Color(1.0, 0.55, 0.25)
	em.emission_enabled = true
	em.emission = Color(1.0, 0.5, 0.2)
	em.emission_energy = 1.2
	body.material_override = em
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_to_group("lantern_glow")
	lan.add_child(body)
	lan.add_child(_box(Vector3(0.04, 0.3, 0.04), Vector3(0, 0.28, 0), WOOD_DARK))
	return lan

static func make_barrel(pos: Vector3) -> Node3D:
	var b := Node3D.new()
	b.position = pos
	b.add_child(_cylinder(0.35, 0.7, Vector3(0, 0.35, 0), WOOD))
	b.add_child(_cylinder(0.36, 0.06, Vector3(0, 0.72, 0), WOOD_DARK))
	b.add_child(_cylinder(0.36, 0.06, Vector3(0, 0.02, 0), WOOD_DARK))
	add_blob_shadow(b, 0.4)
	return b

static func make_wood_pile(pos: Vector3) -> Node3D:
	var pile := Node3D.new()
	pile.position = pos
	for i in 5:
		var log := _cylinder(0.12, 1.2, Vector3(-0.4 + i * 0.2, 0.12, 0), WOOD)
		log.rotation_degrees = Vector3(0, randf_range(-15, 15), 90)
		pile.add_child(log)
	add_blob_shadow(pile, 0.7)
	return pile

static func make_water_bucket(pos: Vector3) -> Node3D:
	var b := Node3D.new()
	b.position = pos
	b.add_child(_cylinder(0.22, 0.35, Vector3(0, 0.18, 0), WOOD))
	add_blob_shadow(b, 0.25)
	return b

static func make_fence_row(from: Vector3, to: Vector3, segments: int) -> Node3D:
	var row := Node3D.new()
	var dir := to - from
	var length := dir.length()
	for i: int in range(segments + 1):
		var t := float(i) / float(segments)
		var p := from.lerp(to, t)
		row.add_child(_box(Vector3(0.12, 0.55, 0.12), p + Vector3(0, 0.28, 0), WOOD_DARK))
	if length > 0.2:
		var mid := from.lerp(to, 0.5)
		var along_x := absf(dir.x) >= absf(dir.z)
		var rail := Vector3(length, 0.06, 0.06) if along_x else Vector3(0.06, 0.06, length)
		row.add_child(_box(rail, mid + Vector3(0, 0.38, 0), WOOD))
		row.add_child(_box(rail, mid + Vector3(0, 0.22, 0), WOOD))
	return row

static func make_moon_gate(pos: Vector3) -> Node3D:
	var gate := Node3D.new()
	gate.name = "MoonGate"
	gate.position = pos
	for side: float in [-1.0, 1.0]:
		var px: float = side * 3.4
		gate.add_child(_box(Vector3(2.2, 2.4, 0.4), Vector3(px, 1.2, 0), WALL))
		gate.add_child(_box(Vector3(2.4, 0.22, 0.7), Vector3(px, 2.45, 0), TILE_DARK))
	gate.add_child(_box(Vector3(1.2, 0.28, 0.45), Vector3(0, 2.55, 0), TILE))
	gate.add_child(_box(Vector3(0.18, 2.2, 0.18), Vector3(-2.2, 1.1, 0), WOOD_DARK))
	gate.add_child(_box(Vector3(0.18, 2.2, 0.18), Vector3(2.2, 1.1, 0), WOOD_DARK))
	add_blob_shadow(gate, 2.4)
	return gate

static func make_screen_walls() -> Node3D:
	var group := Node3D.new()
	group.name = "ScreenWalls"
	# 内院矮隔墙：只做四角段落，不挡等距视线
	_add_screen_seg(group, Vector3(-20, 0.7, -18), Vector3(8.0, 1.4, 0.35))
	_add_screen_seg(group, Vector3(20, 0.7, -18), Vector3(8.0, 1.4, 0.35))
	_add_screen_seg(group, Vector3(-20, 0.7, 18), Vector3(8.0, 1.4, 0.35))
	_add_screen_seg(group, Vector3(20, 0.7, 16), Vector3(6.0, 1.4, 0.35))
	_add_screen_seg(group, Vector3(-22, 0.7, 0), Vector3(0.35, 1.4, 10.0))
	_add_screen_seg(group, Vector3(22, 0.7, -8), Vector3(0.35, 1.4, 8.0))
	return group

static func _add_screen_seg(group: Node3D, pos: Vector3, size: Vector3) -> void:
	group.add_child(_box(size, pos, WALL))
	group.add_child(_box(Vector3(size.x + 0.3, 0.18, size.z + 0.3), pos + Vector3(0, size.y * 0.5 + 0.12, 0), TILE_DARK))

static func make_produce_stall(pos: Vector3) -> Node3D:
	var stall := Node3D.new()
	stall.name = "ProduceStall"
	stall.position = pos
	stall.add_child(_box(Vector3(4.2, 0.18, 3.2), Vector3(0, 0.09, 0), WOOD))
	stall.add_child(_box(Vector3(3.6, 0.7, 1.1), Vector3(0, 0.55, 0.4), WOOD_DARK))
	stall.add_child(_box(Vector3(4.4, 0.08, 2.4), Vector3(0, 2.05, -0.2), Color(0.22, 0.52, 0.28)))
	stall.add_child(_box(Vector3(0.12, 2.0, 0.12), Vector3(-1.9, 1.1, -0.9), WOOD_DARK))
	stall.add_child(_box(Vector3(0.12, 2.0, 0.12), Vector3(1.9, 1.1, -0.9), WOOD_DARK))
	stall.add_child(_box(Vector3(0.12, 2.0, 0.12), Vector3(-1.9, 1.1, 0.9), WOOD_DARK))
	stall.add_child(_box(Vector3(0.12, 2.0, 0.12), Vector3(1.9, 1.1, 0.9), WOOD_DARK))
	stall.add_child(_sphere(0.16, Vector3(-0.9, 1.02, 0.35), Color(0.28, 0.62, 0.28), Color(0.18, 0.42, 0.18)))
	stall.add_child(_sphere(0.16, Vector3(-0.2, 1.02, 0.4), Color(0.92, 0.52, 0.18), Color(0.70, 0.32, 0.10)))
	stall.add_child(_sphere(0.16, Vector3(0.5, 1.02, 0.32), Color(0.78, 0.78, 0.72), Color(0.58, 0.56, 0.50)))
	stall.add_child(_sphere(0.16, Vector3(1.1, 1.02, 0.38), Color(0.86, 0.22, 0.18), Color(0.62, 0.14, 0.12)))
	stall.add_child(_sign_label("蔬果铺", Vector3(0, 2.28, 0.2)))
	add_blob_shadow(stall, 2.0)
	return stall

static func make_animal_pen(pos: Vector3) -> Node3D:
	var pen := Node3D.new()
	pen.name = "AnimalPen"
	pen.position = pos
	pen.add_child(make_fence_row(Vector3(-3.2, 0, -2.6), Vector3(3.2, 0, -2.6), 5))
	pen.add_child(make_fence_row(Vector3(-3.2, 0, 2.6), Vector3(3.2, 0, 2.6), 5))
	pen.add_child(make_fence_row(Vector3(-3.2, 0, -2.6), Vector3(-3.2, 0, 2.6), 4))
	pen.add_child(make_fence_row(Vector3(3.2, 0, -2.6), Vector3(3.2, 0, 1.0), 3))
	# 黄牛
	var cow := Node3D.new()
	cow.name = "Cow"
	cow.position = Vector3(-0.4, 0, 0.15)
	cow.scale = Vector3(0.88, 0.88, 0.88)
	cow.add_child(_box(Vector3(1.5, 0.7, 0.7), Vector3(0, 0.55, 0), Color(0.55, 0.38, 0.22)))
	cow.add_child(_box(Vector3(0.45, 0.4, 0.42), Vector3(0.85, 0.85, 0), Color(0.50, 0.34, 0.20)))
	cow.add_child(_cylinder(0.08, 0.45, Vector3(-0.45, 0.22, 0.22), Color(0.42, 0.30, 0.18)))
	cow.add_child(_cylinder(0.08, 0.45, Vector3(-0.45, 0.22, -0.22), Color(0.42, 0.30, 0.18)))
	cow.add_child(_cylinder(0.08, 0.45, Vector3(0.45, 0.22, 0.22), Color(0.42, 0.30, 0.18)))
	cow.add_child(_cylinder(0.08, 0.45, Vector3(0.45, 0.22, -0.22), Color(0.42, 0.30, 0.18)))
	var cow_idle := IdlePresence.new()
	cow_idle.look_range = 0.0
	cow_idle.amplitude = 0.018
	cow.add_child(cow_idle)
	pen.add_child(cow)
	for i: int in range(2):
		var hen := WanderCritter.new()
		hen.name = "Hen"
		hen.position = Vector3(1.2 + float(i) * 0.7, 0, -0.8 + float(i) * 0.5)
		hen.add_child(_sphere(0.16, Vector3(0, 0.18, 0), Color(0.92, 0.88, 0.78)))
		hen.add_child(_sphere(0.08, Vector3(0.12, 0.28, 0), Color(0.90, 0.82, 0.70)))
		pen.add_child(hen)
	pen.add_child(_box(Vector3(1.2, 0.28, 0.4), Vector3(0.4, 0.2, 1.6), WOOD))
	add_blob_shadow(pen, 2.4)
	return pen

static func make_pier(pos: Vector3) -> Node3D:
	var pier := Node3D.new()
	pier.name = "Pier"
	pier.position = pos
	pier.add_child(_box(Vector3(1.4, 0.12, 3.6), Vector3(0, 0.18, 0), WOOD))
	pier.add_child(_box(Vector3(0.14, 0.7, 0.14), Vector3(-0.55, 0.2, -1.4), WOOD_DARK))
	pier.add_child(_box(Vector3(0.14, 0.7, 0.14), Vector3(0.55, 0.2, -1.4), WOOD_DARK))
	pier.add_child(_box(Vector3(0.14, 0.7, 0.14), Vector3(-0.55, 0.2, 1.4), WOOD_DARK))
	pier.add_child(_box(Vector3(0.14, 0.7, 0.14), Vector3(0.55, 0.2, 1.4), WOOD_DARK))
	add_blob_shadow(pier, 1.1)
	return pier

static func make_stove(pos: Vector3) -> Node3D:
	var stove := Node3D.new()
	stove.name = "Stove"
	stove.position = pos
	stove.add_child(_box(Vector3(1.4, 0.7, 1.1), Vector3(0, 0.35, 0), Color(0.42, 0.38, 0.34)))
	stove.add_child(_cylinder(0.16, 1.1, Vector3(0.35, 1.05, 0), Color(0.50, 0.46, 0.42)))
	stove.add_child(_box(Vector3(0.7, 0.12, 0.7), Vector3(0, 0.76, 0), Color(0.22, 0.20, 0.18)))
	add_blob_shadow(stove, 0.7)
	return stove

static func make_bench(pos: Vector3, yaw_deg: float) -> Node3D:
	var bench := Node3D.new()
	bench.name = "Bench"
	bench.position = pos
	bench.rotation_degrees = Vector3(0, yaw_deg, 0)
	bench.add_child(_box(Vector3(1.4, 0.1, 0.4), Vector3(0, 0.38, 0), WOOD))
	bench.add_child(_box(Vector3(1.4, 0.35, 0.08), Vector3(0, 0.58, -0.16), WOOD_DARK))
	bench.add_child(_box(Vector3(0.1, 0.36, 0.36), Vector3(-0.6, 0.18, 0), WOOD_DARK))
	bench.add_child(_box(Vector3(0.1, 0.36, 0.36), Vector3(0.6, 0.18, 0), WOOD_DARK))
	add_blob_shadow(bench, 0.7)
	return bench

static func make_shrub(pos: Vector3) -> Node3D:
	var shrub := Node3D.new()
	shrub.name = "Shrub"
	shrub.position = pos
	shrub.add_child(_sphere(0.42, Vector3(0, 0.38, 0), FOLIAGE, FOLIAGE_DARK))
	shrub.add_child(_sphere(0.28, Vector3(0.28, 0.32, 0.1), FOLIAGE_DARK, FOLIAGE))
	CourtyardVisuals.enable_wind(shrub, 0.10)
	for c in shrub.get_children():
		if c is MeshInstance3D and c.name != "BlobShadow":
			(c as MeshInstance3D).add_to_group("season_foliage")
	add_blob_shadow(shrub, 0.45)
	return shrub

static func make_rock(pos: Vector3, size: float) -> Node3D:
	var rock := Node3D.new()
	rock.position = pos
	rock.add_child(_sphere(size * 0.35, Vector3(0, size * 0.2, 0), STONE, STONE.darkened(0.15)))
	add_blob_shadow(rock, size * 0.35)
	return rock

static func make_corner_tower(pos: Vector3) -> Node3D:
	var tower := Node3D.new()
	tower.position = pos
	tower.add_child(_box(Vector3(2.4, 3.2, 2.4), Vector3(0, 1.6, 0), WALL))
	tower.add_child(_box(Vector3(2.8, 0.35, 2.8), Vector3(0, 3.35, 0), TILE))
	tower.add_child(_box(Vector3(3.2, 0.25, 3.2), Vector3(0, 3.6, 0), TILE_DARK))
	add_blob_shadow(tower, 1.4)
	return tower

static func setup_character(node: Node3D, yaw_deg: float = 0.0, scale: float = CourtyardLayout.CHAR_SCALE) -> void:
	node.scale = Vector3.ONE * scale
	node.rotation_degrees.y = yaw_deg
	CourtyardVisuals.apply_toon_recursive(node)
	add_blob_shadow(node, 0.40 * scale)
	node.add_child(IdlePresence.new())

static func make_servant(pos: Vector3, robe: Color, yaw_deg: float = 0.0) -> Node3D:
	var n := Node3D.new()
	n.name = "Servant"
	n.position = pos
	n.rotation_degrees.y = yaw_deg
	n.scale = Vector3(CourtyardLayout.CHAR_SCALE * 0.96, CourtyardLayout.CHAR_SCALE * 0.96, CourtyardLayout.CHAR_SCALE * 0.96)
	n.add_child(_cylinder(0.22, 1.05, Vector3(0, 0.62, 0), robe))
	n.add_child(_sphere(0.18, Vector3(0, 1.28, 0), Color(0.86, 0.74, 0.62), Color(0.62, 0.48, 0.38)))
	n.add_child(_box(Vector3(0.42, 0.08, 0.42), Vector3(0, 1.42, 0), robe.darkened(0.18)))
	add_blob_shadow(n, 0.38)
	n.add_child(IdlePresence.new())
	return n

## 天启御驾亲访占位（龙袍简模；精模到位后同名替换）。
static func make_emperor_visit(pos: Vector3, yaw_deg: float = -15.0) -> Node3D:
	var n := Node3D.new()
	n.name = "EmperorVisit"
	n.position = pos
	n.rotation_degrees.y = yaw_deg
	var scale := CourtyardLayout.CHAR_SCALE * 1.08
	n.scale = Vector3(scale, scale, scale)
	var robe := Color(0.88, 0.72, 0.22)
	var robe_dark := Color(0.62, 0.18, 0.14)
	n.add_child(_cylinder(0.24, 1.08, Vector3(0, 0.64, 0), robe))
	n.add_child(_sphere(0.19, Vector3(0, 1.32, 0), Color(0.88, 0.76, 0.64), Color(0.62, 0.48, 0.38)))
	n.add_child(_box(Vector3(0.48, 0.1, 0.48), Vector3(0, 1.46, 0), robe_dark))
	var presence := IdlePresence.new()
	presence.look_range = 14.0
	n.add_child(presence)
	add_blob_shadow(n, 0.44)
	return n

static func make_step_stones(from: Vector3, to: Vector3, count: int) -> Node3D:
	var g := Node3D.new()
	g.name = "StepStones"
	for i: int in range(count):
		var t := (float(i) + 1.0) / (float(count) + 1.0)
		var p := from.lerp(to, t)
		p.x += sin(float(i) * 1.7) * 0.18
		g.add_child(_cylinder(0.36, 0.07, p + Vector3(0, 0.04, 0), STONE))
	return g

static func make_clothesline(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.name = "Clothesline"
	g.position = pos
	g.add_child(_box(Vector3(0.1, 1.7, 0.1), Vector3(-1.6, 0.85, 0), WOOD_DARK))
	g.add_child(_box(Vector3(0.1, 1.7, 0.1), Vector3(1.6, 0.85, 0), WOOD_DARK))
	g.add_child(_box(Vector3(3.3, 0.03, 0.03), Vector3(0, 1.62, 0), Color(0.72, 0.68, 0.60)))
	g.add_child(_box(Vector3(0.55, 0.7, 0.04), Vector3(-0.8, 1.22, 0), Color(0.82, 0.78, 0.70)))
	g.add_child(_box(Vector3(0.48, 0.62, 0.04), Vector3(0.15, 1.26, 0), Color(0.62, 0.22, 0.18)))
	g.add_child(_box(Vector3(0.42, 0.55, 0.04), Vector3(0.95, 1.28, 0), Color(0.38, 0.48, 0.42)))
	add_blob_shadow(g, 1.4)
	return g

static func make_drying_rack(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_box(Vector3(1.6, 0.08, 0.08), Vector3(0, 0.85, 0), WOOD))
	g.add_child(_box(Vector3(0.08, 0.9, 0.08), Vector3(-0.7, 0.45, 0), WOOD_DARK))
	g.add_child(_box(Vector3(0.08, 0.9, 0.08), Vector3(0.7, 0.45, 0), WOOD_DARK))
	g.add_child(_box(Vector3(0.35, 0.5, 0.03), Vector3(-0.35, 0.55, 0), Color(0.78, 0.74, 0.66)))
	g.add_child(_box(Vector3(0.32, 0.45, 0.03), Vector3(0.28, 0.58, 0), Color(0.70, 0.62, 0.48)))
	add_blob_shadow(g, 0.7)
	return g

static func make_cart(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.name = "Cart"
	g.position = pos
	g.rotation_degrees = Vector3(0, 35, 0)
	g.add_child(_box(Vector3(1.6, 0.18, 0.95), Vector3(0, 0.55, 0), WOOD))
	g.add_child(_box(Vector3(1.55, 0.35, 0.08), Vector3(0, 0.72, -0.44), WOOD_DARK))
	g.add_child(_box(Vector3(1.55, 0.35, 0.08), Vector3(0, 0.72, 0.44), WOOD_DARK))
	g.add_child(_box(Vector3(0.08, 0.35, 0.9), Vector3(-0.76, 0.72, 0), WOOD_DARK))
	var w1 := _cylinder(0.28, 0.12, Vector3(-0.55, 0.28, 0.52), WOOD_DARK)
	w1.rotation_degrees = Vector3(90, 0, 0)
	g.add_child(w1)
	var w2 := _cylinder(0.28, 0.12, Vector3(-0.55, 0.28, -0.52), WOOD_DARK)
	w2.rotation_degrees = Vector3(90, 0, 0)
	g.add_child(w2)
	g.add_child(_box(Vector3(0.08, 0.08, 1.1), Vector3(0.85, 0.55, 0), WOOD))
	add_blob_shadow(g, 0.9)
	return g

static func make_crate_stack(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_box(Vector3(0.7, 0.5, 0.55), Vector3(0, 0.25, 0), WOOD))
	g.add_child(_box(Vector3(0.55, 0.42, 0.48), Vector3(0.12, 0.71, 0.05), WOOD_DARK))
	add_blob_shadow(g, 0.45)
	return g

static func make_sack(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_sphere(0.28, Vector3(0, 0.22, 0), Color(0.62, 0.52, 0.36), Color(0.46, 0.38, 0.26)))
	add_blob_shadow(g, 0.3)
	return g

static func make_scarecrow(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.name = "Scarecrow"
	g.position = pos
	g.add_child(_box(Vector3(0.1, 1.7, 0.1), Vector3(0, 0.85, 0), WOOD_DARK))
	g.add_child(_box(Vector3(1.15, 0.08, 0.08), Vector3(0, 1.35, 0), WOOD))
	g.add_child(_sphere(0.2, Vector3(0, 1.72, 0), Color(0.78, 0.62, 0.38), Color(0.55, 0.42, 0.24)))
	g.add_child(_box(Vector3(0.55, 0.55, 0.12), Vector3(0, 1.15, 0), Color(0.55, 0.22, 0.16)))
	add_blob_shadow(g, 0.4)
	return g

static func make_flower_bed(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_box(Vector3(1.8, 0.18, 0.7), Vector3(0, 0.1, 0), WOOD_DARK))
	g.add_child(_sphere(0.22, Vector3(-0.5, 0.32, 0), BLOSSOM, BLOSSOM.darkened(0.2)))
	g.add_child(_sphere(0.18, Vector3(0.05, 0.3, 0.08), FOLIAGE, FOLIAGE_DARK))
	g.add_child(_sphere(0.2, Vector3(0.5, 0.32, -0.06), Color(0.88, 0.42, 0.28), Color(0.62, 0.22, 0.16)))
	CourtyardVisuals.enable_wind(g, 0.08)
	add_blob_shadow(g, 0.7)
	return g

static func make_trough(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_box(Vector3(1.6, 0.28, 0.45), Vector3(0, 0.22, 0), WOOD))
	g.add_child(_box(Vector3(1.45, 0.08, 0.32), Vector3(0, 0.28, 0), Color(0.42, 0.58, 0.62)))
	add_blob_shadow(g, 0.7)
	return g

static func make_millstone(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_cylinder(0.55, 0.18, Vector3(0, 0.1, 0), STONE))
	g.add_child(_cylinder(0.48, 0.14, Vector3(0, 0.24, 0), STONE.darkened(0.08)))
	g.add_child(_box(Vector3(0.08, 0.35, 0.08), Vector3(0.2, 0.42, 0), WOOD_DARK))
	add_blob_shadow(g, 0.55)
	return g

static func make_wash_basin(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.add_child(_cylinder(0.38, 0.22, Vector3(0, 0.18, 0), STONE))
	g.add_child(_cylinder(0.28, 0.06, Vector3(0, 0.26, 0), Color(0.40, 0.58, 0.64)))
	add_blob_shadow(g, 0.35)
	return g

static func make_interact_ring(radius: float = 1.25) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	ring.name = "InteractRing"
	var torus := TorusMesh.new()
	torus.inner_radius = radius * 0.88
	torus.outer_radius = radius
	torus.rings = 10
	torus.ring_segments = 8
	ring.mesh = torus
	ring.rotation_degrees = Vector3(90, 0, 0)
	ring.position.y = 0.06
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.95, 0.82, 0.42, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = mat
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visible = false
	return ring

## 缩放到目标高度；返回贴地所需的 y 偏移（最低点落到 y=0）。
static func _fit_prop_height(root: Node3D, target_height: float) -> float:
	var acc: Array = [AABB(), false]
	_aabb_walk(root, Transform3D.IDENTITY, acc)
	if not acc[1]:
		return 0.0
	var aabb: AABB = acc[0]
	if aabb.size.y < 0.05:
		return 0.0
	var s: float = target_height / aabb.size.y
	root.scale = Vector3(s, s, s)
	return -aabb.position.y * s

static func _aabb_walk(n: Node, parent_xf: Transform3D, acc: Array) -> void:
	var xf := parent_xf
	if n is Node3D:
		xf = parent_xf * (n as Node3D).transform
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh:
			var piece: AABB = xf * mi.get_aabb()
			if not acc[1]:
				acc[0] = piece
				acc[1] = true
			else:
				var merged: AABB = acc[0]
				acc[0] = merged.merge(piece)
	for c in n.get_children():
		_aabb_walk(c, xf, acc)

static func add_blob_shadow(parent: Node3D, radius: float) -> void:
	var shadow := MeshInstance3D.new()
	shadow.name = "BlobShadow"
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.02
	shadow.mesh = disc
	shadow.position = Vector3(0, 0.03, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0, 0, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow.material_override = mat
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shadow)

# ── 内部拼装 ──

static func _box(size: Vector3, pos: Vector3, albedo: Color, shadow: Color = Color(0.38, 0.32, 0.26)) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	m.mesh = b
	m.position = pos
	CourtyardVisuals.apply_toon(m, albedo, shadow)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return m

static func _cylinder(radius: float, height: float, pos: Vector3, albedo: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius
	c.height = height
	m.mesh = c
	m.position = pos
	CourtyardVisuals.apply_toon(m, albedo)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return m

static func _sphere(radius: float, pos: Vector3, albedo: Color, shadow: Color = Color(0.38, 0.32, 0.26)) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = radius
	s.height = radius * 2
	m.mesh = s
	m.position = pos
	CourtyardVisuals.apply_toon(m, albedo, shadow)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return m

static func _pillar(pos: Vector3, height: float) -> MeshInstance3D:
	return _cylinder(0.18, height, pos, WOOD)

static func _sign_label(text: String, pos: Vector3) -> Label3D:
	var lbl := Label3D.new()
	lbl.text = text
	lbl.font_size = 48
	lbl.modulate = Color(0.95, 0.82, 0.45)
	lbl.position = pos
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.outline_size = 8
	lbl.outline_modulate = Color(0.2, 0.12, 0.08)
	return lbl
