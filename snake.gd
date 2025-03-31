


# --- Optional: Basic Forward Movement Example ---
# You'll likely want to add movement based on the new direction.
# This requires using _physics_process and CharacterBody3D features.

# @export var speed: float = 5.0
# @export var gravity: float = 9.8

# func _physics_process(delta: float) -> void:
	# # Apply gravity (if using CharacterBody3D)
	# if not is_on_floor():
		# velocity.y -= gravity * delta

	# var move_direction: Vector3 = Vector3.ZERO
	# if Input.is_action_pressed("move_forward"):
		# # Move in the direction the player is facing (local -Z axis)
		# move_direction = -transform.basis.z
	# elif Input.is_action_pressed("move_backward"):
		# move_direction = transform.basis.z

	# velocity.x = move_direction.x * speed
	# velocity.z = move_direction.z * speed

	# # Call move_and_slide (if using CharacterBody3D)
	# move_and_slide()
