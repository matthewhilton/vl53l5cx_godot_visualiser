extends Spatial

onready var serialNode = $Serial

onready var sensorA = $"Sensor A"
onready var sensorB = $"Sensor B"

var fov_deg = 43
var grid_size = 4

func _process(delta):
	var result = JSON.parse(serialNode.data)
	
	if(result.error == OK):
		process_sensor_data(result.result.a, sensorA, Color(0,1,0))
		process_sensor_data(result.result.b, sensorB, Color(0,0,1))
		

func process_sensor_data(dataFromSensor, sensorNode, color):
	var distances = dataFromSensor.distance
	var status = dataFromSensor.status
	
	assert(distances.size() == grid_size * grid_size)
	
	# Drop all visualiser children.
	for node in sensorNode.get_children():
		# Skip the sensor body itself
		if node is KinematicBody:
			continue
			
		sensorNode.remove_child(node)
		node.queue_free()
	
	for row in range(0, grid_size):
		for col in range(0, grid_size):
			
			var this_distance = distances[row * grid_size + col] / 50
			var node = create_cube(color, Vector3(1,1,1))
			node.transform = sensorNode.transform
			
			sensorNode.add_child(node)
			
			var half_fov = fov_deg / 2
			var fov_per_step = fov_deg / grid_size
			
			# Left/right angle, based on col
			var angle_z = (-1 * half_fov) + (col * fov_per_step)
			
			# Up/down angle, based on row.
			var angle_x = (-1 * half_fov) + (row * fov_per_step)
			
			node.global_rotate(node.global_transform.basis.z, deg2rad(angle_z))
			node.global_rotate(node.global_transform.basis.x, deg2rad(angle_x))
			
			var movement = node.global_transform.basis.y * this_distance
			node.global_translate(movement)

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
