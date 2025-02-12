extends CharacterBody2D

# Bewegungskonstanten
const SPEED = 130.0
const ACCELERATION = 1500.0
const FRICTION = 2000.0
var health = 5.0

# I-Frames
var is_invincible: bool = false  # Ob der Spieler momentan in I-Frames ist
@onready var invincibility_timer = $Timer

# Waffen-Variablen
@export var weapon: Resource  # Aktuelle Waffe
var can_shoot: bool = true  # Cooldown-Management

@onready var sprite = $AnimatedSprite2D
#@onready var debug_text = $"../CanvasLayer/DebugText"
#@onready var health_text = $"../CanvasLayer/HeatlhText"
@onready var health_ui = $"../CanvasLayer/HeartContainers"

@export var default_weapon: Resource  # Aktuelle Waffe
var weapon_reset_timer: Timer

func _ready():
	weapon = default_weapon
	weapon_reset_timer = Timer.new()
	weapon_reset_timer.timeout.connect(_reset_weapon)
	add_child(weapon_reset_timer)

func set_temporary_weapon(new_weapon: Resource, duration: float):
	weapon = new_weapon
	weapon_reset_timer.start(duration)

func _reset_weapon():
	weapon = default_weapon

func _physics_process(delta):
	# Debug-Text aktualisieren (falls vorhanden)
	#update_debug_text()
	
	# Bewegung
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	handle_movement(move_direction, delta)
	move_and_slide()
	
	# Schießen
	var shoot_direction = get_shoot_direction()
	if shoot_direction != Vector2.ZERO and can_shoot:
		shoot(shoot_direction)

func handle_movement(input: Vector2, delta: float) -> void:
	var target_velocity = input * SPEED
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
		update_animation(input)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		stop_animation()

func update_animation(direction: Vector2) -> void:
	if sprite:
		# Beispiel: Animationen nach Richtung wechseln
		if abs(direction.x) > abs(direction.y):
			sprite.play("anim_left")
			sprite.flip_h = direction.x < 0
		else:
			sprite.play("anim_down" if direction.y > 0 else "anim_up")
	else:
		print("Sprite node not initialized!")

func stop_animation() -> void:
	if sprite:
		sprite.stop()

#func update_debug_text() -> void:
	#if debug_text != null:
		#debug_text.text = "Speed: " + str(velocity.length())
		#health_text.text = "Health:" + str(health)
	#else:
		#print("Debug text node is not properly initialized!")

func shoot(direction: Vector2) -> void:
	if weapon and weapon.projectile_scene:
		can_shoot = false

		# Erstelle Projektile basierend auf Waffe
		for i in range(weapon.num_projectiles):
			var angle_offset = weapon.spread_angle * (i - (weapon.num_projectiles - 1) / 2)
			var final_direction = direction.rotated(deg_to_rad(angle_offset)).normalized()

			var projectile = weapon.projectile_scene.instantiate()
			projectile.global_position = global_position
			projectile.direction = final_direction
			projectile.speed = weapon.projectile_speed
			get_parent().add_child(projectile)

		# Cooldown setzen
		await get_tree().create_timer(weapon.cooldown).timeout
		can_shoot = true

func get_shoot_direction() -> Vector2:
	# Eingaben der Schieß-Tasten auslesen (Pfeiltasten)
	var shoot_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return shoot_direction.normalized()
	
	
func on_hit(amount: int):
	take_damage(amount)

func take_damage(amount: int):

	if not is_invincible:
		health -= amount  # Schaden hinzufügen
		# Im Charakter-Skript
		health_ui.update_hearts(health)
		if health <= 0:
			die()  # Spieler stirbt, wenn die Lebenspunkte auf 0 sind


			
func start_invincibility(duration: float):
	is_invincible = true  # Setze den Spieler in den I-Frames Zustand
	invincibility_timer.start(duration)  # Starte den Timer mit der Dauer der I-Frames
	sprite.modulate = Color(1, 0, 0)

# Wenn die I-Frames abgelaufen sind
func _on_invincibility_timeout():
	is_invincible = false  # Setze den Spieler zurück in den normalen Zustand
	sprite.modulate = Color(1, 1, 1)  # Setze die Farbe des Spielers zurück

func die():
	# Der Spieler stirbt, wenn die Lebenspunkte auf 0 gehen
	print("DIE DIE DIE DIE DIE DIE")
	get_tree().change_scene_to_file("res://scenes/stone.tscn")
