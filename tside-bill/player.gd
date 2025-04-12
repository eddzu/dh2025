extends CharacterBody2D

var sped: float = 100

func _physics_process(delta: float) -> void:
	var dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * Vector2(sped, sped)
	
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
	
