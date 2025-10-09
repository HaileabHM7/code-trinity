extends Node2D

func _ready():
	var dialog = Dialogic.start("intro")
	add_child(dialog)
	get_tree().change_scene_to_file("res://game_2d.tscn")
