extends Node2D

@onready var marker: Marker2D = $Marker2D

func _ready() -> void:
	GameWorld.apple_found = true

func _place_character(character: CharacterBody2D):
	character.global_position = marker.global_position
