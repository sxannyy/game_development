extends Area2D

var angular_velocity: float = 1.0
var velocity: Vector2i = Vector2i(0, 0)
var rng = RandomNumberGenerator.new()
@onready var window = get_parent().get_window()
@onready var size = get_node("AsteroidSprite").texture.get_size()

func _ready() -> void:
	velocity = Vector2i(rng.randi_range(-100, 100),
						rng.randi_range(-100, 100))
	angular_velocity = rng.randf_range(1, 5)

func _process(delta: float) -> void:
	position += velocity * delta
	rotation += angular_velocity * delta
	
	if global_position.x > window.size.x - size.x / 2:
		velocity.x *= -1
	elif global_position.y > window.size.y - size.y / 2:
		velocity.y *= -1
	elif global_position.x < size.x / 2:
		velocity.x *= -1
	elif global_position.y < size.y / 2:
		velocity.y *= -1
