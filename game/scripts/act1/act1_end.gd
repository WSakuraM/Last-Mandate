extends Control

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		GameState.money = 20
		GameState.veggies = 0
		GameState.memories.clear()
		GameState.traits = {"mercy": 0, "thrift": 0, "diligence": 0}
		GameState.flags = {
			"met_aen": false,
			"first_harvest": false,
			"helped_qiushui": false,
			"crisis_done": false,
			"night_summon_done": false,
			"has_seed_bag": false,
		}
		get_tree().change_scene_to_file("res://scenes/act1/xin_wang_fu.tscn")
