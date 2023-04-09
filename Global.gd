extends Node

var VP = null

var score = 0
var won = false

var health = 1

var numberOfEnemies = 0
var enemiesSpawned = false

func _ready():
	randomize()
	pause_mode = Node.PAUSE_MODE_PROCESS
	VP = get_viewport().size
	var _signal = get_tree().get_root().connect("size_changed",self,"_resize")
	reset()

func _physics_process(delta):
	if numberOfEnemies == 0 and enemiesSpawned:
		won = true
		var _scene = get_tree().change_scene("res://UI/End_Game.tscn")
	elif numberOfEnemies > 0:
		enemiesSpawned = true

func updateHealth(h):
	health = h
	if health <= 0:
		var _scene = get_tree().change_scene("res://UI/End_Game.tscn")
		print("end game")

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		var Pause_Menu = get_node_or_null("/root/Game/UI/Pause_Menu")
		if Pause_Menu == null:
			get_tree().quit()
		else:
			if Pause_Menu.visible:
				Pause_Menu.hide()
				get_tree().paused = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Pause_Menu.show()
				get_tree().paused = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resize():
	VP = get_viewport().size

func update_score(s):
	score += s
	var HUD = get_node_or_null("/root/Game/UI/HUD")
	if HUD != null:
		HUD.update_score()

func reset():
	score = 0
	health = 1
	numberOfEnemies = 0
	won = false
	enemiesSpawned = false
	
	
