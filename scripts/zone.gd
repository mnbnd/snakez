# Area3D.gd
extends Area3D

@export var start_radius: float = 40.0   # Starting radius of the sphere
@export var shrink_rate: float = 1.0     # Units per second
@export var min_radius: float = 0.1      # Minimum allowed radius
@export var delay_time: float = 45.0     # Seconds to wait before showing storm

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D  = $MeshInstance3D

var storm_active: bool = false

func _ready() -> void:
	# Connect exit signal
	connect("body_exited", Callable(self, "_on_body_exited"))

	# 1) Hide and disable until after delay
	mesh_instance.visible      = false
	collision_shape.disabled   = true

	# 2) Wait for delay_time seconds…
	await get_tree().create_timer(delay_time).timeout

	# 3) After delay, initialize radius & visuals, then enable
	var sphere_shape = collision_shape.shape as SphereShape3D
	sphere_shape.radius = start_radius
	_update_mesh_scale(start_radius)
	_disable_mesh_culling()

	mesh_instance.visible    = true
	collision_shape.disabled = false
	storm_active             = true


func _process(delta: float) -> void:
	if not storm_active:
		return

	var sphere_shape = collision_shape.shape as SphereShape3D
	var new_radius = max(sphere_shape.radius - shrink_rate * delta, min_radius)
	if new_radius != sphere_shape.radius:
		sphere_shape.radius = new_radius
		_update_mesh_scale(new_radius)


func _on_body_exited(body: Node) -> void:
	# If the storm is active and the exiting body can die, kill it
	if storm_active and body.has_method("die"):
		body.die()


func _update_mesh_scale(radius: float) -> void:
	var mesh_radius   = 0.5  # Default SphereMesh radius is 0.5
	var scale_factor  = radius / mesh_radius
	mesh_instance.scale = Vector3.ONE * scale_factor


func _disable_mesh_culling() -> void:
	# Get or create a translucent material
	var material = mesh_instance.get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	material.albedo_color = Color8(224, 107, 237, 20)
	material.cull_mode     = BaseMaterial3D.CULL_DISABLED
