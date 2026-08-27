extends RefCounted
class_name CourtyardLayout
# 信王府分区坐标（单一事实源）。+Z 南（府门），-Z 北（正堂）。
#
#          [正堂]     [夜召堂]
#     [灶房]   菜畦 3×2
#              月洞门
#              [井]
#  [畜栏]              [池·蔬果铺]
#              [府门]
#              流民

const GATE := Vector3(0, 0, 23)
const HALL := Vector3(0, 0, -19.5)
const NIGHT_HALL := Vector3(14, 0, -17)
const WELL := Vector3(0, 0, 3.2)
const MOON_GATE := Vector3(0, 0, -2.2)
const POND := Vector3(17, 0, 6)
const PEN := Vector3(-16, 0, 12)
const STALL := Vector3(12.5, 0, 12.5)
const WEST_WING := Vector3(-15.5, 0, -10)
const PLAYER_SPAWN := Vector3(0, 1, 13.5)
const WUBO := Vector3(-12.8, 0, -10.2)
const QIUSHUI := Vector3(11.2, 0, 15.0)
const CHENGEN := Vector3(13.8, 0, -15.8)
const REFUGEE := Vector3(6.5, 0, 21.2)
const SERVANT_KITCHEN := Vector3(-11.2, 0, -10.5)
const SERVANT_PEN := Vector3(-15.8, 0, 11.8)
const BROTHER_VISIT := Vector3(0.5, 0, 7.8)   # 御驾亲访停步处（井台与菜畦之间）

## 菜畦 3×2 网格（列距/行距/锚点）
const PLOT_COL_SP := 3.45
const PLOT_ROW_SP := 3.45
const PLOT_ORIGIN := Vector3(0, 0, -6.6)

## 占位角色统一缩放（约 1.7m 人高）
const CHAR_SCALE := 1.14

static func plot_positions() -> Array[Vector3]:
	var out: Array[Vector3] = []
	for row: int in range(2):
		for col: int in range(3):
			out.append(PLOT_ORIGIN + Vector3(float(col - 1) * PLOT_COL_SP, 0.0, float(row) * PLOT_ROW_SP))
	return out
