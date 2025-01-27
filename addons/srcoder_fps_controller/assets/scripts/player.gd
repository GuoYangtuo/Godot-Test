extends CharacterBody3D

## The movement speed in m/s. Default is 5.
@export_range(1.0, 30.0) var speed: float = 5.0
## The Jump Velocity in m/s - default to 6.0
@export_range(2.0, 10.0) var jump_velocity: float = 6.0

## Mouse sensitivity for looking around. Default is 3.0
@export_range(1.0, 5.0) var mouse_sensitivity = 3.0
var mouse_motion: Vector2 = Vector2.ZERO
var pitch = 0.0

## The amount of acceleration on the ground - less feels floaty, more is snappy - Default is 4
@export_range(1.0, 10.0) var ground_acceleration: float = 4.0
## The amount of acceleration when in the air. less feels more floaty more is more snappy. - Default is 0.5
@export_range(0.0, 5.0) var air_acceleration: float = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export_range(5.0, 25.0) var gravity: float = 15.0

# The camera pivot for head pitch movement
@onready var camera_pivot: Node3D = $CameraPivot

# Variables for dragging objects
var dragging_object: Node3D = null
var initial_offset: Vector3 = Vector3.ZERO

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	var target_velocity := Vector3.ZERO
	if direction:
		target_velocity = direction

	# Apply velocity with lerp based on whether on ground or in air
	if is_on_floor():
		velocity.x = move_toward(velocity.x, target_velocity.x * speed, speed * ground_acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z * speed, speed * ground_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, target_velocity.x * speed, speed * air_acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z * speed, speed * air_acceleration * delta)

	# Move the player based on velocity
	move_and_slide()

	# Rotate the player and camera pivot based on mouse movement
	rotate_y(-mouse_motion.x * mouse_sensitivity / 1000)
	pitch -= mouse_motion.y * mouse_sensitivity / 1000
	pitch = clamp(pitch, -1.35, 1.35)
	camera_pivot.rotation.x = pitch

	# Reset mouse motion
	mouse_motion = Vector2.ZERO

	# If dragging an object, update its position
	if dragging_object:
		var raycast_result = cast_ray_from_camera()
		if raycast_result:
			dragging_object.global_position = raycast_result.position + initial_offset
		else:
			release_object()

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pick_object()
		else:
			release_object()

func cast_ray_from_camera() -> Dictionary:
	var camera = camera_pivot.get_child(0) as Camera3D
	var ray_origin = camera.global_transform.origin
	var ray_direction = camera.global_transform.basis * Vector3(0, 0, -1)
	var ray_length = 100.0  # Adjust the length as needed

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * ray_length)
	query.collide_with_areas = true  # Enable collision with Area3D if needed[^2^]
	var result = space_state.intersect_ray(query)

	return result

func pick_object():
	var raycast_result = cast_ray_from_camera()
	if raycast_result and raycast_result.collider != self:
		dragging_object = raycast_result.collider
		initial_offset = dragging_object.global_position - raycast_result.position

func release_object():
	if dragging_object:
		dragging_object = null

var body_blood = {
	"头":10,"身体":100, "手臂":100, "腿":100
}

func 攻击(攻击位置: String, 攻击强度: int):
	body_blood[攻击位置] -= 攻击强度
	if (body_blood[攻击位置] <= 0):
		pass

var operatable_dict = {
	"攻击(攻击位置: String, 攻击强度: int)":攻击
}
