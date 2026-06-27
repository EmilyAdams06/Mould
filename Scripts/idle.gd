extends State
class_name Idle

@export var hawk : CharacterBody2D
@export var move_speed := 10.0

const JUMP_VELOCITY = -80.0
var time = 3.0
var is_going_left = false

func go_back_and_forth():
	for i in range(3):
		if hawk.position.y > 0:
			hawk.velocity.y = JUMP_VELOCITY
		if is_going_left:
			hawk.velocity.x = 50.0
			await get_tree().create_timer(1).timeout
		elif !is_going_left:
			hawk.velocity.x = -50.0
			await get_tree().create_timer(1).timeout
	is_going_left = !is_going_left


func get_to_sky():
	await get_tree().create_timer(3).timeout
	if hawk.is_on_floor():
		for i in range(5):
			hawk.velocity.y = JUMP_VELOCITY
			await get_tree().create_timer(0.5).timeout
		
func Update(_delta: float):
	if time > 0:
		time -= _delta
	else:
		time = 3
		go_back_and_forth()
		
func Enter():
	get_to_sky()
	
