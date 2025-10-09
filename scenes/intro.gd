extends Node2D
var conversation = [
	{"speaker": "Player", "text": "The moon is high ... She doesnt have much time"},
	{"speaker": "Player", "text": "This Shadow creatures ... they're drawn to her light."},
	{"speaker": "Player", "text": "Every minute that passes the curse tights its grip."},
	{"speaker": "Player", "text": "My sword feels heavier with each swing."},
	{"speaker": "Player", "text": "What parts of my self must i sacrifice to reach her."},
	{"speaker": "Player", "text": "No matter the cost, i will save her before the mid-night."}
]

func _ready() -> void:
	$DialogueUI.visible = true  # show panel
	for line_data in conversation:
		$DialogueUI/Panel/SpeakerLabel.text = line_data["speaker"]  # set speaker name
		$DialogueUI/Panel/TextLabel.text = line_data["text"]  # set dialogue text
		await get_tree().create_timer(2.0).timeout  # wait 2 seconds for each line
	$DialogueUI.visible = false
	get_tree().change_scene_to_file("res://assets/game/game.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
