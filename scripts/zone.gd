extends Area3D

@onready var collision_shape: CollisionShape3D = $zone_hitbox
@onready var mesh_instance: MeshInstance3D = $zone_mesh

func _ready():
	# Get the SphereShape3D from the CollisionShape3D
	var sphere_shape := collision_shape.shape as SphereShape3D
	if sphere_shape == null:
		push_error("CollisionShape3D does not have a SphereShape3D assigned!")
		return

	# Get the radius from the collision shape
	var radius := sphere_shape.radius

	# Create a SphereMesh with the same radius
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	mesh_instance.mesh = sphere_mesh

	# Match the transforms (position, rotation, scale)
	mesh_instance.transform = collision_shape.transform

	# Create a transparent material visible from inside
	var mat := StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.561, 0.204, 0.922, 0.5) # Light blue, semi-transparent
	mesh_instance.material_override = mat
