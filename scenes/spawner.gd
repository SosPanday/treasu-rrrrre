extends Node

@export var enemy_scene: PackedScene  # Referenz zur Gegner-Szene
@export var enemies_per_wave: int = 5  # Anzahl der Gegner pro Welle
@export var spawn_offset: float = 1000.0  # Abstand vom Bildschirm für den Spawn
@onready var camera = $"../Camera2D"

var spawn_positions: Array = []  # Array, um die bereits verwendeten Spawn-Positionen zu speichern

func _ready():
	# Gegner spawnen, wenn die Szene bereit ist
	spawn_enemies()

func spawn_enemies():
	# Berechne die Bildschirmgröße (viewport size)
	var viewport_size = get_viewport().size  # Das gesamte Viewport wird hier verwendet

	# Sicherstellen, dass das Array für die Spawn-Positionen leer ist
	spawn_positions.clear()

	# Gegner spawnen
	for i in range(enemies_per_wave):
		# Berechne die Spawn-Position außerhalb des Kamerabereichs
		var spawn_position = get_random_spawn_position(viewport_size)

		# Sicherstellen, dass die Position nicht bereits verwendet wurde
		while spawn_positions.has(spawn_position):
			spawn_position = get_random_spawn_position(viewport_size)

		# Füge die verwendete Spawn-Position zum Array hinzu
		spawn_positions.append(spawn_position)

		# Erstelle den Gegner
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_position  # Setze die Spawn-Position außerhalb der Kamera
		
		# Füge den Gegner nach der Initialisierung verzögert zur Szene hinzu
		call_deferred("add_child", enemy)  # Verzögertes Hinzufügen des Gegners zur Szene

# Funktion zur Berechnung der Spawn-Position
func get_random_spawn_position(viewport_size: Vector2) -> Vector2:
	# Zufällig entscheiden, ob der Gegner oben, unten, links oder rechts außerhalb spawnt
	var spawn_direction = randi_range(0, 4)  # 0 = oben, 1 = unten, 2 = links, 3 = rechts
	var spawn_position = Vector2.ZERO

	match spawn_direction:
		# Gegner oben
		0:
			spawn_position = Vector2(randf_range(0, viewport_size.x), -spawn_offset)
		# Gegner unten
		1:
			spawn_position = Vector2(randf_range(0, viewport_size.x), viewport_size.y + spawn_offset)
		# Gegner links
		2:
			spawn_position = Vector2(-spawn_offset, randf_range(0, viewport_size.y))
		# Gegner rechts
		3:
			spawn_position = Vector2(viewport_size.x + spawn_offset, randf_range(0, viewport_size.y))

	return spawn_position
