extends Node3D

var t: float = -5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	if t > 2:
		var debris: RigidBody3D = preload("res://debris.tscn").instantiate()

		var spawn_angle = rng.randf_range(0, 2*PI)
		var offset = Vector2.from_angle(spawn_angle) * 10
		var pos = %Player.position + Vector3(offset.x, 0, offset.y)
		debris.position = pos
		debris.linear_velocity = (%Player.position - pos).normalized() * 2

		add_child(debris)
		t = 0

	pass
