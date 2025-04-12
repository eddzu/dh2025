extends CharacterBody2D

var sped: float = 200

func _physics_process(delta: float) -> void:
	var dir = Input.get_vector("left","right","up","down")
	velocity = dir * Vector2(sped,sped);
	# TODO: detect direction and display appropriate animation, handle special case where no movment
	%AnimatedSprite2D.play("down")
	
	move_and_slide()
	
