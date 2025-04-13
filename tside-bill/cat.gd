extends CharacterBody2D

var shit_is_going_down:int = 0
var speed: float = 200

func _on_cat_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		shit_is_going_down = 1
		var spawner = %objectSpawner
		spawner.texture = null
		
func _process(delta: float) -> void:
	if shit_is_going_down == 1:
		%rig.play("left")
		shit_is_going_down = 2
	if shit_is_going_down == 2:
		self.position += Vector2(-1,0) * delta * speed;
