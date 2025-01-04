extends CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 1500.0  # Increased acceleration for more responsive movement
const FRICTION = 2000.0  # Increased friction for smoother deceleration

@onready var sprite = $AnimatedSprite2D
@onready var debug_text = $"../CanvasLayer/DebugText"

const ROLL_SPEED = 300
const ROLL_DURATION = 0.5 # Duration of the dodge roll in seconds

var rolling = false
var roll_timer = 0
var last_run_pressed = false

func player_movement(input, delta):
	var target_velocity = input * SPEED
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, delta * ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)

func update_debug_text():
	if debug_text != null:
		debug_text.text = "Speed: " + str(velocity.length())
	else:
		print("Debug text node is not properly initialized!")

func _process(delta):
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Normalize the direction vector if it's not zero
	if move_direction.length_squared() > 0:
		move_direction = move_direction.normalized()

func _physics_process(delta):
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player_movement(input, delta)
	update_debug_text()
	move_and_slide()
