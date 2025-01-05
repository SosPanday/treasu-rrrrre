extends Node2D  # Root-Knoten bleibt Node2D

@export var speed: float = 400.0
@export var lifetime: float = 1.5  # Lebensdauer des Projektils
@export var damage: float = 1.0 # Schaden des Projektils 
var direction: Vector2 = Vector2.ZERO  # Richtung des Projektils

func _ready():
	set_as_top_level(true)  # Verhindert, dass die Position relativ zum Parent verändert wird
	# Entferne das Projektil nach Ablauf der Lebensdauer
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Bewege das Projektil in die angegebene Richtung
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):  # Prüfen, ob der getroffene Körper ein Gegner ist
		body.on_hit(damage)  # Schaden dem Gegner zufügen
		queue_free()  # Projektil zerstören
