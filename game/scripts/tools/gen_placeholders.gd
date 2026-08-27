extends SceneTree
# 《末命》占位模型生成器（程序化 blockout）
# 运行：godot --headless --path <项目根> --script res://scripts/tools/gen_placeholders.gd
# 按 docs/18_人物建模规范.md 的 id 与配色生成 PrimitiveMesh 占位 .tscn，命名规范、后续可换精模不改代码。

func _initialize():
	print("=== 占位模型生成器启动 ===")
	gen_characters()
	gen_props()
	gen_buildings()
	print("=== 生成完成，退出 ===")
	quit()

# ---- 工具 ----
func hex(h):
	h = h.replace("#", "")
	var r = h.substr(0, 2).hex_to_int() / 255.0
	var g = h.substr(2, 2).hex_to_int() / 255.0
	var b = h.substr(4, 2).hex_to_int() / 255.0
	return Color(r, g, b)

func mat(color):
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.95
	m.metallic = 0.0
	return m

func add_box(parent, sx, sy, sz, color, px, py, pz):
	var mi = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = Vector3(sx, sy, sz)
	mi.mesh = b
	mi.material_override = mat(color)
	mi.position = Vector3(px, py, pz)
	parent.add_child(mi)
	return mi

func add_cyl(parent, h, r, color, px, py, pz):
	var mi = MeshInstance3D.new()
	var c = CylinderMesh.new()
	c.height = h
	c.top_radius = r
	c.bottom_radius = r
	mi.mesh = c
	mi.material_override = mat(color)
	mi.position = Vector3(px, py, pz)
	parent.add_child(mi)
	return mi

func add_sphere(parent, r, color, px, py, pz):
	var mi = MeshInstance3D.new()
	var s = SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	mi.mesh = s
	mi.material_override = mat(color)
	mi.position = Vector3(px, py, pz)
	parent.add_child(mi)
	return mi

func _set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.owner = root
		_set_owner_recursive(child, root)

func save_scene(root, path):
	_set_owner_recursive(root, root)
	var packed = PackedScene.new()
	packed.pack(root)
	var err = ResourceSaver.save(packed, path)
	if err != OK:
		printerr("保存失败: ", path, " err=", err)
	else:
		print("  OK ", path)
	root.queue_free()

# ---- 人物：身体(圆柱)+头(球)+可选拐杖 ----
func humanoid(path, body_hex, head_hex, height, radius, with_staff):
	var root = Node3D.new()
	add_cyl(root, height * 0.65, radius, hex(body_hex), 0, height * 0.325, 0)
	add_sphere(root, radius * 0.62, hex(head_hex), 0, height * 0.65 + radius * 0.62, 0)
	if with_staff:
		add_cyl(root, height * 0.95, 0.025, hex("#5A4A38"), radius * 0.55, height * 0.475, 0)
	save_scene(root, path)

func gen_characters():
	print("-- 人物 --")
	# 信王 M1：黛青常服 #3B4654 / 暖肤 #E8C9A0（人物建模规范.md §1.1）
	humanoid("res://assets/models/characters/xinwang_m1.tscn", "#3B4654", "#E8C9A0", 1.8, 0.3, false)
	# 王承恩(阿恩)：褐衣 #6E4A2E / 暖肤 #E2C49C（§2）
	humanoid("res://assets/models/characters/aen.tscn", "#6E4A2E", "#E2C49C", 1.6, 0.28, false)
	# 吴伯(老仆)：灰褐 #5A5048 / 暗暖肤 #D8B98F，带拐杖
	humanoid("res://assets/models/characters/wubo.tscn", "#5A5048", "#D8B98F", 1.65, 0.3, true)
	# 秋穗(外乡旧识)：土黄常服 #7A6A4A / 暖肤 #E0C0A0
	humanoid("res://assets/models/characters/qiushui.tscn", "#7A6A4A", "#E0C0A0", 1.7, 0.3, false)

# ---- 道具 ----
func gen_props():
	print("-- 道具 --")
	for i in range(1, 7):
		var root = Node3D.new()
		# 命名 Soil / Crops，匹配 CourtPlot.gd 状态机引用
		var soil = MeshInstance3D.new()
		soil.name = "Soil"
		var sb = BoxMesh.new()
		sb.size = Vector3(3, 0.3, 3)
		soil.mesh = sb
		soil.material_override = mat(hex("#5A4632"))
		soil.position = Vector3(0, 0.15, 0)
		root.add_child(soil)
		var crops = MeshInstance3D.new()
		crops.name = "Crops"
		var cb = BoxMesh.new()
		cb.size = Vector3(2.8, 0.45, 2.8)
		crops.mesh = cb
		crops.material_override = mat(hex("#4A6B3A"))
		crops.position = Vector3(0, 0.5, 0)
		root.add_child(crops)
		save_scene(root, "res://assets/models/props/plot_%02d.tscn" % i)
	var well = Node3D.new()
	add_cyl(well, 0.8, 0.6, hex("#5A4A38"), 0, 0.4, 0)                  # 井圈
	add_cyl(well, 0.1, 0.5, hex("#2A2018"), 0, 0.82, 0)                 # 井口暗
	add_box(well, 1.6, 0.1, 0.2, hex("#6E4A2E"), 0, 1.0, 0)            # 顶盖横梁
	save_scene(well, "res://assets/models/props/well.tscn")

# ---- 建筑 ----
func gen_buildings():
	print("-- 建筑 --")
	var gate = Node3D.new()
	add_box(gate, 0.4, 3.0, 0.4, hex("#4A3A2A"), -1.2, 1.5, 0)          # 左立柱
	add_box(gate, 0.4, 3.0, 0.4, hex("#4A3A2A"), 1.2, 1.5, 0)           # 右立柱
	add_box(gate, 3.2, 0.5, 0.5, hex("#3A2A1A"), 0, 3.2, 0)             # 横梁
	add_box(gate, 2.4, 0.3, 0.3, hex("#9E2E24"), 0, 2.9, 0)            # 门楣硃红点
	save_scene(gate, "res://assets/models/buildings/mansion_gate.tscn")
