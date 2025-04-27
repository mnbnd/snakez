# Area3D.gd
extends Area3D

@export var start_radius: float = 80.0   # Starting radius of the sphere
@export var shrink_rate: float = 1.0    # Units per second
@export var min_radius: float = 0.1     # Minimum allowed radius

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	var sphere_shape := collision_shape.shape as SphereShape3D
	sphere_shape.radius = start_radius
	_update_mesh_scale(start_radius)
	_disable_mesh_culling()

func _process(delta: float) -> void:
	var sphere_shape := collision_shape.shape as SphereShape3D
	var new_radius = max(sphere_shape.radius - shrink_rate * delta, min_radius)
	if new_radius != sphere_shape.radius:
		sphere_shape.radius = new_radius
		_update_mesh_scale(new_radius)

func _update_mesh_scale(radius: float) -> void:
	var mesh_radius = 0.5 # Default SphereMesh radius is 0.5
	var scale_factor = radius / mesh_radius
	mesh_instance.scale = Vector3.ONE * scale_factor

func _disable_mesh_culling() -> void:
	# Get the current material or create a new one if none exists
	var material := mesh_instance.get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
		material.albedo_color = Color8(224, 107, 237, 50)
	# Disable backface culling
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
