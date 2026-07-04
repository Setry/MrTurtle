extends CharacterBody3D


const SPEED = 10.0
const ACCEL_SPEED = 0.1
const MAX_TURN_SPEED = 0.1
const TURN_SPEED = 0.001
const DRAG = 0.99
const JUMP_VELOCITY = 4.5

var board: GDExample
var remote: GDExample

var board_values: Vector4i

var angular_speed: float

var aim_pos: Vector2

func _ready() -> void:
	print(GDExample.get_devices())

	for dev in GDExample.get_devices():
		var node: GDExample = GDExample.new()
		add_child(node)

		print(node)

		node.connect_to_device(dev)

		if node.get_is_board():
			board = node

		if node.get_is_remote():
			remote = node

	if not remote or not board:
		print("Something is missing")
		get_tree().quit(1)

	board.board_received.connect(func(data: Vector4i) -> void:
		board_values = data
	)

	remote.ir_received.connect(func(points: Array) -> void:
		# FIXME: very jank
		if len(points) == 0:
			aim_pos = Vector2(0.5, 0.5)
			return

		var avg = Vector2()
		for p in points:
			avg += p
		avg /= len(points)
		aim_pos = avg
	)

func _physics_process(delta: float) -> void:
	# Add the gravity.

	if position.y > 0:
		velocity += get_gravity() * delta
	else:
		velocity.y += -position.y * 0.2 - velocity.y * 0.05

	#print(board_values)

	var left_sum = max(1, board_values.z + board_values.w)
	var right_sum = max(1, board_values.x + board_values.y)

	var up_sum = max(1, board_values.x + board_values.z)
	var down_sum = max(1, board_values.y + board_values.w)

	# Normalize to -1..1
	var lr = (float(right_sum) / (left_sum + right_sum) - 0.5) * 2
	#print("L/R: ", lr)

	var ud = (float(up_sum) / (up_sum + down_sum) - 0.25) * 2
	#print("U/D: ", ud)

	if left_sum + right_sum < 2000:
		lr = 0
		ud = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_axis("ui_up", "ui_down")
	#var lr_dir := Input.get_axis("ui_left", "ui_right")

	$Body.rotation.x = move_toward($Body.rotation.x, -ud, 0.05)
	$Body.rotation.z = move_toward($Body.rotation.z, -lr, 0.05)

	if ud < 0:
		ud *= 0.75
	else:
		ud *= 1.5
	var direction: Vector3 = (transform.basis * Vector3(0, 0, -ud)).normalized() * abs(ud)
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL_SPEED)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL_SPEED)

	velocity.x *= DRAG
	velocity.z *= DRAG

	var dir = sign((transform.basis.inverse() * velocity).z)
	#print("Speed = ", Vector2(velocity.x, velocity.z).length())

	if abs(lr) > 0.1:
		angular_speed = move_toward(angular_speed, dir * lr * MAX_TURN_SPEED, abs(lr) * Vector2(velocity.x, velocity.z).length() * TURN_SPEED)

	angular_speed *= DRAG

	rotation.y += angular_speed

	move_and_slide()

func _process(_delta: float) -> void:
	%Ui/Cursor.position = %Ui/Cursor.position.move_toward(aim_pos * get_viewport().get_visible_rect().size, 50)
