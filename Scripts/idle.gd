extends State
class_name Idle

@export var hawk: CharacterBody2D
@export var move_speed := 10.0

const JUMP_VELOCITY = -80.0

var time_since_last_action := 0.0
var is_going_left := false
var current_phase := "ascending"  # "ascending", "patrol", "waiting"
var phase_timer := 0.0
var patrol_step := 0

func _ready():
	# Auto-assign hawk if not already set in Inspector
	if not hawk:
		hawk = get_parent().get_parent()  # Behavior -> CharacterBody2D (Hawk)

func enter():
	print("idling")
	current_phase = "ascending"
	phase_timer = 0.0
	patrol_step = 0
	is_going_left = false

func Update(delta: float):
	if not hawk:
		return
	
	phase_timer += delta
	
	# ascending needs a height limit
	match current_phase:
		"ascending": # to the sky!
			if phase_timer >= 2.0: # ascend
				current_phase = "patrol"
				phase_timer = 0.0
				patrol_step = 0
			else:
				# jump repeatedly while ascending
				if int(phase_timer * 2) % 2 == 0:  # Every ~0.5 seconds
					hawk.velocity.y = JUMP_VELOCITY
		
		"patrol":
			# Patrol back and forth (12 loops)
			if patrol_step < 24:  # 12 loops = 24 half-loops
				if phase_timer >= 3.0:
					phase_timer = 0.0
					patrol_step += 1
					is_going_left = (patrol_step % 2 == 0)
				
				if is_going_left:
					hawk.velocity.x = 50.0
				else:
					hawk.velocity.x = -50.0
				hawk.velocity.y = JUMP_VELOCITY*0.001
			else:
				# Patrol complete, wait before ascending again
				current_phase = "waiting"
				phase_timer = 0.0
				
			# check for player detection
			if hawk.detected_player:
				Transitioned.emit(self, "attack")
				print("noticed player")
				return	
		
		"waiting":
			# Rest for 3 seconds before ascending again
			if phase_timer >= 3.0:
				current_phase = "ascending"
				phase_timer = 0.0
				patrol_step = 0
			else:
				hawk.velocity.x = 0.0

func exit():
	hawk.velocity = Vector2.ZERO
