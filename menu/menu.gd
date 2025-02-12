extends Control


const RUN_SCENE = preload("res://scenes/basic_scene.tscn")

@onready var continue_button: Button = $"VBoxContainer/New Run"


func _ready() -> void:
	get_tree().paused = false


func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
