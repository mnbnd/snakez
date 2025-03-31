# Attach this script to your Player (CharacterBody3D) node

extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var turn_speed = 3.0 # Radians per second for turning

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# No need for direct camera references for basic following/turning!

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# --- Player Rotation ---
	# Calculate rotation amount based on left/right input
	var turn_input = Input.get_axis("ui_left", "ui_right")
	# Rotate the CharacterBody3D around its Y axis
	# This rotation will automatically be inherited by child nodes (SpringArm, Camera)
	rotate_y(turn_input * turn_speed * delta)
	# ----------------------

	# --- Player Movement ---
	# Movement direction is relative to the player's forward direction (basis.z)
	var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	# Note: We use input_dir.y for forward/backward because ui_up/ui_down map to the Y axis of the input vector
	# We don't use X input (strafe) in this specific example, but you could add it:
	# var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	# ----------------------

	move_and_slide()
