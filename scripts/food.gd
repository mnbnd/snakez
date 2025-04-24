extends Node3D

# Reference to the player node
@export var player: Node3D

# Map boundaries for random spawning
@export var map_size: Vector3 = Vector3(10, 0, 10)

func _ready():
	# Spawn the first piece of food
	spawn_food()

func spawn_food():
	var x = randf_range(-map_size.x, map_size.x)
	var z = randf_range(-map_size.z, map_size.z)
	position = Vector3(x, 4.5, z)

func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if the player collided with the food
	if body == player:
		# Call the add_body_segment function from the player script
		player.call("add_body_segment")
		# Respawn the food at a new random position
		spawn_food()
