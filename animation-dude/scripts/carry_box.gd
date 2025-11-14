extends RigidBody2D

@onready var collision = get_node("CollisionShape2D")

var holder: Node2D = null

func hold(character: Node2D):
	holder = character
	collision.disabled = true
	freeze = true

func release(throw_force: Vector2 = Vector2.ZERO):
	holder = null
	collision.disabled = false
	freeze = false
	if throw_force != Vector2.ZERO:
		apply_central_impulse(throw_force)
