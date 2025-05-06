extends Area3D

@export var start_radius: float = 50.0   
@export var shrink_rate: float = 1.25     
@export var min_radius: float = 0.1     
@export var delay_time: float = 30.0    #time to wait before storm

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D  = $MeshInstance3D

var storm_active: bool = false

func _ready() -> void:
	connect("body_exited", Callable(self, "_on_body_exited"))

	#hide until time
	mesh_instance.visible      = false
	collision_shape.disabled   = true

	#wait for timer
	await get_tree().create_timer(delay_time).timeout

	#show tingz
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

	#make equivalnt shape and shrink it at the same time
	var sphere_shape = collision_shape.shape as SphereShape3D
	var new_radius = max(sphere_shape.radius - shrink_rate * delta, min_radius)
	if new_radius != sphere_shape.radius:
		sphere_shape.radius = new_radius
		_update_mesh_scale(new_radius)


func _on_body_exited(body: Node) -> void:
	#call die function in respective player/enemy script
	if storm_active and body.has_method("die"):
		print("Storm death")
		body.die()


func _update_mesh_scale(radius: float) -> void:
	var mesh_radius   = 0.5  
	var scale_factor  = radius / mesh_radius
	mesh_instance.scale = Vector3.ONE * scale_factor


func _disable_mesh_culling() -> void:
	var material = mesh_instance.get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	material.albedo_color = Color8(224, 107, 237, 20)
	material.cull_mode     = BaseMaterial3D.CULL_DISABLED #for two sided
