extends Node2D

@onready var animation_player = %"LOGO PLAYER"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("play_start"):
		animation_player.play("start")
	if event.is_action_pressed("start_game"):
		get_tree().change_scene_to_file("res://title_screen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
