extends Node2D

signal damaged

var speed: float = 0
var max_speed: float = 500
var speed_step: float = 5

@onready var shield = get_node("ShipArea/ShipSprite/ShieldSprite")
@onready var flame = get_node("ShipArea/ShipSprite/Flame")

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("ui_left"):
		rotation -= 0.1
	if Input.is_action_pressed("ui_right"):
		rotation += 0.1
	if Input.is_action_pressed("ui_up"):
		speed += speed_step
		if speed >= max_speed:
			speed = max_speed
	if Input.is_action_pressed("ui_down"):
		speed -= speed_step
		if speed <= 0:
			speed = 0
	var x = 0.1 * cos(rotation + PI/2)
	var y = 0.1 * sin(rotation + PI/2)
	position += speed * delta * Vector2(x, y).normalized()
	
	flame.visible = speed > 10
	flame.scale = Vector2(1.0, lerp(1, 3, clamp(speed / max_speed, 0.0, 3.0)))

func damage() -> void:
	shield.visible = false	

func _on_ship_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		damaged.emit()
