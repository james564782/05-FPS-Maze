extends Spatial

var map = [] #whereever map = false, it is solid, whereever map = true, it is hollow
var objectMap = []
var tiles = [
	preload("res://MazeGenerator/TileEmpty.tscn")	# all the tiles we created
	,preload("res://MazeGenerator/TileFilled.tscn")
]
var enemies = [
	preload("res://Enemy/Enemy.tscn")
]
var light = preload("res://Lighting/Torch.tscn")

var tile_size = 2 						# 2-meter tiles
var width = 200  						# width of map (in tiles), Standard is 100
var height = 25  						# height of map (in tiles), Standard is 25

var emptySpaces = 0
var numberOfRooms = 0
var minNumberOfRooms = 10

var enemy_spawn_rate = 0.03 #one in every # spawn, standard is 0.025
var light_spawn_rate = 0.01

func _ready():
	randomize()
	make_maze()

var rooms = [] #[Room Number],[XPos, YPos, XSize, YSize]

var room_size = 6
var room_variation = 2
func create_room(var xPos, var yPos, var xSize, var ySize):
	if can_create_room_at_position(xPos, yPos, xSize, ySize):
		for x in range(xPos - (xSize / 2), xPos + (xSize / 2)):
			for y in range(yPos - (ySize / 2), yPos + (ySize / 2)):
				if not map[x][y]:
					map[x][y] = true
					emptySpaces += 1
		rooms.append(Vector2(xPos, yPos))
		return true
	else:
		return false

func can_create_room_at_position(var xPos, var yPos, var xSize, var ySize):
	var value = true
	if withinBoundaries(xPos, yPos, xSize, ySize):
		for x in range(xPos - (xSize / 2.0) - 1, xPos + (xSize / 2.0) + 1):
			for y in range(yPos - (ySize / 2.0) - 1, yPos + (ySize / 2.0) + 1):
				if map[x][y]:
					value = false
					break
		return value
	else:
		return false

func withinBoundaries(var xPos, var yPos, var xSize, var ySize):
	if xPos + (xSize / 2.0) < width - 1 and xPos - (xSize / 2.0) >= 1 and yPos + (ySize / 2.0) < height - 1 and yPos - (ySize / 2.0) >= 1:
		return true
	else:
		return false

func make_maze():
	for x in range(width):
		map.append([])
		map[x].resize(height)
		objectMap.append([])
		objectMap[x].resize(height)
		for y in range(height):
			map[x][y] = false
			objectMap[x][y] = false
	
	create_room(2, 2, 2, 2)
	var count = 0
	for x in range(1, width - 1):
		for y in range(0, height / 4):
			var widthSize = random_range(room_size - room_variation, room_size + room_variation)
			var lengthSize = random_range(room_size - room_variation, room_size + room_variation)
			if create_room(x, random_range(1, height - 1), widthSize, lengthSize):
				count = 0
				numberOfRooms += 1
			else:
				count += 1
	
	for i in range(0, rooms.size() - 1):
		var previousValue = rooms[i].linear_interpolate(rooms[i+1], 0.0)
		previousValue = Vector2(round(previousValue.x), round(previousValue.y))
		for a in range(0.0, 1.0 * 100.0):
			var value = rooms[i].linear_interpolate(rooms[i+1], a / 100.0)
			value = Vector2(round(value.x), round(value.y))
			map[value.x][value.y] = true
			if value.x != previousValue.x and value.y != previousValue.y:
				map[value.x][round(value.y - 1)] = true
				map[value.x][round(value.y + 1)] = true
				map[round(value.x - 1)][value.y] = true
				map[round(value.x + 1)][value.y] = true
				
				pass
			previousValue = value
	var Object_Container = get_node_or_null("/root/Game/Object_Container")
	for x in range(width):
		for y in range(height):
			var tile
			var position = Vector3(x * tile_size, 0, y * tile_size)
			if map[x][y]:
				tile = tiles[0].instance()
				if enemy_spawn_rate > randf() and Vector3(4, 0, 4).distance_to(position) > 5 and Object_Container != null:
					var enemy = enemies[0].instance()
					enemy.translation = position
					enemy.name = "Enemy " + str(x + (y * height))
					Object_Container.add_child(enemy)
					Global.numberOfEnemies += 1
				elif enemy_spawn_rate > randf() and Object_Container != null and Vector3(4, 0, 4).distance_to(position) > 5:
					var object = light.instance()
					Object_Container.add_child(object)
					object.translation = position
					object.rotation_degrees.y = randf() * 360.0
					object.name = "Light " + str(x + (y * height))
			else:
				tile = tiles[1].instance()
			if x % 2 == 0:
					tile.scale.x = -1
			if y % 2 == 0:
				tile.scale.z = -1
			tile.translation = position
			tile.name = "Tile_" + str(x) + "_" + str(y)
			add_child(tile)
	print("Spawned " + str(Global.numberOfEnemies) + " Enemies")

func random_range(var start, var end):
	if end < start:
		return start
	else:
		var value = end - start
		value = randi() % value #returns random value between the difference between start and end
		return value + start
#Spanning Tree Generation
