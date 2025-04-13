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
	target_node.text = "changed text"

func going():
	blackbox.visible = false
