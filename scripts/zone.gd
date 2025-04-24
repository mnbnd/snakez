extends Area3D

@export var area_shrink_rate: float = 0.1



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var amount: float = area_shrink_rate * delta
	# subtract uniformly from each axis
	var new_scale: Vector3 = scale - Vector3.ONE * amount
	# prevent any component going negative
	new_scale.x = max(new_scale.x, 0)
	new_scale.y = max(new_scale.y, 0)
	new_scale.z = max(new_scale.z, 0)
	scale = new_scale
