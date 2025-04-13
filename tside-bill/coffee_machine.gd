extends Node2D

var target_node
var blackbox
var full_text
var current_text = ""
var has_interacted = 0
var decision;


func _ready():
	# Directly access the node using the full path
	target_node = get_node("/root/Node2D/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")#/SkretRoom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")
	print(target_node.text)
	blackbox = get_node("/root/Node2D/textbox/CanvasLayer")
	print(blackbox)
	#target_node.visible = false
	blackbox.visible = false

func interact():
		full_text = "You stare longingly at the machine. It stares back, silently judging you."
		var result = ApiCall.api_answer("grumpy")
		if result.has("text_answer"):
			full_text = result["text_answer"]
		else: 
			full_text = "This item is no good!";
		if result.has("decision"):
			decision = result["decision"]
			GlobalScript.hasCoffee = true;
		else:
			decision = false;
			
		blackbox.visible = true;
		type_text(full_text);
		
		
			

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
	
