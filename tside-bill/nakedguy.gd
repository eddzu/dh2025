extends CharacterBody2D

var target_node
var blackbox
var full_text
var current_text = ""


func _ready():
	# Directly access the node using the full path
	target_node = get_node("/root/SkretRoom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")
	blackbox = get_node("/root/SkretRoom/textbox/CanvasLayer")
	#target_node.visible = false
	blackbox.visible = false

func interact():
	blackbox.visible = true
	#target_node.text = "changed text"
	full_text = "Go away!"
		
	type_text(full_text)

func type_text(full_text):
	current_text = ""
	target_node.text = current_text
	
	var typing_timer = Timer.new()
	add_child(typing_timer)
	typing_timer.wait_time = 0.05
	typing_timer.one_shot = false
	typing_timer.connect("timeout", func():
		if current_text.length() < full_text.length():
			current_text += full_text[current_text.length()]
			target_node.text = current_text
		else:
			typing_timer.stop()
			typing_timer.queue_free()
	)
	typing_timer.start()
	#typing_timer.wait_time = 1.00
	

func going():
	blackbox.visible = false
