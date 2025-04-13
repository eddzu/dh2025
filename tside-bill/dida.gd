extends CharacterBody2D

var target_node
var blackbox
var full_text
var current_text = ""
var has_interacted = false
var text_answer;


func _ready():
	# Directly access the node using the full path
	target_node = get_node("/root/classroom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")#/SkretRoom/textbox/CanvasLayer/ColorRect/HBoxContainer/Label")
	print(target_node)
	blackbox = get_node("/root/classroom/textbox/CanvasLayer")
	print(blackbox)
	#target_node.visible = false
	blackbox.visible = false
	
func interact():
	if not GlobalScript.visited_rooms.has("classroom"):
		blackbox.visible = true
		#target_node.text = "changed text"
		full_text = "Ugh, it's you... I suppose you want that key, but first, fetch me a coffee. \n It should be from the vending machine, which existed already when I was studying here... Nostalgic."
		GlobalScript.visited_rooms["classroom"] = true
		type_text(full_text)
		has_interacted = true
	else:
		var decsision = false
		if (GlobalScript.hasCoffee):
			var result = ApiCall.api_answer("grumpy")
			if result.has("text_answer"):
				text_answer = result["text_answer"] + "\n Here is your key!"
			else: 
				text_answer = "This item is no good!";
			if result.has("decision"):
				decsision = result["decision"]
			else:
				decsision = false;
		else:
			text_answer = "Pfff, I only want coffee from FRI coffee machine!"
		
		if decsision:
			GlobalScript.itemPic= load("res://sprites/kljuc.png")
		blackbox.visible = true
		full_text = text_answer;
		#full_text = "Thank you for the delicious coffee!"
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
