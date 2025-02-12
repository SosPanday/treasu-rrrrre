# EnemyResource.gd
extends Resource

@export var sprite: SpriteFrames  # SpriteFrames anstelle von SpriteFrame
@export var health: int = 5  # Leben des Gegners
@export var speed: float = 50.0  # Geschwindigkeit des Gegners
@export var default_speed: float = 50.0
@export var can_pass_through_walls: bool = false  # Ob der Gegner durch Wände gehen kann
@export var has_death_state: bool = true  # Ob der Gegner einen Todeszustand hat
@export var respawn_time: float = 4.0  # Zeit bis zum Spawn eines Geisters

@export var attack_range: float = 50.0  # Abstand zum Spieler, bei dem der Angriff ausgelöst wird
@export var attack_animation: String = "attack"  # Animation für den Angriff
@export var attack_cooldown: float = 1.5  # Zeit zwischen Angriffen
@export var attack_damage: int = 1  # Schaden, den der Gegner verursacht
