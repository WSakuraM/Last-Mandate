extends Control

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event is InputEventKey or event is InputEventMouseButton:
			_start()

func _start() -> void:
	get_tree().change_scene_to_file("res://scenes/act1/xin_wang_fu.tscn")
