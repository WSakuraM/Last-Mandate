extends Node3D
# 《末命》主入口：构建第一幕世界与 HUD。

func _ready():
	var world = load("res://scripts/world/Act1Director.gd").new()
	add_child(world)
	var hud = load("res://scripts/ui/HUD.gd").new()
	add_child(hud)
