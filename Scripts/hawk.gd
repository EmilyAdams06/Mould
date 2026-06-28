extends CharacterBody2D
class_name Hawk

const SPEED = 300.0
const JUMP_VELOCITY = -80.0
const GLIDE_FACTOR = 0.05

@export var max_height = 0.0

var detected_player: Node2D = null
var attack # ref to state machine

@onready var screen_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

func _ready():
	var detection_area = $DetectionArea
	detection_area.area_entered.connect(Callable(self,"_on_detection_area_entered"))
	detection_area.area_exited.connect(Callable(self,"_on_detection_area_exited"))

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
	position = position.clamp(Vector2.ZERO, screen_size)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Character:
		attack.attack_success = true
		body.receive_damage(10)
		print("attacked")


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body is Character:
		attack.attack_success = false

func set_animation(name: String):
	$CollisionShape2D/AnimatedSprite2D.animation = name
