#ENEMY LOGIC
extends CharacterBody3D

@export var speed := 5.75
@export var initial_body_segments: int = 10
@export var segment_delay: int = 5
@export var turn_distance: float = 4.0  # Distance between turns
@export var food_seek_bias: float = 1.0  # 0.0 = random, 1.0 = always toward food
@onready var chomp      = $"../player/chomp_sfx"
@onready var death_sfx      = $"../player/death_sfx"


var body_segments: Array    = []
var position_history: Array = []
var max_history: int        = 1000

var directions = [
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.LEFT,
	Vector3.RIGHT
]
var current_direction: Vector3 = Vector3.FORWARD
var next_turn_position: Vector3 = Vector3.ZERO
var turning: bool = false

func _ready():
	#head lives on layer 1, and only collides with layer 2 (our collidable segments)
	collision_layer = 1
	collision_mask  = 2

	randomize()
	_pick_new_direction()
	for i in range(initial_body_segments):
		add_body_segment()

func add_body_segment():
	if body_segments.size() > 9:
		chomp.play()
	
	var idx = body_segments.size()
	var body = StaticBody3D.new()
	add_child(body)
	body.add_to_group("body_segment")

	# first three segments never get a collision layer/mask
	if idx <= 3:
		body.collision_layer = 0
		body.collision_mask  = 0
	else:
		body.collision_layer = 2
		body.collision_mask  = 1

	# visual mesh
	var mesh_inst = MeshInstance3D.new()
	var sphere   = SphereMesh.new()
	sphere.radius = 0.5
	mesh_inst.mesh       = sphere
	mesh_inst.scale      = Vector3(0.5, 0.5, 0.5)
	var mat = StandardMaterial3D.new()
	mat.albedo_color     = Color8(255, 0, 0)
	mesh_inst.material_override = mat
	body.add_child(mesh_inst)

	# collision shape
	var shape     = CollisionShape3D.new()
	var sph_shape = SphereShape3D.new()
	sph_shape.radius = sphere.radius * mesh_inst.scale.x
	shape.shape = sph_shape
	body.add_child(shape)

	# initial local placement (will be overridden by the trail logic)
	body.position = Vector3(0, 0, idx + 0.2)
	body_segments.append(body)

func _physics_process(delta):
	# move
	var motion = current_direction * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		var hit = collision.get_collider()
		# any segment beyond the first 3 (or any other body's segment) kills
		if hit.is_in_group("body_segment"):
			die()
			return
		# otherwise it’s just an obstacle—pick a new direction
		_pick_new_direction()
		return

	# scheduled turn?
	if not turning and global_position.distance_to(next_turn_position) < 0.2:
		turning = true
		_pick_new_direction()

	# record trail
	position_history.append(global_position)
	if position_history.size() > max_history:
		position_history.remove_at(0)

	# update body segments
	for i in range(body_segments.size()):
		var seg = body_segments[i]
		var history_index = position_history.size() - 1 - (i + 1) * segment_delay
		if history_index >= 0:
			seg.global_position = position_history[history_index]
		else:
			seg.global_position = global_position - current_direction * (i + 1)

func _pick_new_direction():
	turn_distance = randf_range(3.0, 8.0)

	var perp_dirs = []
	if current_direction == Vector3.FORWARD or current_direction == Vector3.BACK:
		perp_dirs = [Vector3.LEFT, Vector3.RIGHT]
	else:
		perp_dirs = [Vector3.FORWARD, Vector3.BACK]

	var food = _get_nearest_food()
	var chosen_dir = perp_dirs[randi() % perp_dirs.size()]

	if food:
		var to_food = (food.global_position - global_position).normalized()
		var best_dir = perp_dirs[0]
		var best_dot = -INF
		for dir in perp_dirs:
			var dot = dir.dot(to_food)
			if dot > best_dot:
				best_dot = dot
				best_dir = dir
		chosen_dir = best_dir

	current_direction    = chosen_dir
	next_turn_position  = global_position + current_direction * turn_distance
	turning             = false

func _get_nearest_food():
	var nearest = null
	var ndist   = INF
	for food in get_tree().get_nodes_in_group("Food"):
		if food is Node3D:
			var d = global_position.distance_to(food.global_position)
			if d < ndist:
				ndist   = d
				nearest = food
	return nearest

func die():
	death_sfx.play()
	print("Enemy died")
	get_node("../victory").victory()
	queue_free()
