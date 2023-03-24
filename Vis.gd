extends Spatial

onready var serialNode = $Serial
onready var visParent = $"Vis Parent"

var fov_deg = 43
var grid_size = 4

func _process(delta):
	var result = JSON.parse(serialNode.data)
	
	if(result.error == OK):
		var distances = result.result.distance
		var status = result.result.status
		
		assert(distances.size() == grid_size * grid_size)
		
		# Drop all visualiser children.
		for node in visParent.get_children():
			visParent.remove_child(node)
			node.queue_free()
		
		for row in range(0, grid_size):
			for col in range(0, grid_size):
				
				var this_distance = distances[row * grid_size + col] / 50
				var node = create_cube(Color(1,0,0), Vector3(1,1,1))
				
				visParent.add_child(node)
				
				var half_fov = fov_deg / 2
				var fov_per_step = fov_deg / grid_size
				
				# Left/right angle, based on col
				var angle_z = (-1 * half_fov) + (col * fov_per_step)
				
				# Up/down angle, based on row.
				var angle_x = (-1 * half_fov) + (row * fov_per_step)
				
				node.rotate(node.transform.basis.z, deg2rad(angle_z))
				node.rotate(node.transform.basis.x, deg2rad(angle_x))
				node.translate(Vector3(0,this_distance,0))
				

func create_cube(color = Color(1,1,1), size = Vector3(0.2,0.2,0.2)):
	var cube_mesh = CubeMesh.new()
	var cube_material = SpatialMaterial.new()
	var cube_node = MeshInstance.new()
	
	cube_mesh.size = size

	# set cube material properties
	cube_material.albedo_color = color
	cube_node.material_override = cube_material

	# set cube mesh for cube node
	cube_node.mesh = cube_mesh
	
	return cube_node
