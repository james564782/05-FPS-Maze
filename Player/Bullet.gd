extends KinematicBody

var direction = Vector3.ZERO
var speed = 2.5
var damage = 5 #3

var Effects = null

func _physics_process(delta):
	var velocity = direction * speed
	move_and_collide(velocity)

func _on_Area_body_entered(body):
	if body.name != "Player":
		if body.has_method("damage"):
			body.damage(damage)
		queue_free()

func _on_Timer_timeout():
	queue_free()
