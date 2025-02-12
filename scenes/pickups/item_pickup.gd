extends Area2D

@export var weapon_resource: Resource  # Die neue Waffe, die der Spieler erhält
@export var duration: float = 5.0  # Wie lange die Waffe aktiv bleibt

func _ready():
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("set_temporary_weapon"):
		body.set_temporary_weapon(weapon_resource, duration)
		queue_free()
