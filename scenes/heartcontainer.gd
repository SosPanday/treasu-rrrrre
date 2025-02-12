extends Node

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

@export var max_hearts: int = 3
var hearts: Array

func _ready():
	hearts = get_children()  # Holt sich alle Heart-Sprites (TextureRect)

func update_hearts(current_hp: int):
	for i in range(max_hearts):
		if i < current_hp:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = empty_heart
