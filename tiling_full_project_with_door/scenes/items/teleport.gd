extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var destination: String = ""
@export var requires_apple: bool = true
var entered = false
var closed: bool = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		entered = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		entered = false
		if not closed:
			sprite.play("default")
			closed = true

func _ready() -> void:
	sprite.play("default")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") \
			and entered \
			and (not requires_apple or GameWorld.apple_found) \
			and not GameWorld.teleports_locked():
		sprite.play("open")
		closed = false
		if destination:
			GameWorld.lock_teleports(2)
			GameWorld._load_level(destination)
