extends RefCounted
class_name StyleC
## 风格 C：清爽赛璐璐色板、描边与木框 UI。

const OUTLINE := Color(0.18, 0.14, 0.12, 1)
const PAPER := Color(0.96, 0.93, 0.86, 1)
const GRASS_A := Color(0.42, 0.72, 0.38, 1)
const GRASS_B := Color(0.52, 0.8, 0.45, 1)
const DIRT := Color(0.72, 0.55, 0.38, 1)
const DIRT_LIGHT := Color(0.82, 0.64, 0.45, 1)
const LEAF := Color(0.32, 0.68, 0.35, 1)
const LEAF_DARK := Color(0.22, 0.52, 0.28, 1)
const UI_PANEL := Color(0.98, 0.95, 0.88, 0.96)
const UI_EDGE := Color(0.32, 0.22, 0.14, 1)
const UI_WOOD := Color(0.72, 0.52, 0.34, 1)
const UI_INK := Color(0.22, 0.16, 0.12, 1)
const UI_ZHU := Color(0.62, 0.18, 0.14, 1)
const UI_PAPER_INNER := Color(0.99, 0.97, 0.92, 1)

static func draw_outlined_circle(canvas: CanvasItem, center: Vector2, radius: float, fill: Color, outline_w: float = 2.0) -> void:
	canvas.draw_circle(center, radius + outline_w * 0.5, OUTLINE)
	canvas.draw_circle(center, radius, fill)

static func draw_outlined_ellipse(canvas: CanvasItem, center: Vector2, radii: Vector2, fill: Color, outline_w: float = 2.0) -> void:
	_ellipse(canvas, center, radii + Vector2(outline_w, outline_w), OUTLINE)
	_ellipse(canvas, center, radii, fill)

static func _ellipse(canvas: CanvasItem, center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 36:
		var a := TAU * float(i) / 36.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	canvas.draw_colored_polygon(pts, color)

## —— UI 木框 ——
static func wood_panel(fill: Color = UI_PANEL, border: Color = UI_EDGE, radius: int = 6, border_w: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 14
	s.content_margin_top = 10
	s.content_margin_right = 14
	s.content_margin_bottom = 12
	s.shadow_color = Color(0, 0, 0, 0.18)
	s.shadow_size = 5
	s.shadow_offset = Vector2(2, 3)
	return s

## 细木条（目标 / 时钟 / 旁注）
static func slim_panel() -> StyleBoxFlat:
	var s := wood_panel(Color(0.98, 0.95, 0.88, 0.92), UI_EDGE, 5, 2)
	s.content_margin_left = 12
	s.content_margin_top = 6
	s.content_margin_right = 12
	s.content_margin_bottom = 6
	s.shadow_size = 3
	return s

## 对白大框：外深木 + 内纸色感
static func dialogue_panel() -> StyleBoxFlat:
	var s := wood_panel(UI_PAPER_INNER, Color(0.42, 0.28, 0.16, 1), 8, 4)
	s.content_margin_left = 16
	s.content_margin_top = 12
	s.content_margin_right = 16
	s.content_margin_bottom = 14
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 4)
	return s

## 立绘小槽外框
static func portrait_frame() -> StyleBoxFlat:
	var s := wood_panel(Color(0.9, 0.84, 0.72, 1), Color(0.42, 0.28, 0.16, 1), 4, 3)
	s.content_margin_left = 4
	s.content_margin_top = 4
	s.content_margin_right = 4
	s.content_margin_bottom = 4
	s.shadow_size = 2
	return s

static func toast_panel() -> StyleBoxFlat:
	var s := wood_panel(Color(0.98, 0.94, 0.82, 0.96), UI_WOOD, 8, 2)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

static func tip_panel() -> StyleBoxFlat:
	var s := wood_panel(Color(0.96, 0.92, 0.84, 0.88), UI_EDGE, 4, 2)
	s.content_margin_left = 10
	s.content_margin_top = 4
	s.content_margin_right = 10
	s.content_margin_bottom = 4
	s.shadow_size = 2
	return s

static func button_normal() -> StyleBoxFlat:
	var s := wood_panel(Color(0.94, 0.88, 0.76, 1), UI_EDGE, 5, 2)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.shadow_size = 2
	return s

static func button_hover() -> StyleBoxFlat:
	var s := button_normal()
	s.bg_color = Color(0.98, 0.92, 0.8, 1)
	s.border_color = UI_ZHU
	return s

static func button_pressed() -> StyleBoxFlat:
	var s := button_normal()
	s.bg_color = Color(0.88, 0.8, 0.68, 1)
	s.shadow_size = 0
	return s

static func apply_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", button_normal())
	btn.add_theme_stylebox_override("hover", button_hover())
	btn.add_theme_stylebox_override("pressed", button_pressed())
	btn.add_theme_stylebox_override("focus", button_hover())
	btn.add_theme_color_override("font_color", UI_INK)
	btn.add_theme_color_override("font_hover_color", UI_ZHU)
	btn.add_theme_font_size_override("font_size", 15)

## 把 Label 包进木框 Panel（返回 Panel）
static func wrap_in_panel(parent: Control, label: Control, style: StyleBoxFlat, pos: Vector2, size: Vector2, panel_name: String) -> PanelContainer:
	var existing := parent.get_node_or_null(panel_name) as PanelContainer
	if existing:
		return existing
	var p := PanelContainer.new()
	p.name = panel_name
	parent.add_child(p)
	p.add_theme_stylebox_override("panel", style)
	p.position = pos
	p.size = size
	var lp := label.get_parent()
	if lp:
		lp.remove_child(label)
	p.add_child(label)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 8
	label.offset_top = 4
	label.offset_right = -8
	label.offset_bottom = -4
	return p
