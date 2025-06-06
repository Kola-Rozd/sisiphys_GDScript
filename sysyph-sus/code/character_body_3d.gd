extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5

var down_direction : Vector3 = Vector3.DOWN
var mouse_sensitivity = 0.1
@onready var camera_pivot = $Neck

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		$Neck.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))



func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func get_vector_to_closest_target() -> Vector3:
	var closest_vector := Vector3.ZERO
	var closest_distance := 1000
	var player_pos := global_transform.origin
	var to_target : Vector3
	for target in get_tree().get_nodes_in_group("core"):
		if not target is Node3D:
			continue  # Skip non-3D nodes
		to_target = target.global_transform.origin - player_pos
		var distance := to_target.length()
		if distance < closest_distance:
			closest_distance = distance
			closest_vector = to_target
	return closest_vector

func _physics_process(delta: float) -> void:
	down_direction = -get_vector_to_closest_target().normalized()
	
	rotation.x = down_direction.z
	rotation.z = -down_direction.x
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * down_direction
		

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor() or is_on_wall():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
