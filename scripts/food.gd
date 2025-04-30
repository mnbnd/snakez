extends Node3D

# Reference to the player node
@export var player: Node3D
@export var enemy: Node3D 

@export var x_offset = 5
@export var y_offset = 10

# Map boundaries for random spawning
@export var map_size: Vector3 = Vector3(20, 0, 20)

func _ready():
	# Spawn the first piece of food
	add_to_group("Food")
	for i in range(20):
		spawn_food()

func spawn_food():
	var x = randf_range(-map_size.x, map_size.x) + x_offset
	var z = randf_range(-map_size.z, map_size.z) + y_offset
	position = Vector3(x, 4.5, z)

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Collided with:", body)
	
	if body.is_in_group("snake"):
		body.call("add_body_segment")
		spawn_food()

	
