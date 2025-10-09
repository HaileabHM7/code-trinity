extends Area2D

func _ready() -> void:
	Engine.time_scale = 1.0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		print("Player touched kill zone!")

		# Slow down time
		Engine.time_scale = 0.5

		# Disable player collision so they fall through the ground
		if body is CharacterBody2D:
			body.set_collision_layer(0)
			body.set_collision_mask(0)
		
		# Wait 1 second in real-time (ignores time_scale)
		await get_tree().create_timer(1.0, true, false, true).timeout

		# Restore normal speed and restart
		Engine.time_scale = 1.0
		get_tree().change_scene_to_file("res://scenes/restart.tscn")
