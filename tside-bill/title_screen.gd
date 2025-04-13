extends Control


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main-hall.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
