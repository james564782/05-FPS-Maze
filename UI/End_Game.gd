extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not Global.won:
		$Label.text = "Game Over! Your final score was " + str(Global.score) + " points"
	else:
		$Label.text = "You defeated all of the enemies! Your final score was " + str(Global.score) + " points"


func _on_Play_pressed():
	Global.reset()
	var _scene = get_tree().change_scene("res://Game.tscn")


func _on_Quit_pressed():
	get_tree().quit()
