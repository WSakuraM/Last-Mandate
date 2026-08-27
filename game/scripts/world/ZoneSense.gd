extends Node
class_name ZoneSense
# 走过分区时轻报地名，让府里有「地方」而不是一块空地。

var _last := ""
var _zone_t := 0.0

func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var p := player.global_position
	var z := _zone_at(p)
	if z != _last:
		_last = z
		if not z.is_empty():
			EventBus.zone_entered.emit(z)

func _zone_at(p: Vector3) -> String:
	if p.distance_to(CourtyardLayout.WELL) < 4.8:
		return "井台"
	if p.distance_to(CourtyardLayout.POND) < 5.5:
		return "池上"
	if p.distance_to(CourtyardLayout.PEN) < 5.5:
		return "畜栏"
	if p.distance_to(CourtyardLayout.STALL) < 5.0:
		return "蔬果铺"
	if p.distance_to(CourtyardLayout.WEST_WING) < 5.5:
		return "灶房"
	if p.distance_to(CourtyardLayout.NIGHT_HALL) < 6.5:
		return "夜召堂"
	if p.distance_to(CourtyardLayout.HALL) < 7.5:
		return "正堂"
	if p.z > 19.0 and absf(p.x) < 9.0:
		return "府门"
	var po := CourtyardLayout.PLOT_ORIGIN
	if absf(p.x - po.x) < 6.0 and p.z > po.z - 1.5 and p.z < po.z + CourtyardLayout.PLOT_ROW_SP + 2.0:
		return "菜圃"
	if absf(p.x) < 2.8 and p.z > -1.0 and p.z < 12.0:
		return "中轴"
	return ""
