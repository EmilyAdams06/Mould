class_name Character

extends CharacterBody2D

#Variables
@export var maxEnergy = 100
@export var maxHealth = 100

const SPEED = 100.0
const JUMP_VELOCITY = -80.0
const GLIDE_FACTOR = 0.1
const FRICTION = 4.0
const DIVE_COST = 5.0
const FLAP_COST = 1.0

var health = 100.0
var energy = 100.0
var is_in_range: bool = false

var damage_timer = -1.0

var target_object: Node2D

func receive_damage(amount: int) -> void:
	health -= amount
	$AnimatedSprite2D.animation = &"Damage"
	$AnimatedSprite2D.modulate = Color(1.0, 0.5, 0.5, 1.0)
	damage_timer = 0.3
	if health <= 0:
		die()

func die() -> void:
	get_tree().reload_current_scene()
	health = maxHealth
	energy = maxEnergy

func _physics_process(delta: float) -> void:
	damage_timer -= delta
	if damage_timer > 0.0: return
	$AnimatedSprite2D.modulate = Color(1.0,1.0,1.0,1.0)
	
	var direction := Input.get_axis("ui_left", "ui_right")
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("dive") and energy > 0:
			velocity += get_gravity() * delta
			$AnimatedSprite2D.animation = &"Dive"
			energy -= DIVE_COST * delta
		else:
			velocity += get_gravity() * GLIDE_FACTOR * delta
			$AnimatedSprite2D.animation = &"Flap"

	if is_on_floor():
		if Input.is_action_pressed("dive"):
			$AnimatedSprite2D.animation = &"Peck"
		elif direction:
			$AnimatedSprite2D.animation = &"Walk"
		else:
			$AnimatedSprite2D.animation = &"default"

	# Handle jump.
	if Input.is_action_just_pressed("flap") and energy > 0:
		velocity.y = JUMP_VELOCITY
		energy -= FLAP_COST

	# Eat seed
	if is_in_range:
		if Input.is_action_just_pressed("dive"):
			print("Yum")
			energy += 10
			target_object.queue_free()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
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

	energy = clamp(energy, 0.0, 100.0)

	move_and_slide()
	


func _on_range_body_entered(body: Node2D) -> void:
	if body is Seed:
		is_in_range = true
		print("isInRange")
		target_object = body


func _on_range_body_exited(body: Node2D) -> void:
	if body is Seed:
		is_in_range = false
		print("isNotInRange")
		target_object = null
