extends Node2D

var target_node
var blackbox
var full_text
var current_text = ""
var has_interacted = 0


func _ready():
	# Directly access the node using the full path
	target_node = get_node("/root/Node2D/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")#/SkretRoom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")
	print(target_node.text)
	blackbox = get_node("/root/Node2D/textbox/CanvasLayer")
	print(blackbox)
	#target_node.visible = false
	blackbox.visible = false

func interact():
	if has_interacted == 0:
		blackbox.visible = true
		#target_node.text = "changed text"
		full_text = "You stare longingly at the machine. It stares back, silently judging you."
		
		type_text(full_text)
		has_interacted = 1
	elif has_interacted == 1:
		has_interacted = 2
		blackbox.visible = true
		full_text = "Still no cup? Even the coffee machine's losing hope in you."
		type_text(full_text)
	else:
		full_text = "A perfect pour. You're now caffeinated and dangerous."
		blackbox.visible = true
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
	
