extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800
const STUN_TIME = 0.5
const PICKUP_DISTANCE = 40
const THROW_FORCE = 400
enum State {IDLE, RUN, JUMP, DOUBLE_JUMP, STUN}

@onready var animation = get_node('AnimationPlayer')
@onready var sprite = get_node('Sprite2D')

var current_state: State = State.IDLE
var double_jump: bool = false
var stun_delay = 0
var is_held: bool = false
var carry_box:RigidBody2D = null
var interactive = null

signal hit
signal hit_slime
signal hit_slime2

func set_state(new_state: State):
	current_state = new_state

func _ready() -> void:
	set_state(State.IDLE)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and is_held:
		var direction = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT
		direction.y = -0.5
		carry_box.release(direction* THROW_FORCE)
		carry_box = null
		is_held = false
		
	elif event.is_action_pressed("pickup") and not is_held:
		var state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		shape.radius = PICKUP_DISTANCE
		query.shape = shape
		query.collide_with_areas = true
		query.transform = Transform2D(0, global_position)
		query.exclude = [self]
		var results = state.intersect_shape(query)
		
		for result in results:
			if "CarryBox" == result.collider.name:
				carry_box = result.collider
				carry_box.hold(self)
				is_held = true
				
			if result.collider is Area2D:
				interactive = result.collider
			
	elif event.is_action_released("pickup"):
		if interactive and interactive.has_method("activate"):
			interactive.activate()
			interactive = null
		
func handle_held(delta):
	if carry_box:
		carry_box.global_transform.origin = (global_position + Vector2(0, -50))

func handle_idle(delta: float):
	animation.play("idle")
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 80)
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		double_jump = true
		set_state(State.JUMP)
		
func handle_run(delta):
	animation.play("run")
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		set_state(State.IDLE)
		#velocity.x = 0
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		double_jump = true
		set_state(State.JUMP)
		
func handle_jump(delta):
	animation.play("jump")
	
	if Input.is_action_just_pressed("jump") and double_jump:
		velocity.y = JUMP_VELOCITY
		double_jump = false
		set_state(State.DOUBLE_JUMP)
		
	var direction = Input.get_axis("left", "right")
	velocity.x = lerp(velocity.x, direction * SPEED, 0.2)
		
func handle_double_jump(delta):
	animation.play("double_jump")
	
	if velocity.y > 0:
		set_state(State.JUMP)
	
	var direction = Input.get_axis("left", "right")
	velocity.x = lerp(velocity.x, direction * SPEED, 0.2)
		
func update_flip():
	sprite.flip_h = velocity.x < 0

func handle_collisions(delta):
	var collision_count = get_slide_collision_count()
	var platform = null
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if "JumpBox" in collider.name:
			var force = 4
			if normal.y < 0:
				force = 2
			hit.emit()
			velocity = normal * SPEED * 2
			set_state(State.JUMP)
			
		if "Wall" in collider.name:
			if abs(normal.x) > 0.8:
				velocity = normal * SPEED
				stun_delay = STUN_TIME
				set_state(State.STUN)
				
		if "Bridge" in collider.name:
			platform = collider
			
		if collider.name == "SlimeBody" or collider.name == "SlimeBody2":
			var force = 2
			if normal.y < 0:
				force = 1
				
			if collider.name == "SlimeBody":
				hit_slime.emit()
			elif collider.name == "SlimeBody2":
				hit_slime2.emit()
		
			velocity = normal * SPEED * 2
			set_state(State.JUMP)
			
		if "Rock" in collider.name:
			collider.apply_impulse(-normal * 10)	
			
	if Input.is_action_just_pressed("down") and platform != null:
		var collision = platform.get_child(0)
		collision.disabled = true
		await get_tree().create_timer(0.1).timeout
		collision.disabled = false
				
func handle_stun(delta):
	if stun_delay <= 0:
		set_state(State.IDLE)
	stun_delay -= delta
				

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.RUN:
			update_flip()
			handle_run(delta)
		State.JUMP:
			handle_jump(delta)
		State.DOUBLE_JUMP:
			handle_double_jump(delta)
		State.STUN:
			handle_stun(delta)
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	handle_collisions(delta)
	handle_held(delta)
	move_and_slide()
	
	if is_on_floor() and current_state in [State.JUMP, State.DOUBLE_JUMP]:
		if abs(velocity.x) > 0:
			set_state(State.RUN)
		else:
			set_state(State.IDLE)
