extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -80.0
const GLIDE_FACTOR = 0.1
const FRICTION = 4.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("dive"):
			velocity += get_gravity() * delta
			$AnimatedSprite2D.animation = &"Dive"
		else:
			velocity += get_gravity() * GLIDE_FACTOR * delta
			$AnimatedSprite2D.animation = &"Flap"

	if is_on_floor():
		if Input.is_action_pressed("dive"):
			$AnimatedSprite2D.animation = &"Peck"
		else:
			$AnimatedSprite2D.animation = &"default"
		

	# Handle jump.
	if Input.is_action_just_pressed("flap"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, delta)
		if direction > 0:
			$AnimatedSprite2D.flip_h = false
			if velocity.x < 0:
				velocity.x *= -1.0
		else:
			$AnimatedSprite2D.flip_h = true
			if velocity.x > 0:
				velocity.x *= -1.0
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, delta * FRICTION)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta)

	move_and_slide()
