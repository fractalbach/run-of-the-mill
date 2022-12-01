extends AudioStreamPlayer

export(Array, AudioStream) var song_list
var current_song = 0


func _ready() -> void:
	connect("finished", self, "_on_finished")
	stream = song_list[0]
	play()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_0:
			stop()
			_on_finished()

func _on_finished():
	print("song", current_song, " ending.")
	current_song = (current_song + 1) % len(song_list)
	stream = song_list[current_song]
	print("playing song", current_song," now.")
	play()
