extends Control

func _ready():
	var dialog = Dialogic.start("free")  # Start the Dialogic timeline named "free"
	add_child(dialog)

	# Wait until the timeline finishes before changing scene
	if not dialog.is_connected("timeline_ended", Callable(self, "_on_timeline_ended")):
		dialog.connect("timeline_ended", Callable(self, "_on_timeline_ended"))
