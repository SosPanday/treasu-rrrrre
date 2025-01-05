extends Resource

@export var cooldown: float = 0.5  # Zeit zwischen Schüssen
@export var projectile_scene: PackedScene  # Referenz zur Projektil-Szene
@export var projectile_speed: float = 400.0  # Geschwindigkeit der Geschosse
@export var num_projectiles: int = 1  # Anzahl der Geschosse (für Spread-Waffen)
@export var spread_angle: float = 15.0  # Winkelabweichung für Spread-Waffen
