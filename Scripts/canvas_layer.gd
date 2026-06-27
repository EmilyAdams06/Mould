extends CanvasLayer

@onready var player: CharacterBody2D = $".."

@onready var label: Label = $Control/Label
@onready var health: ProgressBar = $Control/Health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(roundi(player.energy)) + "/" + str(roundi(player.maxEnergy))
	health.value = player.health
