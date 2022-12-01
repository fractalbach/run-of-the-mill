extends Button

func _pressed() -> void:
	var err = get_tree().change_scene("res://scenes/Game/Game.tscn")
	if err != OK:
		print("'Play Game' Button Failed. ", err)
	else:
		print("'Play Game' Button was successfully activated.")
