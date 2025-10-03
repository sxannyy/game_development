extends Node2D

var acceleration: Vector2 = Vector2(0, 0)
var velocity: Vector2 = Vector2(0, 0)
var max_force: float = 700
var max_speed: float = 500
var max_distance: float = 350
@onready var window = get_parent().get_window()

func apply_force(force: Vector2):
	acceleration = force

func seek(target: Vector2):
	var direction = target - global_position
	if direction.length() > max_distance:
		return
	var desired_velocity = direction.normalized() * max_speed
	var k = remap(direction.length(), 0, max_distance / 2, 0, 1)
	var steering = k * (desired_velocity - velocity)
	steering = steering.limit_length(max_force)
	apply_force(steering)

func flee(target: Vector2):
	var direction = global_position - target
	if direction.length() > max_distance / 3:
		return
	var desired_velocity = direction.normalized() * max_speed
	var steering = (desired_velocity - velocity)
	steering = steering.limit_length(max_force)
	apply_force(steering)

func update(delta: float):
	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)
	global_position += velocity * delta
	acceleration *= 0
	rotation = velocity.angle() - PI / 2
	
func _process(delta: float) -> void:
	update(delta)
	
	if global_position.x > window.size.x:
		global_position.x = 0
	elif global_position.y > window.size.y:
		global_position.y = 0
	elif global_position.x < 0:
		global_position.x = window.size.x
	elif global_position.y < 0:
		global_position.y = window.size.y
