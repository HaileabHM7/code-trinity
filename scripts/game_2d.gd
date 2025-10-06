extends Node2D
func _ready():
	var dialog = Dialogic.start("intro")
	add_child(dialog)
	

func _on_player_reached_goal():
	var dialog = Dialogic.start("end")
	add_child(dialog)
