extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var board: GDExample
var remote: GDExample

var board_values: Vector4i

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
		print(points)
	)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	#print(board_values)

	var left_sum = max(1, board_values.z + board_values.w)
	var right_sum = max(1, board_values.x + board_values.y)

	var up_sum = max(1, board_values.x + board_values.z)
	var down_sum = max(1, board_values.y + board_values.w)

	if left_sum + right_sum < 1000:
		return

	print(left_sum, " ", right_sum)

	# Normalize to -1..1
	var lr = (float(left_sum) / (left_sum + right_sum) - 0.5) * 2
	print(lr)

	var ud = (float(up_sum) / (up_sum + down_sum) - 0.5) * 2
	print(ud)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_axis("ui_up", "ui_down")
	#var lr_dir := Input.get_axis("ui_left", "ui_right")
	var direction := (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	rotation.y += lr * 0.05

	move_and_slide()
