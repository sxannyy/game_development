extends Node2D

@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")

@onready var slime = get_node("Slime")
@onready var slime_animation = get_node("Slime/AnimationPlayer")

@onready var slime2 = get_node("Slime2")
@onready var slime_animation2 = get_node("Slime2/AnimationPlayer")

@onready var rock = get_node("Rock")
@onready var rock_animation = get_node("Rock/AnimationPlayer")

@onready var fan = get_node("Fan")
@onready var fan_animation = get_node("Fan/AnimationPlayer")

@onready var staticbox_animation = get_node("Static/JumpBox/AnimationPlayer")
@onready var dude = get_node("PhysicsDude")

func _ready() -> void:
	audio_player.stream = load("res://assets/audio/background.ogg")
	audio_player.volume_db = linear_to_db(8.5)
	audio_player.play()
	
	slime_animation.play("appear_and_pulse")
	slime_animation.animation_finished.connect(_on_slime_animation_finished)

	slime_animation2.play("idle")
	slime_animation2.animation_finished.connect(_on_slime2_animation_finished)
	
	rock_animation.play("idle")
	
	fan_animation.play("RESET")

	dude.hit.connect(_on_hit_static_box)
	dude.hit_slime.connect(_on_hit_slime)
	dude.hit_slime2.connect(_on_hit_slime2)

func _on_slime_animation_finished(name):
	if name == "appear_and_pulse":
		slime_animation.play("idle")
	elif name == "idle_texture":
		slime_animation.play("idle")

func _on_slime2_animation_finished(name):
	if name == "idle_texture":
		slime_animation2.play("idle")

func _on_hit_static_box():
	staticbox_animation.play("hit")

func _on_hit_slime():
	slime_animation.play("idle_texture")

func _on_hit_slime2():
	slime_animation2.play("idle_texture")
