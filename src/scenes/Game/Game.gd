extends Node2D


const bird_timer_max   = 1.5 # how frequently birds spawn (birds/second)
const spawn_distance = 3000  # distance between player and newly spawned objects
var left_limit = 0
var bird_timer = 0.0
var next_wall_spawn_trigger  = 5000
var next_wheat_spawn_trigger = 1000
var wheat_spawn_spacing      = 2123
var windmill_spacing         = 30000
var Bird         = preload("res://scenes/Bird/Bird.tscn")
var Wall         = preload("res://scenes/Wall/Wall.tscn")
var WheatStalk   = preload("res://scenes/WheatStalk/WheatStalk.tscn")
var WheatSeed    = preload("res://scenes/WheatSeed/WheatSeed.tscn")
var WheatChopped = preload("res://scenes/WheatChopped/WheatChopped.tscn")
var wheat_scythed   = 0
var wheat_threshed  = 0
var seeds_collected = 0
var flour_milled    = 0
var difficulty      = 0

const max_difficulty = 3

# Distance in pixels between each wall, based on difficulty
var wall_spawn_spacing = {
	0: 2000,
	1: 2500,
	2: 1500,
	3: 1000,
}

# Interval of time (in seconds) between each bird spawn, based on difficulty
var bird_spawn_interval = {
	0: 5.0,
	1: 2.5,
	2: 1.5,
	3: 1.0,
}

# checkpoints are where the game difficulty changes (up until max_difficulty)
var next_checkpoint_position = {
	0: 5000,
	1: 40000,
	2: 80000,
}

# how fast the left boundary moves (pixels/second)
var left_limit_speed = {
	0: 1.0,
	1: 5.0,
	2: 8.0,
	3: 10.0,
}


func _process(delta: float) -> void:
	update_debugger()
	advance_left_limit(delta)
	bird_spawning_procedure(delta)
	wall_spawning_procedure(delta)
	wheat_spawning_procedure(delta)
	sync_floor_position_with_player()
	if $Player.is_on_wall() and $Player.position.x - 50 < left_limit:
		death_sequence("You got stuck between a rock and a hard place.")
	if $Player.hitpoints <= 0:
		death_sequence("It was a murder of crows.")


func _physics_process(_delta: float) -> void:
	if difficulty < max_difficulty and $Player.position.x > next_checkpoint_position[difficulty]:
		difficulty += 1
	handle_player_collisions()
	handle_objects_past_left_limit()


func handle_player_collisions():
	var areas = $Player/Area2D.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("bird") and $Player.invincible_cooldown == 0:
			$Player.invincible_cooldown = $Player.INVINCIBLE_COOLDOWN_MAX
			$Player.hitpoints -= 1
			Sound.play_sound(Sound.bird_hits_player)
			
		elif area.is_in_group("wheat_stalk") and $Player/AnimatedSprite.animation == "scythe":
			var w = WheatChopped.instance()
			w.position = area.get_parent().position
			add_child(w)
			w.linear_velocity = Vector2(1500, -1500)
			area.get_parent().queue_free()
			wheat_scythed += 1
			Sound.play_sound(Sound.successful_scythe)
			
		elif area.is_in_group("wheat_chopped") and $Player/AnimatedSprite.animation == "thresh":
			var w = WheatSeed.instance()
			w.position = area.get_parent().position
			add_child(w)
			w.linear_velocity = Vector2(1500, -1500)
			area.get_parent().queue_free()
			wheat_threshed += 1
			Sound.play_sound(Sound.successful_thresh)
			
		elif area.is_in_group("wheat_seed") and area.get_node("../SpawnTimer").is_stopped():
			area.get_parent().queue_free()
			seeds_collected += 1
			Sound.play_sound(Sound.pickup_seed)
		
		elif area.is_in_group("windmill"):
			flour_milled = seeds_collected
			$Player.hitpoints = 5
			if $WindmillSoundTimer.is_stopped():
				Sound.play_sound(Sound.pass_the_mill)
				$WindmillSoundTimer.start()


func handle_objects_past_left_limit():
	var lim = left_limit - 400
	if $Windmill.position.x < lim:
		$Windmill.position.x += windmill_spacing
	
	for group in ["wall", "wheat_seed", "wheat_chopped", "wheat_stalk"]:
		for obj in get_tree().get_nodes_in_group(group):
			if obj.get_parent().position.x < lim:
				obj.get_parent().queue_free()


func update_debugger():
	$Debugger/Label.text = \
		"FPS: %3d \n" % Engine.get_frames_per_second()\
		+ "Distance: %d \n" % ($Player.position.x / 100)\
		+ "Difficulty: %d \n" % difficulty\
		+ "Hitpoints: %d \n" % $Player.hitpoints


func advance_left_limit(delta):
	left_limit = max(left_limit + left_limit_speed[difficulty]*delta*60, $Player.position.x - 500)
	$Player/Camera2D.limit_left = left_limit
	$left_limit_line.position.x = left_limit
	if $Player.position.x < left_limit + 50:
		$Player.position.x = left_limit + 50


func bird_spawning_procedure(delta):
	if difficulty < 1:
		return
	bird_timer += delta
	if bird_timer >= bird_spawn_interval[difficulty]:
		bird_timer = 0
		var b = Bird.instance()
		b.position.x = $Player.position.x + spawn_distance
		var r = rand_range(0.0, 1.0)
		if   r < 0.33: b.position.y = -200
		elif r < 0.66: b.position.y = -400
		else:          b.position.y = -600
		add_child(b)


func wall_spawning_procedure(delta):
	if $Player.position.x >= next_wall_spawn_trigger:
		next_wall_spawn_trigger += wall_spawn_spacing[difficulty]
		var w = Wall.instance()
		w.position.x = $Player.position.x + spawn_distance
		var r = rand_range(0.0, 1.0)
		if   r < 0.33:
			w.position.y = -100
		elif r < 0.66:
			w.position.y = -200
		else:
			w.position.y = -400
		add_child(w)


func wheat_spawning_procedure(delta):
	if difficulty < 1:
		return
	if $Player.position.x >= next_wheat_spawn_trigger:
		next_wheat_spawn_trigger += wheat_spawn_spacing
		var w = WheatStalk.instance()
		w.position.x = $Player.position.x + spawn_distance
		var r = rand_range(0.0, 1.0)
		if r < 0.33:   w.position.y = -300
		elif r < 0.66: w.position.y = -500
		else:          w.position.y = -700
		w.set_height(-w.position.y)
		add_child(w)


func sync_floor_position_with_player():
	$Floor.position.x = $Player.position.x


func death_sequence(message = "Oh no, You have died!"):
	$CanvasLayer/CenterContainer/VBoxContainer/FinalScoreLabel.bbcode_text = \
		"[table=2]"\
		+ "[cell]Distance Walked: [/cell][cell]%d[/cell] \n" % ($Player.position.x / 100)\
		+ "[cell]Wheat Scythed: [/cell][cell]%d[/cell] \n" % wheat_scythed\
		+ "[cell]Wheat Threshed: [/cell][cell]%d[/cell] \n" % wheat_threshed\
		+ "[cell]Seeds Collected: [/cell][cell]%d[/cell] \n" % seeds_collected\
		+ "[cell]Flour Milled: [/cell][cell]%d[/cell] \n" % flour_milled\
		+ "[/table]"
	$CanvasLayer/CenterContainer/VBoxContainer/OhNoLabel.bbcode_text = \
		"[b][center]" + message + "[/center][/b]"
	$CanvasLayer/CenterContainer.visible = true
	$CanvasLayer/ColorRect.visible = true
	get_tree().paused = true



