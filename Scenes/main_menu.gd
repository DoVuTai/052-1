extends Control


func _on_multi_btn_pressed() -> void:
	Global.online_mode = true
	get_tree().change_scene_to_file("res://Scenes/connect_ui.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_single_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
