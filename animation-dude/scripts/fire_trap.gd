extends Node2D

@export var active_time: float = 1.5
@export var knockback_force: float = 600

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Area2D
@onready var sparks: GPUParticles2D = $Area2D/GPUParticles2D
@onready var fire_sound: AudioStreamPlayer2D = $FirePlayer
@onready var life_timer: Timer = $LifeTimer

var is_active: bool = false

func _ready() -> void:
	set_off()
	
	hitbox.body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(_on_life_timer_timeout)

func set_off() -> void:
	is_active = false
	if animation.has_animation("off"):
		animation.play("off")
	sparks.emitting = false
	fire_sound.stop()
	hitbox.monitoring = true

func activate() -> void:
	is_active = true
	if animation.has_animation("burn"):
		animation.play("burn")
	sparks.emitting = true
	fire_sound.play()
	
	life_timer.start(active_time)

func _on_body_entered(body: Node) -> void:
	if is_active:
		return
	
	if not (body is CharacterBody2D):
		return
	
	activate()
	
	_push_body(body as CharacterBody2D)

func _push_body(body: CharacterBody2D) -> void:
	var dir := (body.global_position - global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	
	if body.has_method("apply_fire_trap_knockback"):
		body.apply_fire_trap_knockback(global_position, knockback_force)
	elif "velocity" in body:
		body.velocity = dir * knockback_force
		
func _on_life_timer_timeout() -> void:
	set_off()
