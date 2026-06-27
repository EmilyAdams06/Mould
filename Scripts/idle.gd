extends State
class_name Idle

@export var hawk : CharacterBody2D
@export var move_speed := 10.0

func Physics_Update(_delta: float):
	if hawk:
		hawk.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * move_speed
