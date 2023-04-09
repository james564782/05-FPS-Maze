extends KinematicBody

var player = null
var health = 25
var min_speed = 10
var max_speed = 45
var speed_slowdown = 3 #Makes it so the enemy is faster when it is further away but slows down as it gets closer

var kill_distance = 1
var type = 0

var enemies = [
	preload("res://Materials/ImageMaterials/Texture1.tres"),
	preload("res://Materials/ImageMaterials/Texture2.tres"),
	preload("res://Materials/ImageMaterials/Texture3.tres"),
	preload("res://Materials/ImageMaterials/Texture4.tres")
]



func _ready():
	type = (randi() % 4)
	$Pivot/CSGMesh.material = enemies[type]
	if type == 0:
		min_speed = 10
		health = 70
	elif type == 1:
		min_speed = 17
		health = 15
	elif type == 2:
		speed_slowdown = 4
		max_speed = 65
	elif type == 3:
		health = 35
		min_speed = 12
		speed_slowdown = 2

func damage(var damage):
	health -= damage
	if (health <= 0):
		Global.update_score(50 * (type + 1))
		Global.numberOfEnemies -= 1
		queue_free()

func _physics_process(delta):
	var direction = target_direction()
	if direction != null:
		$Pivot.rotation.y = direction.angle()+3*PI/2
		if can_move_toward_player() != Vector3.ZERO:
			move_and_slide(can_move_toward_player() * clamp((player.global_transform.origin.distance_to(global_transform.origin)), min_speed, max_speed) / speed_slowdown, Vector3.UP)
			pass
		if (player.global_transform.origin.distance_to(global_transform.origin)) < kill_distance:
			player.damage(10)

func target_direction():
	player = get_tree().get_root().get_node_or_null("/root/Game/Player")
	if player != null:
		var direction = Vector2(global_transform.origin.x, global_transform.origin.z).angle_to_point(Vector2(player.global_transform.origin.x, player.global_transform.origin.z)) - PI/2
		return Vector2.UP.rotated(-direction)
	else:
		return null

func can_move_toward_player():
	var detection = $Detect_Walls
	detection.cast_to = player.global_transform.origin - global_transform.origin
	if not detection.is_colliding():
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		return direction
	return Vector3.ZERO
