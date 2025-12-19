extends CharacterBody2D

enum State {IDLE, WALK}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_state: State = State.IDLE
var speed: float = 200.

func handle_idle(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	animation_player.play("RESET")
	if direction != Vector2.ZERO:
		current_state = State.WALK
		print("walk")
	
func handle_walk(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if(Input.is_action_pressed("right") || Input.is_action_pressed("left")):
		direction.y = 0
	if(Input.is_action_pressed("up") || Input.is_action_pressed("down")):
		direction.x = 0
	if direction == Vector2.ZERO:
		current_state = State.IDLE
		print("idle")
	direction = direction.normalized()
	
	if direction == Vector2.DOWN:
		animation_player.play("down")
	if direction == Vector2.UP:
		animation_player.play("up")
	if direction == Vector2.RIGHT:
		animation_player.play("right")
	if direction == Vector2.LEFT:
		animation_player.play("left")
	
	velocity = direction * speed
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.WALK:
			handle_walk(delta)
			
	move_and_slide()
#func _ready() -> void:
