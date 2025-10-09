extends Node2D
func _ready():
	var dialog = Dialogic.start("intro")
	add_child(dialog)
	
