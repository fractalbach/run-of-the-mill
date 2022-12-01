extends AudioStreamPlayer

export(AudioStream) var scythe_swing
export(AudioStream) var thresher_swing
export(AudioStream) var bird_hits_player
export(AudioStream) var player_jumps
export(AudioStream) var player_lands
export(AudioStream) var pass_the_mill
export(AudioStream) var pickup_seed
export(AudioStream) var successful_scythe
export(AudioStream) var successful_thresh

onready var player_list = [self]
var current_player = 0

func _ready() -> void:
	for i in range(6):
		var p = AudioStreamPlayer.new()
		player_list.append(p)
		add_child(p)
	

func play_sound(sound):
	player_list[current_player].stop()
	player_list[current_player].stream = sound
	player_list[current_player].play()
	current_player = (current_player + 1) % len(player_list)
