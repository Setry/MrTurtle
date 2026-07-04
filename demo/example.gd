extends GDExample


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_is_remote())
	print(get_is_board())
	self.board_received.connect(func(data: Vector4i) -> void:
		print(data)
	)

	self.ir_received.connect(func(points: Array) -> void:
		print(points)
	)
