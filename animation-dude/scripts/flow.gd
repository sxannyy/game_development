extends Area2D

@export var force: Vector2 = Vector2(0, -20)

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		
		if body is CharacterBody2D:
			body.velocity += force
			
		if body is RigidBody2D:
			body.apply_impulse(force)
