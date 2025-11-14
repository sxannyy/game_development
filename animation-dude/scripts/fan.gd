extends Node2D

@onready var animation = $AnimationPlayer
@onready var area = get_node("Area2D/CollisionShape2D")
@onready var particles = get_node("Area2D/GPUParticles2D")
@onready var audio_fan: AudioStreamPlayer2D = get_node("FanPlayer")

func turn_on():
	animation.play("idle")
	area.disabled = false
	particles.emitting = true
	audio_fan.play()
	
func turn_off():
	animation.play("RESET")
	area.disabled = true
	particles.emitting = false
	audio_fan.stop()
