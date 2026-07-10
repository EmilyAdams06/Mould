extends Control

@onready var character_data = Customization.character_data

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_overworld.scn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_color_picker_color_changed(new_color: Color) -> void:
	character_data.color = new_color
	Customization.update_skin_color(new_color)
	print(new_color)
