extends RigidBody3D

var t: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(pop)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	if t >= 10:
		queue_free()

	#if position.y < 0:
	#	linear_velocity.y += -position.y
	pass

func pop(node: Node) -> void:
	if node is Debris:
		node.queue_free()
		queue_free()
		get_parent().find_child("Player").hit()
