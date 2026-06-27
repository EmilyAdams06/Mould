extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -80.0
const GLIDE_FACTOR = 0.05

@export var max_height = 0.0
@export var screen_height = get_viewport_rect().size.y

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * GLIDE_FACTOR * delta
		$CollisionShape2D/AnimatedSprite2D.animation = &"Flappy"
	else:
		$CollisionShape2D/AnimatedSprite2D.animation = &"default"

	if velocity.x > 0:
		$CollisionShape2D/AnimatedSprite2D.flip_h = false
	else:
		$CollisionShape2D/AnimatedSprite2D.flip_h = true

	move_and_slide()
	
	# Handle jump.
