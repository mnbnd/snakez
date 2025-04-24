# Enemy.gd
extends CharacterBody3D

@export var speed := 4.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var initial_body_segments: int = 10
@export var segment_delay: int = 5
var body_segments: Array = []
var position_history: Array = []
var max_history: int = 1000

func add_body_segment():
	# Create a physics body to hold the mesh and collision
	var body = StaticBody3D.new()
	add_child(body)

	# Create the mesh instance
	var segment = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	
	
	sphere_mesh.radius = 0.5  # Default is 1.0, adjust as needed
	segment.mesh = sphere_mesh
	segment.scale = Vector3(0.5, 0.5, 0.5)  # Scale mesh visually

	# Set material color
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color8(255, 0, 0)
	segment.material_override = body_material

	body.add_child(segment)

	# Create the collision shape
	var body_hitbox = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	
	#puts segments on different layer than head so its one sided collision


	
	# Set radius to match mesh radius * scale.x (assuming uniform scale)
	sphere_shape.radius = sphere_mesh.radius * segment.scale.x
	body_hitbox.shape = sphere_shape

	body.add_child(body_hitbox)

	body.collision_layer = 2
	#body.collision_mask = 0

	# Positioning
	var forward_direction = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	body.position = Vector3(0, 0, (body_segments.size() + 0.2))

	# Store the body (not just the mesh instance)
	body_segments.append(body)


func _ready():
	_pick_new_destination()
	
	position_history = []
	for i in range(initial_body_segments):
		add_body_segment()

func _physics_process(delta):
	
	var forward_direction = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	
	if nav_agent.is_navigation_finished():
		_pick_new_destination()
		return

	var next_point: Vector3 = nav_agent.get_next_path_position()
	var dir: Vector3 = (next_point - global_transform.origin).normalized()
	var motion: Vector3 = dir * speed * delta




	var collision = move_and_collide(motion)
	if collision:
		# On hit—choose a new random goal
		_pick_new_destination()
		
# Store the head's current GLOBAL position in history
	position_history.append(global_position)
	# Limit history size to prevent memory issues
	if position_history.size() > max_history:
		position_history.remove_at(0)


	for i in range(body_segments.size()):
		var segment = body_segments[i]
		# Calculate the delayed history index for this segment
		var history_index = position_history.size() - 1 - (i + 1) * segment_delay
		if history_index >= 0:
			# Move segment to the delayed position in GLOBAL space
			segment.global_position = position_history[history_index]
		else:
			# If not enough history, position behind based on current facing direction
			var offset = -forward_direction * (i + 1)
			segment.global_position = global_position + offset	

func _pick_new_destination():
	var map_id: RID = nav_agent.get_navigation_map()
	var raw_point: Vector3 = NavigationServer3D.map_get_random_point(
		map_id,
		nav_agent.navigation_layers,
		true
	)
	# Snap to the nearest valid mesh surface
	var safe_point: Vector3 = NavigationServer3D.map_get_closest_point(
		map_id,
		raw_point
	)
	nav_agent.target_position = safe_point
	
	
