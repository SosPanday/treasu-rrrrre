extends CharacterBody2D

@export var enemy_data: Resource  # EnemyResource, die alle Attribute speichert
var current_health: int = 0  # Aktuelle Leben des Gegners
var current_state: State = State.ALIVE  # Der aktuelle Zustand des Gegners (ALIVE oder DEAD)
var last_state = global_position
enum State { ALIVE, DEAD, ATTACK }
var attack_timer: Timer  # Timer für Angriffscooldown

@onready var sprite = $AnimatedSprite2D
@onready var respawn_timer = $Timer
@onready var collision = $CollisionShape2D  # Hier könnte das Kollisionsobjekt sein

@onready var detection_area = $DetectionArea
@onready var shoot_timer = Timer.new()

@export var shoot_cooldown: float = 1  # Zeit, die das Schiff zum Zielen braucht
@export var projectile_scene: PackedScene  # Projektil-Szene

var target_player = null  # Speichert den Spieler, wenn er im Sichtbereich ist


func _ready():
	if enemy_data:
		var data = enemy_data
		sprite.frames = data.sprite
		current_health = data.health
		velocity = Vector2.ZERO
		
		# Attacken-Timer erstellen
		attack_timer = Timer.new()
		attack_timer.wait_time = data.attack_cooldown
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_cooldown)
		add_child(attack_timer)

		if enemy_data.has_death_state:
			respawn_timer.wait_time = data.respawn_time
			respawn_timer.one_shot = true



func _physics_process(delta):
	var player = get_tree().get_root().get_node("basic_scene/Player")
	if not player:
		return
	var distance_to_player = global_position.distance_to(player.global_position)
	
	match current_state:
		State.ALIVE:
			if distance_to_player <= enemy_data.attack_range:
				start_attack(player)
			else:
				move_towards_player(delta)
		State.ATTACK:
			velocity = Vector2.ZERO
		State.DEAD:
			velocity = Vector2.ZERO


func start_attack(player):
	if current_state != State.ATTACK and not attack_timer.is_stopped():
		return  # Noch im Cooldown

	current_state = State.ATTACK
	velocity = Vector2.ZERO  # Bewegung stoppen
	
	if sprite and enemy_data.attack_animation:
		sprite.play("attack")
	await sprite.animation_finished  # Warte, bis die Animation zu Ende ist
	
	if global_position.distance_to(player.global_position) <= enemy_data.attack_range:
		player.take_damage(enemy_data.attack_damage)
	
	attack_timer.start()  # Cooldown starten
	current_state = State.ALIVE

func _on_attack_cooldown():
	current_state = State.ALIVE

func move_towards_player(_delta):
	var player = get_tree().get_root().get_node("basic_scene/Player")  # Passe den Pfad an
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * enemy_data.speed
		move_and_slide()
		update_animation(direction)
		
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

# Diese Methode wird vom Projektil aufgerufen, wenn der Gegner getroffen wird
func on_hit(damage: int):  # Wenn der Gegner getroffen wird
	if current_state == State.ALIVE:
		current_health -= damage
		if current_health <= 0:
			die()

func die():
	current_state = State.DEAD
	sprite.modulate = Color(0.5, 0.5, 0.5)  # Ändere die Farbe für den Todeszustand
	respawn_timer.start()
	velocity = Vector2.ZERO

	# Zufällige Drop-Chance (30% Wahrscheinlichkeit)
	var drop_chance = 0.1
	if randf() < drop_chance:
		drop_pickup()

	if !enemy_data.has_death_state:
		queue_free()
	else:
		last_state = global_position
		var explode = load("res://scenes/enemies/explosion.tscn").instantiate()
		explode.global_position = last_state
		get_parent().add_child(explode)
		sprite.play("broken")

func drop_pickup():
	# Verzögere das Hinzufügen des Pickups, um den Fehler zu vermeiden
	call_deferred("_create_pickup")
	
func _create_pickup():
	# Erstelle und füge das Pickup hinzu
	var pickup_scene = load("res://scenes/pickups/pickup.tscn")  # Lade Pickup-Szene
	var pickup = pickup_scene.instantiate()
	pickup.global_position = global_position  # Drop an der Gegnerposition
	get_parent().add_child(pickup)

func _on_respawn_ghost_timer_timeout():
	# Geister-Gegner spawnen
	if enemy_data.has_death_state:
		var ghost = load("res://scenes/enemies/ghost.tscn").instantiate()  # Geister-Szene laden
		ghost.global_position = last_state
		get_parent().add_child(ghost)
	# Entferne den aktuellen Gegner
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):  # Prüfen, ob der getroffene Körper ein Gegner ist
		body.take_damage(1)  # Schaden an den Spieler weitergeben
		body.start_invincibility(1)  # Starte I-Frames für 1 Sekunde

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		target_player = body
		start_shoot_timer()

func _on_detection_area_body_exited(body):
	if body == target_player:
		enemy_data.speed = enemy_data.default_speed
		target_player = null
		shoot_timer.stop()  # Angriff abbrechen
		
func start_shoot_timer():
	if shoot_timer.is_inside_tree():  
		remove_child(shoot_timer)  # Falls der Timer schon existiert, entfernen

	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(shoot)

	add_child(shoot_timer)

	shoot_timer.start()

		
func shoot():
	if target_player == null:
		return  # Falls der Spieler inzwischen verschwunden ist

	var direction = (target_player.global_position - global_position).normalized()
	
	var projectile = projectile_scene.instantiate()
	projectile.direction = (target_player.global_position - global_position).normalized()  # Richtung berechnen
	get_parent().add_child(projectile)  # Projektil zur Szene hinzufügen
	projectile.global_position = global_position  # Projektil startet beim Gegner
	
	enemy_data.speed = 10.0
	get_parent().add_child(projectile)

	shoot_timer.start()
