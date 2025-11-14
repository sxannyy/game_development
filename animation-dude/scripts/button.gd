extends Area2D

@export var node_path: NodePath
var node: Node 
var active: bool = false
@onready var sprite: Sprite2D = get_node("Sprite2D")

func _ready() -> void:
	node = get_node(node_path)

func activate():
	if node:
		if node.has_method("turn_on") and not active:
			node.turn_on()
			active = true
			sprite.texture = load("res://assets/assets/off_button.png")
			sprite.scale.x = 2
			sprite.scale.y = 2
		elif node.has_method("turn_off") and active:
			node.turn_off()
			active = false
			sprite.texture = load("res://assets/assets/on_button.png")
			sprite.scale.x = 1.1
			sprite.scale.y = 1.1
