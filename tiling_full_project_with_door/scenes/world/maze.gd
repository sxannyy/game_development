extends Node2D

@export var complexity:float=0.75
@export var density:float = 0.75
@export var size:Vector2i = Vector2i(70,70)

@onready var water: TileMapLayer = $Water
@onready var ground: TileMapLayer = $Ground
@onready var teleport = $Teleport
@onready var apple = $Apple
var label_map:Array[Array]
var labels:Array[int]
var map:Array = []
var max=0
var max_label=0
var maze_ready: bool = false
var _pending_character: CharacterBody2D = null
func _place_character(character:CharacterBody2D):
	if not maze_ready:
		_pending_character = character
		return
	while true:
		var x_rand = randi_range(0, size.x - 1)
		var y_rand = randi_range(0, size.y - 1)
		var tile = ground.get_cell_atlas_coords(Vector2i(x_rand,y_rand))
		if tile != Vector2i(-1,-1):
			if max_label!=0:
				if label_map[y_rand][x_rand]==max_label:
					print(max_label)
					character.global_position=ground.map_to_local(Vector2i(x_rand,y_rand))
					break
			else:
				character.global_position=ground.map_to_local(Vector2i(x_rand,y_rand))
				break
	while true:
		var x_rand = randi_range(0, size.x - 1)
		var y_rand = randi_range(0, size.y - 1)
		var tile = ground.get_cell_atlas_coords(Vector2i(x_rand,y_rand))
		var place=ground.map_to_local(Vector2i(x_rand,y_rand))
		if tile != Vector2i(-1,-1) and abs(place.x-character.global_position.x)>1 and abs(place.y-character.global_position.y)>1:
			if max_label!=0:
				if label_map[y_rand][x_rand]==max_label:
					teleport.global_position=ground.map_to_local(Vector2i(x_rand,y_rand))
					break
			else:
				teleport.global_position=ground.map_to_local(Vector2i(x_rand,y_rand))
				break
	while true:
		var x_rand = randi_range(0, size.x - 1)
		var y_rand = randi_range(0, size.y - 1)
		var tile = ground.get_cell_atlas_coords(Vector2i(x_rand,y_rand))
		var place=ground.map_to_local(Vector2i(x_rand,y_rand))
		if tile != Vector2i(-1,-1) and abs(place.x-character.global_position.x)>1 and abs(place.y-character.global_position.y)>1:
			if max_label!=0:
				if label_map[y_rand][x_rand]==max_label:
					apple.global_position=ground.map_to_local(Vector2i(x_rand,y_rand))
					break
			else:
				apple.global_position=ground.map_to_local(Vector2i(x_rand,y_rand))
				break
	
func _ready() -> void:
	GameWorld.apple_found=false
	map = get_map()
	_draw_map(map)
	
	_draw_border()
	label_all()
	find_max()
	maze_ready = true
	if _pending_character != null:
		var c = _pending_character
		_pending_character = null
		_place_character(c)
	
	
func _draw_map(map):
	for x in size.x:
		for y in size.y:
			if map[y][x]==1:
				ground.set_cell(Vector2i(x,y), 0, Vector2i(1,1))
			else:
				water.set_cell(Vector2i(x,y), 0, Vector2i(x%4,0))


func _draw_border() -> void:
	for x in range(-1, size.x + 1):
		water.set_cell(Vector2i(x, -1), 0, Vector2i(abs(x) % 4, 0))
		water.set_cell(Vector2i(x, size.y), 0, Vector2i(abs(x) % 4, 0))
	for y in range(-1, size.y + 1):
		water.set_cell(Vector2i(-1, y), 0, Vector2i(abs(y) % 4, 0))
		water.set_cell(Vector2i(size.x, y), 0, Vector2i(abs(y) % 4, 0))
				
	
func get_map():
	var map:Array[Array]
	for y in size.y:
		map.append([])
		map[y].resize( size.x)
		for x in size.x:
			map[y][x]=0
	var scale_density = floor(density*floor(size.x/2)*floor(size.y/2))
	var scale_complexity = floor(complexity * 5 *(size.x+size.y))
	for i in scale_density:
		var x_rand = randi_range(0, floor(size.x/2))*2+1
		var y_rand = randi_range(0, floor(size.y/2))*2+1
		if x_rand<size.x and y_rand<size.y:
			map[y_rand][x_rand]=1
			for j in scale_complexity:
				var neighbours = []
				if x_rand>2:
					neighbours.append([y_rand,x_rand-2])
				if x_rand<size.x-2:
					neighbours.append([y_rand,x_rand+2])
				if y_rand>2:
					neighbours.append([y_rand-2,x_rand])
				if y_rand<size.y-2:
					neighbours.append([y_rand+2,x_rand])
				if neighbours.size()>0:
					var yx = neighbours[randi_range(0,neighbours.size()-1)]
					var yn=yx[0]
					var xn=yx[1]
					if map[yn][xn]==0:
						map[yn][xn]=1
						var dy=yn+floor((y_rand-yn)/2)
						var dx=xn+floor((x_rand-xn)/2)
						map[dy][dx]=1
						x_rand=xn
						y_rand=yn
			
	return map

func find_max():
	var count=0
	var new_labels:Array[int]=[]
	for label in labels:
		count=0
		for x in label_map.size():
			for y in label_map[0].size():
				if label_map[y][x]==label:
					count+=1
		if count>max:
			max=count
			max_label=label
	return max_label
	


func get_labels():
	labels=[]
	for x in range(0,size.x-1):
		for y in range(0,size.y-1):
			if label_map[y][x] not in labels and label_map[y][x]>0:
				labels.append(label_map[y][x])
				
func label(x,y,index):
	if label_map[y][x]==1 or label_map[y][x]==-1:
		label_map[y][x]=index
		if x<size.x-1:
			label(x+1,y,index)
		if x>0:
			label(x-1,y,index)
		if y<size.y-1:
			label(x,y+1,index)
		if y>0:
			label(x,y-1,index)
	return
	
func label_all():
	label_map=map.duplicate(true)
	var index=1
	var found=false
	while true:
		index+=1
		found=false
		for find_x in label_map.size():
			for find_y in label_map[find_x].size():
				if label_map[find_y][find_x]==1:
					label(find_x, find_y, index)
					found=true
					break
			if found:
				break
		if !found:
			get_labels()
			return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_position = get_global_mouse_position()
		var tile_pos=ground.local_to_map(mouse_position)
		var tile = ground.get_cell_atlas_coords(tile_pos)
		if tile == Vector2i(1,1):
			var nav = get_world_2d().navigation_map
			var character_position =GameWorld.player.global_position
			var path = NavigationServer2D.map_get_path(nav,character_position, mouse_position, true)
			var new_path=[]
			for i in path:
				new_path.append(ground.map_to_local(ground.local_to_map(i)))
			GameWorld.player.path(new_path)
