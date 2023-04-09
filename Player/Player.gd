extends KinematicBody

onready var Camera = $Pivot/Camera					# the camera attached to the player (in a "pivot" node so we rotate the entire player left and right but only move its "head" up and down)
onready var Bullet = load("res://Player/Bullet.tscn")
var Effects = null

var health = 10
var gravity = 0    #-30 							# downward (-y) acceleration applied on every frame
var max_speed = 6	#6								# velocity multiplier applied to every movement
var mouse_sensitivity = 0.002						# translating the mouse XY coordinates into angular (radian) movement
var mouse_range = 1.2								# Clamp to about a 140 degree range of motion

var velocity = Vector3()

func damage(var damage):
	health -= damage
	Global.updateHealth(health)
	if (health <= 0):
		print("Player dead")

func _ready():
	#hide and lock mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input():
	var input_dir = Vector3()						# Collect all the inputs into a single vector
	if Input.is_action_pressed("forward"):			# all the inputs are directions relative to where the camera is currently facing
		input_dir += -Camera.global_transform.basis.z
	if Input.is_action_pressed("back"):
		input_dir += Camera.global_transform.basis.z
	if Input.is_action_pressed("left"):				# strafe left and right
		input_dir += -Camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_dir += Camera.global_transform.basis.x
	if Input.is_action_pressed("shoot") and not shooting:
		shoot()
	input_dir = input_dir.normalized()				# just get the unit vector (length of 1), which essentially just returns the direction
	return input_dir

var cooldown = 0.1
var shooting = false

func shoot():
	shooting = true
	generate_bullet()
	var t = Timer.new()
	t.set_wait_time(cooldown)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	shooting = false
	pass

func generate_bullet():
	Effects = get_node_or_null("/root/Game/Effects")
	if Effects != null:
		var bullet = Bullet.instance()
		bullet.transform.origin = $Pivot/Gun/Muzzle.global_transform.origin
		bullet.rotation = $Pivot.global_rotation
		bullet.direction = -$Pivot/Camera.get_global_transform().basis.z
		Effects.add_child(bullet)

func _unhandled_input(event):
	if event is InputEventMouseMotion:											# if the mouse has moved
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)					# up-down motion, applied to the $Pivot
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -mouse_range, mouse_range)	# make sure we can't look inside ourselves :)
		rotate_y(-event.relative.x * mouse_sensitivity)							# left-right motion, applied to the Player

func _physics_process(delta):
	if (Input.is_action_pressed("reduce")):
		max_speed = 12
	else:
		max_speed = 6
	velocity.y += gravity * delta					# apply gravity
	if is_on_floor():
		velocity.y = 0
	var desired_velocity = get_input() * max_speed
	
	velocity.x = desired_velocity.x					# just get the XZ components of the velocity (the y is handled purely by gravity)
	velocity.z = desired_velocity.z
	velocity.y = 0
	velocity = move_and_slide(velocity, Vector3.UP, true)
