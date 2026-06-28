class_name Seed

extends RigidBody2D

@export var textures: Array[Texture2D] = []

func _ready() -> void:
	var sprite = $Sprite2D
	var r = randi() % textures.size()
	print(r)
	sprite.texture = textures[r]
