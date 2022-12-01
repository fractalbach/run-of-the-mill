extends Camera2D

const max_zoom = 3
const min_zoom = 1
const step = 0.05

func _process(delta: float) -> void:
	if Input.is_action_pressed("game_zoom_in"):
		var stepd = step * delta * 60
		zoom[0] = clamp(zoom[0] - stepd, min_zoom, max_zoom)
		zoom[1] = clamp(zoom[1] - stepd, min_zoom, max_zoom)
	elif Input.is_action_pressed("game_zoom_out"):
		var stepd = step * delta * 60
		zoom[0] = clamp(zoom[0] + stepd, min_zoom, max_zoom)
		zoom[1] = clamp(zoom[1] + stepd, min_zoom, max_zoom)
