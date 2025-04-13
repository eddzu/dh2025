extends CharacterBody2D

var target_node
var blackbox
var full_text
var current_text = ""
var has_interacted = false


func _ready():
	# Directly access the node using the full path
	target_node = get_node("/root/classroom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")#/SkretRoom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")
	print(target_node)
	blackbox = get_node("/root/classroom/textbox/CanvasLayer")
	print(blackbox)
	#target_node.visible = false
	blackbox.visible = false

func interact():
	if not has_interacted:
		blackbox.visible = true
		#target_node.text = "changed text"
		full_text = "Ugh, it's you... I suppose you want that key, but first, fetch me a coffee. It should be from the vending machine,\nwhich existed already when I was studying here... Nostalgic."
		
		type_text(full_text)
		has_interacted = true
	else:
		blackbox.visible = true
		full_text = "Did you bring anything useful?"
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
