extends Node

signal color_updated(color: Color)

var character_data: CharacterData

func _ready() -> void:
	character_data = CharacterData.new()
	print(character_data.color)
	
func update_skin_color(new_color: Color) -> void:
	character_data.color = new_color
	color_updated.emit(new_color)
