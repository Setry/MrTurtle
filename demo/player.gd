extends CharacterBody3D


const SPEED = 2.0
const ACCEL_SPEED = 0.1
const MAX_TURN_SPEED = 0.05
const TURN_SPEED = 0.005
const DRAG = 0.99
const JUMP_VELOCITY = 4.5

var board: GDExample
var remote: GDExample

var board_values: Vector4i

var angular_speed: float

var aim_pos: Vector2
var aim_rot: float

var board_calibration: Vector4i

var t: float

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
		return

	board.board_received.connect(func(data: Vector4i) -> void:
		board_values = data
	)

	remote.ir_received.connect(func(points: Array) -> void:
		# FIXME: very jank
		#print(points)

		var reduced_points = []
		for p in points:
			if p.x == 0 and p.y == 0:
				continue

			var found = false
			for r in reduced_points:
				if (r - p).length() < 0.01:
					found = true
					break

			if found:
				continue

			reduced_points.push_back(p)

		if len(reduced_points) != 2:
			#aim_pos = Vector2(0.5, 0.5)
			return

		var avg = Vector2()
		for p in reduced_points:
			avg += p
		avg /= len(reduced_points)

		var line_len_x = abs(reduced_points[0].x - reduced_points[1].x)
		var line_len_y = abs(reduced_points[0].y - reduced_points[1].y)

		#print(line_len_x, "/", line_len_y)

		var r_x = remap(avg.x, 0.5 * line_len_x, 1 - 0.5 * line_len_x, 0, 1)
		var r_y = remap(avg.y, 0.5 * line_len_y, 1 - 0.5 * line_len_y, 0, 1)

		var angle = atan2(reduced_points[0].y - reduced_points[1].y, reduced_points[0].x - reduced_points[1].x)
		%Ui/Cursor.rotation = angle

		aim_pos = Vector2(1 - r_x, r_y)
		aim_rot = angle
		#print(reduced_points, avg, aim_pos)
	)

	remote.key_received.connect(func(key: String, pressed: bool) -> void:
		print(key, ": ", pressed)
		if key == "b" and pressed:
			shoot()
	)

func _physics_process(delta: float) -> void:
	t += delta
	if t < 3:
		board_calibration = board_values
		print("Calibrating: ", board_calibration)

	# Add the gravity.

	if position.y > 0:
		velocity += get_gravity() * delta
	else:
		velocity.y += -position.y * 0.2 - velocity.y * 0.05

	#print(board_values)

	var board_v = board_values - board_calibration
	#print(board_v)
	var left_sum = max(1, board_v.z + board_v.w)
	var right_sum = max(1, board_v.x + board_v.y)

	var up_sum = max(1, board_v.x + board_v.z)
	var down_sum = max(1, board_v.y + board_v.w)

	# Normalize to -1..1
	var lr = (float(right_sum) / (left_sum + right_sum) - 0.5) * 2
	#print("L/R: ", lr)

	var ud = (float(up_sum) / (up_sum + down_sum) - 0.33) * 2
	#print("U/D: ", ud)

	if left_sum + right_sum < 200:
		lr = 0
		ud = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_axis("ui_up", "ui_down")
	#var lr_dir := Input.get_axis("ui_left", "ui_right")

	$Body.rotation.x = move_toward($Body.rotation.x, -ud * 0.5 + 0.5, 0.05)
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

func shoot() -> void:
	var bub_packed = preload("res://bubble.tscn")
	var bub: RigidBody3D = bub_packed.instantiate()

	var screen_position = aim_pos * get_viewport().get_visible_rect().size
	print(get_viewport().get_screen_transform().affine_inverse() * screen_position)

	var pos = %Camera.project_position(screen_position, 5)

	var dir = pos - position
	bub.position = position + dir.normalized() * 2
	bub.linear_velocity = dir.normalized() * 10 + velocity

	get_parent().add_child(bub)
	pass
