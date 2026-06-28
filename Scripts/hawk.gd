extends CharacterBody2D
class_name Hawk

var SPEED = 300.0
var JUMP_VELOCITY = -80.0
var SWOOP_SPEED = 300.0
var DAMAGE = 10
const GLIDE_FACTOR = 0.05

@export var max_height = 0.0
@export_enum("Normal", "Corrupt") var type: String

@onready var base_hawk_frames = preload("res://Assets/HawkAnimations/base_hawk.tres")
@onready var corrupt_hawk_frames = preload("res://Assets/HawkAnimations/corrupt_hawk.tres")

var detected_player: Node2D = null
var attack # ref to state machine

var start_height: float

func _ready():
	var detection_area = $DetectionArea
	detection_area.area_entered.connect(Callable(self,"_on_detection_area_entered"))
	detection_area.area_exited.connect(Callable(self,"_on_detection_area_exited"))

	if type == "Normal":
		$CollisionShape2D/AnimatedSprite2D.sprite_frames = base_hawk_frames
		SPEED = 50.0
		JUMP_VELOCITY = -80.0
		SWOOP_SPEED = 300.0
		DAMAGE = 10
	elif type == "Corrupt":
		$CollisionShape2D/AnimatedSprite2D.sprite_frames = corrupt_hawk_frames
		SPEED = 25.0
		JUMP_VELOCITY = -40.0
		SWOOP_SPEED = 150.0
		DAMAGE = 30
		
	start_height = position.y

	attack = $Behavior/Attack
	
func _on_detection_area_entered(area: Area2D):
	if area.is_in_group("player"):
		detected_player = area.get_parent()
		print("PLAYER DETECTED: ", detected_player.name)
func _on_detection_area_exited(area: Area2D):
	if area.is_in_group("player"):
		detected_player = null
			
func _physics_process(delta: float) -> void:
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
	position.y = clamp(position.y, start_height-228, start_height+228)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Character:
		attack.attack_success = true
		body.receive_damage(DAMAGE)
		print("attacked")


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body is Character:
		attack.attack_success = false

func set_animation(name: String):
	$CollisionShape2D/AnimatedSprite2D.animation = name
