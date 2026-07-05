extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(pop)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if position.y < 0:
	#	linear_velocity.y += -position.y
	pass

func pop(node: Node) -> void:
	if node is Debris:
		node.queue_free()
		queue_free()
