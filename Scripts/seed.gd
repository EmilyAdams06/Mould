class_name Seed

extends Area2D

#func _on_body_entered(body: Node2D) -> void:
	#if bsdy is Character:
		#body.seed_collisions.append(self)


#func _on_body_exited(body: Node2D) -> void:
	#if body sis Character:
		#var index = body.seed_collisions.find(self)
		#if  index != -1:
			#body.seed_collisions.remove_at(index)
