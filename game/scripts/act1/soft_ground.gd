extends Node2D
## 风格 C 地表：顶视草地平铺（不用等轴草），土路略扁。

var _grass: Texture2D
var _dirt: Texture2D

func _ready() -> void:
	## 只用顶视草；缺再回退等轴
	_grass = ModelSprites.tex("materials", "grass_tile.png")
	if _grass == null:
		_grass = ModelSprites.tex("materials", "grass_iso.png")
	_dirt = ModelSprites.tex("materials", "dirt_tile.png")
	WorldClock.season_changed.connect(func(_s): queue_redraw())
	WorldClock.disaster_changed.connect(func(_k): queue_redraw())
	queue_redraw()

func _draw() -> void:
	var paper := StyleC.PAPER
	var tint := Color.WHITE
	match WorldClock.season:
		WorldClock.Season.SUMMER:
			paper = Color(0.98, 0.94, 0.82, 1)
			tint = Color(1.0, 0.98, 0.9, 1)
		WorldClock.Season.AUTUMN:
			tint = Color(1.0, 0.9, 0.75, 1)
		WorldClock.Season.WINTER:
			paper = Color(0.92, 0.94, 0.96, 1)
			tint = Color(0.9, 0.95, 1.0, 1)
		_:
			pass
	if WorldClock.disaster == "drought":
		tint = Color(1.0, 0.88, 0.7, 1)
		paper = Color(0.96, 0.88, 0.72, 1)
	draw_rect(Rect2(0, 0, 1600, 900), paper)
	if _grass:
		## 略扁的顶视格，减弱「大块正方」感
		var tw := 110.0
		var th := 88.0
		for x in range(0, 1600, int(tw)):
			for y in range(80, 820, int(th)):
				draw_texture_rect(_grass, Rect2(x, y, tw, th), false, tint * Color(1, 1, 1, 0.88))
	else:
		StyleC.draw_outlined_ellipse(self, Vector2(640, 420), Vector2(520, 280), StyleC.GRASS_A * tint, 3.0)
	## 土路：扁椭圆带，贴合顶视
	if _dirt:
		draw_texture_rect(_dirt, Rect2(200, 400, 880, 72), false, Color(1, 1, 1, 0.9))
	else:
		StyleC.draw_outlined_ellipse(self, Vector2(640, 430), Vector2(460, 70), StyleC.DIRT, 2.5)
