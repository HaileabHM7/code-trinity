extends Node
func _ready():
	var dialog = Dialogic.start("end")
	add_child(dialog)
