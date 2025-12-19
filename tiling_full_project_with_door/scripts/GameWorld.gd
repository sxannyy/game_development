extends Node

@onready var levels = {
	"meadow": "res://scenes/world/meadow.tscn",
	"random_forest": "res://scenes/world/forest.tscn",
	"forest": "res://scenes/world/forest.tscn",
	"maze": "res://scenes/world/maze.tscn",
}

var world: Node2D = null
var player: CharacterBody2D = null
var current_level: Node2D = null

var apple_found: bool = false

func _set_world(node: Node2D):
	world = node

func _set_player(character: CharacterBody2D):
	player = character
	
func _load_level(name: String):
	if current_level:
		world.remove_child(current_level)
		current_level.queue_free()
	var node: Node2D = load(levels[name]).instantiate()
	current_level = node
	if world:
		world.add_child(current_level)
	if player:
		current_level.call_deferred("_place_character", player)
		
var _teleport_lock_frames: int = 0

func lock_teleports(frames: int = 2) -> void:
	_teleport_lock_frames = max(_teleport_lock_frames, frames)

func teleports_locked() -> bool:
	return _teleport_lock_frames > 0

func _process(delta: float) -> void:
	if _teleport_lock_frames > 0:
		_teleport_lock_frames -= 1
