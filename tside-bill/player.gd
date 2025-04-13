extends CharacterBody2D

var sped: float = 100

func _physics_process(delta: float) -> void:
	var dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * Vector2(sped, sped) * delta
	
	# Determine which animation to play based on direction
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				%AnimatedSprite2D.play("right")
			else:
				%AnimatedSprite2D.play("left")
		else:
			if dir.y > 0:
				%AnimatedSprite2D.play("down")
			else:
				%AnimatedSprite2D.play("up")
	else:
		%AnimatedSprite2D.stop()

	move_and_slide()	

func _input(event) -> void:
	if event.is_action_pressed("phone"):
		if not %fon.get_meta("FlipUp"):
			%fon.play("flip_up")
			%fon.set_meta("FlipUp",true)
		else:
			%fon.play("flip_down")
			%fon.set_meta("FlipUp",false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method('interact'):
		#show textbox
		body.interact()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method('going'):
		body.going()
	# hide the textbox
