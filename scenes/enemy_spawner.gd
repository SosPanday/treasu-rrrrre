extends Node2D

@export var spawn_delay: float = 3.0  # Zeit zwischen den Spawns
@export var enemy_scene: PackedScene  # Die Gegner-Szene, die gespawnt wird
@export var max_enemies: int = 10  # Maximale Anzahl von Gegnern, die gleichzeitig existieren dürfen

var active_enemies: Array = []  # Liste der aktiven Gegner

@onready var timer = $Timer

func _ready():
	# Initialisiere den Timer und starte den Spawner
	timer.wait_time = spawn_delay
	timer.one_shot = false
	timer.start()

# Zufällige Position für den Spawn
func get_random_position() -> Vector2:
	var spawn_area = Rect2(Vector2(-200, -200), Vector2(400, 400))  # Beispielbereich
	
	return spawn_area.position + Vector2(
		randf_range(0, spawn_area.size.x),
		randf_range(0, spawn_area.size.y)
	)

func _on_timer_timeout():
	if active_enemies.size() < max_enemies:
		var new_enemy = enemy_scene.instantiate()  # Erstelle einen neuen Gegner
		add_child(new_enemy)  # Füge den Gegner dem Spawner als Kind hinzu
		
		# Setze eine zufällige Position (z. B. um den Spieler herum oder auf der Karte)
		new_enemy.position = get_random_position()
		
		# Überwache das Entfernen von Gegnern
		
		# Füge den Gegner zur Liste der aktiven Gegner hinzu
		active_enemies.append(new_enemy)
