extends Node2D

const speed_x_base = 10.0
var speed_x = speed_x_base

const death_timer_max = 10.0
var death_timer = 0.0

func _enter_tree() -> void:
	speed_x += rand_range(0.0, 5.0)

func _process(delta: float) -> void:
	position.x -= speed_x * delta * 60
	death_timer += delta
	if death_timer > death_timer_max:
		queue_free()
