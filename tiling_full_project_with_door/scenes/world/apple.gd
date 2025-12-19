extends Node2D

var entered = false
var closed = true


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is CharacterBody2D:
		entered=true
	


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is CharacterBody2D:
		entered=false
	if !closed:
		closed=true
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and entered:
		GameWorld.apple_found=true
		queue_free()
