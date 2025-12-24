extends RigidBody3D
class_name DieObject

@onready var mesh: MeshInstance3D = $Mesh

const MOVEMENT_THRESHOLD = 0.01

var current_number
var rolling: bool = false
var locked: bool = false
var selected: bool = false

func _ready() -> void:
	current_number = get_top_face()

func _physics_process(delta: float) -> void:
	if rolling:
		if linear_velocity.length() < MOVEMENT_THRESHOLD:
			current_number = get_top_face()
			rolling = false

func get_top_face() -> int:
	var up = Vector3.UP

	var faces = {
		1: Vector3.UP,
		6: Vector3.DOWN,
		5: Vector3.FORWARD,
		2: Vector3.BACK,
		3: Vector3.RIGHT,
		4: Vector3.LEFT
	}

	var best_face = -1
	var best_dot = -1.0

	for face in faces.keys():
		var world_dir = global_transform.basis * faces[face]
		var dot = world_dir.dot(up)

		if dot > best_dot:
			best_dot = dot
			best_face = face

	return best_face

func lock() -> void:
	locked = true
	selected = false
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_color = Color(1, 0, 0)

func unlock() -> void:
	locked = false
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_color = Color(1, 1, 1)

func reset() -> void:
	unlock()
	unselect()

func select() -> void:
	selected = true
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_color = Color(0, 1, 1)

func unselect() -> void:
	selected = false
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_color = Color(1, 1, 1)
