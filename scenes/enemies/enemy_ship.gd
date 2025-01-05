extends CharacterBody2D

@export var enemy_data: Resource  # EnemyResource, die alle Attribute speichert
var current_health: int = 0  # Aktuelle Leben des Gegners
var current_state: State = State.ALIVE  # Der aktuelle Zustand des Gegners (ALIVE oder DEAD)
var last_state = global_position
enum State { ALIVE, DEAD }

@onready var sprite = $AnimatedSprite2D
@onready var respawn_timer = $Timer
@onready var collision = $CollisionShape2D  # Hier könnte das Kollisionsobjekt sein

func _ready():
	# Initialisieren der Werte
	if enemy_data:
		var data = enemy_data
		sprite.frames = data.sprite  # Zuweisen der SpriteFrames
		current_health = data.health
		velocity = Vector2.ZERO
		if enemy_data.has_death_state:
			respawn_timer.wait_time = data.respawn_time
			respawn_timer.one_shot = true
		

func _physics_process(delta):
	match current_state:
		State.ALIVE:
			move_towards_player(delta)
		State.DEAD:
			# Im Todeszustand keine Bewegung
			velocity = Vector2.ZERO


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
	# Wechsel in den Todeszustand
	current_state = State.DEAD
	sprite.modulate = Color(0.5, 0.5, 0.5)  # Ändere die Farbe für den Todeszustand
	respawn_timer.start()
	# Deaktiviere die Bewegung, behalte aber die Kollision bei
	velocity = Vector2.ZERO
	
	if !enemy_data.has_death_state:
		queue_free()
	else:
		last_state = global_position
		var explode = load("res://scenes/enemies/explosion.tscn").instantiate()
		explode.global_position = last_state
		get_parent().add_child(explode)
		sprite.play("broken")

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
