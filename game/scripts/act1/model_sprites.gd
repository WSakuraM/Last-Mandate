extends RefCounted
class_name ModelSprites
## 从 assets/models 取图；等轴素材统一压扁贴地，贴近顶视场景。

## Great Farm 等轴 → 顶视场景的纵向压扁
const ISO_SQUASH := 0.84
## Hand-Drawn 顶视素材不压扁
const TOP_SQUASH := 1.0

static func tex(category: String, filename: String) -> Texture2D:
	return AssetBank.load_texture(category, filename)

static func crop_tex(kind: String, stage: int) -> Texture2D:
	return tex("vegetation", "%s_s%d.png" % [kind, clampi(stage, 1, 3)])

static func draw_tex(canvas: CanvasItem, texture: Texture2D, center: Vector2, max_h: float = 48.0, modulate: Color = Color.WHITE, squash_y: float = ISO_SQUASH) -> void:
	if texture == null:
		return
	var sz := texture.get_size()
	var scale := max_h / maxf(sz.y, 1.0)
	var w := sz.x * scale
	var h := sz.y * scale * squash_y
	canvas.draw_texture_rect(texture, Rect2(center.x - w * 0.5, center.y - h, w, h), false, modulate)

## foot = 脚底中心；先画阴影再贴图（等轴道具默认）
static func draw_grounded(canvas: CanvasItem, texture: Texture2D, foot: Vector2, max_h: float = 48.0, modulate: Color = Color.WHITE, squash_y: float = ISO_SQUASH) -> void:
	if texture == null:
		return
	var shadow_w := max_h * 0.32
	var shadow_h := max_h * 0.11
	StyleC.draw_outlined_ellipse(canvas, foot + Vector2(0, 2), Vector2(shadow_w, shadow_h), Color(0, 0, 0, 0.16), 1.0)
	draw_tex(canvas, texture, foot, max_h, modulate, squash_y)

static func draw_tex_rect(canvas: CanvasItem, texture: Texture2D, rect: Rect2, modulate: Color = Color.WHITE) -> void:
	if texture == null:
		return
	canvas.draw_texture_rect(texture, rect, false, modulate)
