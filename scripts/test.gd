# Enemy.gd
extends CharacterBody3D

@export var speed := 4.0
@export var initial_body_segments: int = 10
@export var segment_delay: int = 5
@export var turn_distance: float = 4.0  # Distance between turns
@export var food_seek_bias: float = 1.0 # 0.0 = random, 1.0 = always toward food

var body_segments: Array = []
var position_history: Array = []
var max_history: int = 1000

var directions = [
	Vector3.FORWARD,  # (0, 0, -1)
	Vector3.BACK,     # (0, 0, 1)
	Vector3.LEFT,     # (-1, 0, 0)
	Vector3.RIGHT     # (1, 0, 0)
]
var current_direction: Vector3 = Vector3.FORWARD
var next_turn_position: Vector3 = Vector3.ZERO
var turning: bool = false

func add_body_segment():
	var body = StaticBody3D.new()
	add_child(body)

	var segment = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	segment.mesh = sphere_mesh
	segment.scale = Vector3(0.5, 0.5, 0.5)

	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color8(255, 0, 0)
	segment.material_override = body_material

	body.add_child(segment)

	var body_hitbox = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = sphere_mesh.radius * segment.scale.x
	body_hitbox.shape = sphere_shape

	body.add_child(body_hitbox)

	body.collision_layer = 2

	body.position = Vector3(0, 0, (body_segments.size() + 0.2))
	body_segments.append(body)

func _ready():
	randomize()
	_pick_new_direction()
	position_history = []
	for i in range(initial_body_segments):
		add_body_segment()

func _physics_process(delta):
	var motion = current_direction * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		_pick_new_direction()
		return

	if not turning and global_position.distance_to(next_turn_position) < 0.2:
		turning = true
		_pick_new_direction()

	position_history.append(global_position)
	if position_history.size() > max_history:
		position_history.remove_at(0)

	for i in range(body_segments.size()):
		var segment = body_segments[i]
		var history_index = position_history.size() - 1 - (i + 1) * segment_delay
		if history_index >= 0:
			segment.global_position = position_history[history_index]
		else:
			var offset = -current_direction * (i + 1)
			segment.global_position = global_position + offset

func _pick_new_direction():
	turn_distance = randf_range(3.0, 8.0)

	
	var perp_dirs = []
	if current_direction == Vector3.FORWARD or current_direction == Vector3.BACK:
		perp_dirs.append(Vector3.LEFT)
		perp_dirs.append(Vector3.RIGHT)
	else:
		perp_dirs.append(Vector3.FORWARD)
		perp_dirs.append(Vector3.BACK)

	var food = _get_nearest_food()
	var chosen_dir = perp_dirs[randi() % perp_dirs.size()]

	if food:
		var to_food = (food.global_position - global_position)
		var best_dir = perp_dirs[0]
		var best_dot = -INF
		for dir in perp_dirs:
			var dot = dir.normalized().dot(to_food.normalized())
			if dot > best_dot:
				best_dot = dot
				best_dir = dir
		chosen_dir = best_dir
		print("Turning toward food. Chosen direction:", chosen_dir)
	else:
		print("No food found. Random direction:", chosen_dir)

	current_direction = chosen_dir
	next_turn_position = global_position + current_direction * turn_distance
	turning = false



func _get_nearest_food():
	var nearest_food = null
	var nearest_dist = INF
	var food_nodes = get_tree().get_nodes_in_group("Food")
	print("Found", food_nodes.size(), "food nodes in group.")
	for food in food_nodes:
		if not food is Node3D:
			continue
		var dist = global_position.distance_to(food.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_food = food
	return nearest_food
