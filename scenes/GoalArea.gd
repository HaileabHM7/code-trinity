extends Area2D

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if triggered:
		return

	# Safety check
	if body == null:
		return

	# Check the correct group
	if body.is_in_group("Players"):  # <-- matches your group name
		triggered = true

		# Start the "end" dialogue
		if Engine.has_singleton("Dialogic"):
			Dialogic.start("end")  # latest Dialogic call for Godot 4
		else:
			push_error("Dialogic singleton not found! Make sure plugin is enabled.")
