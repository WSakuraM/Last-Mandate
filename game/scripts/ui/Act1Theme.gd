class_name Act1Theme
extends RefCounted
# 第一幕 UI 共享主题：暖纸底 + 细木描边 + 低饱和墨色（对齐 archive/ui/ui_0.0.3）

const PAPER := Color(0.94, 0.88, 0.76)
const PAPER_DIM := Color(0.88, 0.80, 0.66)
const INK := Color(0.22, 0.16, 0.12)
const INK_MUTED := Color(0.42, 0.34, 0.26)
const INK_FAINT := Color(0.58, 0.50, 0.40)
const WOOD := Color(0.36, 0.24, 0.14)
const BRONZE := Color(0.62, 0.48, 0.28)
const GOLD := Color(0.82, 0.66, 0.36)
const VERMILLION := Color(0.72, 0.22, 0.14)
const VERMILLION_SOFT := Color(0.85, 0.38, 0.28)
const SHADOW := Color(0.08, 0.05, 0.03, 0.35)
const NIGHT_DIM := Color(0.06, 0.04, 0.03, 0.48)

const FONT_TITLE := 20
const FONT_BODY := 19
const FONT_SMALL := 14
const FONT_TINY := 12
const FONT_HINT := 17
const FONT_HUD_LABEL := 14
const FONT_HUD_VALUE := 15

static func paper_panel(alpha: float = 0.94, radius: int = 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(PAPER.r, PAPER.g, PAPER.b, alpha)
	sb.border_color = Color(BRONZE.r, BRONZE.g, BRONZE.b, 0.85)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(radius)
	sb.shadow_color = SHADOW
	sb.shadow_size = 5
	sb.shadow_offset = Vector2(0, 2)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb

static func slim_panel(alpha: float = 0.90) -> StyleBoxFlat:
	var sb := paper_panel(alpha, 3)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	sb.shadow_size = 3
	return sb

static func night_card() -> StyleBoxFlat:
	var sb := paper_panel(0.97, 4)
	sb.border_color = VERMILLION_SOFT
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 18
	sb.content_margin_bottom = 16
	return sb

static func bar_background() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.28, 0.20, 0.14, 0.28)
	sb.set_corner_radius_all(1)
	return sb

static func bar_fill(color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(1)
	return sb

static func resource_fill(value: float) -> Color:
	if value >= 60.0:
		return Color(0.52, 0.58, 0.38)
	if value >= 35.0:
		return Color(0.72, 0.58, 0.32)
	return Color(0.78, 0.38, 0.24)

static func mandate_fill(value: float) -> Color:
	if value < 30.0:
		return Color(0.78, 0.62, 0.28)
	if value < 70.0:
		return Color(0.82, 0.42, 0.18)
	return Color(0.62, 0.16, 0.12)

static func apply_label(label: Label, size: int, color: Color = INK) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)

static func choice_button_normal() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(PAPER_DIM.r, PAPER_DIM.g, PAPER_DIM.b, 0.92)
	sb.border_color = Color(BRONZE.r, BRONZE.g, BRONZE.b, 0.55)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(3)
	sb.content_margin_left = 14
	sb.content_margin_top = 8
	sb.content_margin_right = 14
	sb.content_margin_bottom = 8
	return sb

static func choice_button_hover() -> StyleBoxFlat:
	var sb := choice_button_normal()
	sb.border_color = VERMILLION_SOFT
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.bg_color = Color(0.96, 0.90, 0.82, 0.98)
	return sb

static func choice_button_selected() -> StyleBoxFlat:
	var sb := choice_button_hover()
	sb.bg_color = Color(0.98, 0.92, 0.84, 1.0)
	sb.border_color = VERMILLION
	return sb

static func apply_choice_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", choice_button_normal())
	btn.add_theme_stylebox_override("hover", choice_button_hover())
	btn.add_theme_stylebox_override("focus", choice_button_hover())
	btn.add_theme_stylebox_override("pressed", choice_button_selected())
	btn.add_theme_color_override("font_color", INK)
	btn.add_theme_color_override("font_hover_color", VERMILLION)

static func speaker_tag() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(WOOD.r, WOOD.g, WOOD.b, 0.88)
	sb.border_color = GOLD
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb

static func separator() -> ColorRect:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.color = Color(BRONZE.r, BRONZE.g, BRONZE.b, 0.35)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return line

static func format_delta_line(deltas: Dictionary, zh_map: Dictionary) -> String:
	var parts: PackedStringArray = []
	for k in deltas.keys():
		var zh: String = String(zh_map.get(k, k))
		var v: float = float(deltas[k])
		if absf(v) < 0.01:
			continue
		var sign := "增" if v > 0 else "减"
		parts.append("%s%s%d" % [zh, sign, int(absf(v))])
	if parts.is_empty():
		return ""
	return "　·　" + "　".join(parts)
