extends State
class_name Attack

@export var hawk: Hawk
@export var swoop_speed := 300.0
@export var swoop_distance := 150.0
@export var attack_success = false

var swoop_start_position: Vector2
var distance_traveled := 0.0

func enter(): 
	if not hawk.detected_player:
		Transitioned.emit(self, "idle")
		return
		
	swoop_start_position = hawk.global_position
	distance_traveled = 0.0
	
func Update(delta: float):
	# add a delay
	if not hawk.detected_player: 	# if player is no longer detected, return to idle immediately
		Transitioned.emit(self, "idle")
		return
	
	# move towards player
	var direction = (hawk.detected_player.global_position - hawk.global_position).normalized()
	hawk.velocity = direction * swoop_speed
	hawk.set_animation("Attack")
	
	# track distance traveled
	distance_traveled += (direction * swoop_speed * delta).length()
			
	#if distance_traveled >= swoop_distance: # if swoop distance reached, return to idle
		#Transitioned.emit(self, "idle")
	if attack_success:
		print("attackSuccess")
		Transitioned.emit(self, "idle")

func exit():
	hawk.velocity = Vector2.ZERO
	print("zero velocity")
