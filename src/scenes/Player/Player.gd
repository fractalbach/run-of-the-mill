extends KinematicBody2D


const SPEED_X        = 1000
const SPEED_Y        = 30
const SPEED_FALL     = SPEED_Y * 2
const JUMP_TIMER_MAX = 0.4 # in seconds
const INVINCIBLE_COOLDOWN_MAX = 60  # in physics frames (seconds/60)
enum {
	JUMP_READY
	JUMP_UPWARD
	JUMP_FALLING
}
var jump_state = JUMP_READY
var jump_timer = 0.0
var attacking  = false
var ducking    = false
var invincible_cooldown = 0 # Considered invincible if this value is NOT 0.
var hitpoints = 5
var curr_speed_x = 0

onready var min_position_y = position.y
onready var collision_rect_original = $CollisionShape2D.shape.extents
onready var collision_pos_original = $CollisionShape2D.position


func _process(delta):
	
	curr_speed_x = 0
	
	if Input.is_action_pressed("game_right"):
		curr_speed_x += SPEED_X
		$AnimatedSprite.flip_h = false

	if Input.is_action_pressed("game_left"):
		curr_speed_x -= SPEED_X
		$AnimatedSprite.flip_h = true

	#position.x += curr_speed_x * delta * 60
	move_and_slide(Vector2(curr_speed_x, 980), Vector2.UP)

	match jump_state:
		JUMP_READY:
			if Input.is_action_pressed("game_jump"):
				jump_state = JUMP_UPWARD
				
		JUMP_UPWARD:
			if Input.is_action_pressed("game_jump") and jump_timer < JUMP_TIMER_MAX:
				position.y -= jump_speed_based_on_timer() * delta * 60
				jump_timer += delta
			else:
				jump_state = JUMP_FALLING
				jump_timer = 0
			
		JUMP_FALLING:
#			if Input.is_action_pressed("game_down"):
#				position.y += SPEED_FALL * delta * 60
#			if position.y > min_position_y:
#				position.y = min_position_y
#				jump_state = JUMP_READY
			if is_on_floor():
				jump_state = JUMP_READY

	if not attacking:
		if Input.is_action_pressed("game_scythe"):
			$AnimatedSprite.play("scythe")
			attacking = true
		elif Input.is_action_pressed("game_thresh"):
			$AnimatedSprite.play("thresh")
			attacking = true

	# ducking = false

	if attacking:
		return

	if jump_state == JUMP_FALLING or jump_state == JUMP_UPWARD:
		$AnimatedSprite.play("duck")
		# ducking = true
	elif curr_speed_x == 0:
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.play("walk")
	


func _on_AnimatedSprite_animation_finished() -> void:
	match $AnimatedSprite.animation:
		"scythe", "thresh":
			attacking = false
			$AnimatedSprite.play("idle")



func jump_speed_based_on_timer():
	return SPEED_Y * lerp(2, 1, jump_timer/JUMP_TIMER_MAX)



func _physics_process(delta: float) -> void:

#	if ducking:
#		$CollisionShape2D.shape.extents.y = collision_rect_original.y/2
#		$CollisionShape2D.position.y = collision_pos_original.y + collision_rect_original.y/2
#		$Area2D/CollisionShape2D.shape.extents.y = collision_rect_original.y/2
#		$Area2D/CollisionShape2D.position.y = collision_pos_original.y + collision_rect_original.y/2
#	else:
#		$CollisionShape2D.shape.extents.y = collision_rect_original.y
#		$CollisionShape2D.position.y = collision_pos_original.y
#		$Area2D/CollisionShape2D.shape.extents.y = collision_rect_original.y
#		$Area2D/CollisionShape2D.position.y = collision_pos_original.y

	if invincible_cooldown > 1:
		var v = 55 + 20*(invincible_cooldown%10)
		$AnimatedSprite.modulate = Color8(255,v,v,255)
		invincible_cooldown -= 1
	elif invincible_cooldown == 1:
		$AnimatedSprite.modulate = Color8(255,255,255,255)
		invincible_cooldown = 0
