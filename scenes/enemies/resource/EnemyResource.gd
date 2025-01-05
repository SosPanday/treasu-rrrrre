# EnemyResource.gd
extends Resource

@export var sprite: SpriteFrames  # SpriteFrames anstelle von SpriteFrame
@export var health: int = 5  # Leben des Gegners
@export var speed: float = 50.0  # Geschwindigkeit des Gegners
@export var can_pass_through_walls: bool = false  # Ob der Gegner durch Wände gehen kann
@export var has_death_state: bool = true  # Ob der Gegner einen Todeszustand hat
@export var respawn_time: float = 4.0  # Zeit bis zum Spawn eines Geisters
