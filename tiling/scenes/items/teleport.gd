extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var destination: String = ""
var entered = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		entered = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		entered = false
		sprite.play("default")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and entered:
		sprite.play("open")
		if destination:
			GameWorld._load_level(destination)
