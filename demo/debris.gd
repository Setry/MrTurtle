class_name Debris
extends RigidBody3D

var debris: Array[PackedScene] = [
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/platform.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/platform-planks.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/barrel.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/chest.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/crate-bottles.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/crate.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/bottle.fbx"),
	preload("res://Assets/kenney_pirate-kit/Models/FBX format/bottle-large.fbx"),
]

func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var d := debris[rng.randi_range(0, len(debris) - 1)]
	add_child(d.instantiate())

	self.body_entered.connect(collide)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.y > 0:
		linear_velocity += get_gravity() * delta
	else:
		linear_velocity.y += -position.y * 0.2 - linear_velocity.y * 0.05

func collide(node: Node) -> void:
	if node.name == "Player":
		print("U DED")
		get_tree().quit(1)
