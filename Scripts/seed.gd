class_name Seed

extends RigidBody2D

@export var textures: Array[Texture2D] = []

func _ready() -> void:
	var sprite = $Sprite2D
	var r = randi() % textures.size()
	sprite.texture = textures[r]
