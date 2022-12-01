extends Node2D

func set_height(height:int) -> void:
	$Line2D.points[1].y = height
	var rect = RectangleShape2D.new()
	rect.extents.x = $Area2D/CollisionShape2D.shape.extents.x
	rect.extents.y = height/2
	$Area2D/CollisionShape2D.position.y = height/2
	$Area2D/CollisionShape2D.shape = rect
