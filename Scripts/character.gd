class_name Character

extends CharacterBody2D

#cum
#Variables
@export var maxEnergy = 100
@export var maxHealth = 100

const SPEED = 100.0
const JUMP_VELOCITY = -80.0
const GLIDE_FACTOR = 0.1
const FRICTION = 4.0
const DIVE_COST = 5.0
const FLAP_COST = 1.0
const ATTACK_COST = 5.0

var health = 100.0
var energy = 100.0
var is_in_range: bool = false

var damage_timer = -1.0
var attack_timer = -1.0

var target_object: Node2D

# indicator setup 
#var indicator_Sprite : AnimatedSprite2D
@onready var indicator_Sprite : Node2D = get_node("AnimatedSprite2D/indicatorSprite")

func receive_damage(amount: int) -> void:
	if attack_timer < 0.1:
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
	attack_timer -= delta
	if damage_timer > 0.0: return
	if attack_timer > 0.1:
		if is_on_floor():
			$AnimatedSprite2D.animation = &"Attack_floor"
		else:
			$AnimatedSprite2D.animation = &"Attack"
		return
	$AnimatedSprite2D.modulate = Color(1.0,1.0,1.0,1.0)
	
	var direction := Input.get_axis("move_left", "move_right")
	# Add the gravity.
	# Layer 5 is all platforms, tree or not
	if not is_on_floor():
		if Input.is_action_pressed("dive") and energy > 0:
			velocity += get_gravity() * delta
			$AnimatedSprite2D.animation = &"Dive"
			energy -= DIVE_COST * delta
			set_collision_mask_value(5, false)
		else:
			velocity += get_gravity() * GLIDE_FACTOR * delta
			$AnimatedSprite2D.animation = &"Flap"
			set_collision_mask_value(5, true)

	if is_on_floor():
		if Input.is_action_pressed("dive"):
			$AnimatedSprite2D.animation = &"Peck"
			set_collision_mask_value(5, false)
		elif direction:
			$AnimatedSprite2D.animation = &"Walk"
			set_collision_mask_value(5, true)
		else:
			$AnimatedSprite2D.animation = &"default"
			set_collision_mask_value(5, true)

	# Handle jump.
	if Input.is_action_just_pressed("flap") and energy > 0:
		velocity.y = JUMP_VELOCITY
		energy -= FLAP_COST
		
	if attack_timer > 0.1:
		$AnimatedSprite2D.modulate = Color(0.0,1.0,1.0,1.0)
	# Eat seed
	if is_in_range:
		if Input.is_action_just_pressed("dive"):
			print("Yum")
			energy += 10
			health += 5
			target_object.queue_free()
	
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

	# Handle attack
	if Input.is_action_just_pressed("attack") and energy > 0 and attack_timer < 0.0:
		energy -= ATTACK_COST
		var fist: Area2D = $LFist if $AnimatedSprite2D.flip_h else $RFist
		for body in fist.get_overlapping_bodies():
			if body is Hawk:
				body.receive_damage(1)
		attack_timer = 0.5

	energy = clamp(energy, 0.0, 100.0)

	move_and_slide()
	


func _on_range_body_entered(body: Node2D) -> void:
	if body is Seed:
		is_in_range = true
		print("isInRange")
		target_object = body
		indicator_Sprite.play("see_food")


func _on_range_body_exited(body: Node2D) -> void:
	if body is Seed:
		is_in_range = false
		print("isNotInRange")
		target_object = null
		indicator_Sprite.play("none")
