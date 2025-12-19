extends Node2D

enum RandomType {Random, Perlin}

@export var size: Vector2i = Vector2i(10, 10)
@export var random_type: RandomType = RandomType.Perlin

@export var use_orthogonal_bridges: bool = false
@export var min_island_area: int = 15

@onready var water: TileMapLayer = $Water
@onready var ground: TileMapLayer = $Ground
@onready var trees: TileMapLayer = $Trees
@onready var bridges: TileMapLayer = $Bridges

var ground_tiles := {"ground": Vector2i(1, 1)}

var tree_tiles := {
	"small_tree": Vector2i(0, 0),
	"big_tree": Vector2i(1, 0),
	"apple_tree": Vector2i(3, 0),
}

var map: Array = []

func _ready() -> void:
	for x in range(-1, size.x + 2):
		water.set_cell(Vector2i(x, -1), 0, Vector2i(0, 0))
		water.set_cell(Vector2i(x, size.y + 1), 0, Vector2i(0, 0))

	for y in range(-1, size.y + 2):
		water.set_cell(Vector2i(-1, y), 0, Vector2i(0, 0))
		water.set_cell(Vector2i(size.x + 1, y), 0, Vector2i(0, 0))

	match random_type:
		RandomType.Random:
			_random()
		RandomType.Perlin:
			_perlin()


func _random() -> void:
	ground.clear()
	water.clear()
	trees.clear()
	if bridges:
		bridges.clear()

	for x in range(size.x + 1):
		for y in range(size.y + 1):
			var tile: Vector2i = Vector2i(-1, -1)
			var tile_pos := Vector2i(x, y)

			if randf() < 0.8:
				tile = ground_tiles["ground"]
				if randf() < 0.1:
					var tree_types: Array = tree_tiles.keys()
					var tree_type: int = randi_range(0, tree_tiles.size() - 1)
					var tree = tree_tiles[tree_types[tree_type]]
					trees.set_cell(tile_pos + Vector2i(0, -1), 0, tree)

			if tile != Vector2i(-1, -1):
				ground.set_cell(tile_pos, 0, tile)
			else:
				water.set_cell(tile_pos, 0, Vector2i(0, 0))

func label(input_map: Array) -> Array:
	var h: int = input_map.size()
	if h == 0:
		return []
	var w: int = input_map[0].size()

	var labels: Array = []
	labels.resize(h)
	for y in range(h):
		labels[y] = []
		labels[y].resize(w)
		for x in range(w):
			labels[y][x] = 0

	var neighbors_4 := [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	]
	var neighbors_8 := neighbors_4 + [
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
	]
	var neighbors := neighbors_8

	var current_label: int = 0

	for y in range(h):
		for x in range(w):
			if int(input_map[y][x]) != 0 and int(labels[y][x]) == 0:
				current_label += 1
				var stack: Array[Vector2i] = []
				stack.append(Vector2i(x, y))
				labels[y][x] = current_label

				while stack.size() > 0:
					var p: Vector2i = stack.pop_back()
					for d in neighbors:
						var nx: int = p.x + d.x
						var ny: int = p.y + d.y
						if nx < 0 or ny < 0 or nx >= w or ny >= h:
							continue
						if int(input_map[ny][nx]) != 0 and int(labels[ny][nx]) == 0:
							labels[ny][nx] = current_label
							stack.append(Vector2i(nx, ny))
	return labels


func remove_islands(labels: Array, min_area: int = 15) -> Array:
	var h: int = labels.size()
	if h == 0:
		return labels
	var w: int = labels[0].size()

	var area := {}
	for y in range(h):
		for x in range(w):
			var l: int = int(labels[y][x])
			if l > 0:
				area[l] = area.get(l, 0) + 1

	var keep := {}
	for l in area.keys():
		if int(area[l]) >= min_area:
			keep[l] = true

	for y in range(h):
		for x in range(w):
			var l: int = int(labels[y][x])
			if l > 0 and not keep.has(l):
				labels[y][x] = 0

	return labels

func _get_island_ids(labels: Array) -> Array[int]:
	var h: int = labels.size()
	var w: int = labels[0].size()
	var set_ids := {}
	for y in range(h):
		for x in range(w):
			var l: int = int(labels[y][x])
			if l > 0:
				set_ids[l] = true
	var ids: Array[int] = []
	for k in set_ids.keys():
		ids.append(int(k))
	return ids

func _get_points_of_label(labels: Array, label_id: int) -> Array[Vector2i]:
	var h: int = labels.size()
	var w: int = labels[0].size()
	var pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			if int(labels[y][x]) == label_id:
				pts.append(Vector2i(x, y))
	return pts

func _bridge_path(a: Vector2i, b: Vector2i) -> Array:
	if use_orthogonal_bridges:
		var corner := Vector2i(a.x, b.y)
		var path: Array = []
		path += Geometry2D.bresenham_line(a, corner)
		path += Geometry2D.bresenham_line(corner, b)
		return path
	else:
		return Geometry2D.bresenham_line(a, b)

func build_bridge(map_ref: Array, labels: Array, id1: int, id2: int) -> void:
	var pts1 := _get_points_of_label(labels, id1)
	var pts2 := _get_points_of_label(labels, id2)
	if pts1.is_empty() or pts2.is_empty():
		return

	var best_d: float = 1e30
	var best_a: Vector2i = pts1[0]
	var best_b: Vector2i = pts2[0]
	
	for p1 in pts1:
		for p2 in pts2:
			var d := Vector2(p1).distance_squared_to(Vector2(p2))
			if d < best_d:
				best_d = d
				best_a = p1
				best_b = p2

	var bridge := _bridge_path(best_a, best_b)

	var prev := Vector2i(bridge[0])
	for p in bridge:
		var pi := Vector2i(p)
		map_ref[pi.y][pi.x] = -1

		if prev.x != pi.x and prev.y != pi.y:
			map_ref[prev.y][pi.x] = -1
		prev = pi

func _perlin() -> void:
	ground.clear()
	water.clear()
	trees.clear()
	if bridges:
		bridges.clear()

	var noise := FastNoiseLite.new()
	noise.frequency = 0.05
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 2
	noise.fractal_gain = 1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

	map = []
	for y in range(size.y + 1):
		map.append([])
		map[y].resize(size.x + 1)
		for x in range(size.x + 1):
			map[y][x] = 0

	for x in range(size.x + 1):
		for y in range(size.y + 1):
			var val: float = noise.get_noise_2d(float(x), float(y))
			map[y][x] = 1 if val > 0.0 else 0

	var labels := label(map)
	labels = remove_islands(labels, min_island_area)

	for y in range(size.y + 1):
		for x in range(size.x + 1):
			if int(labels[y][x]) == 0:
				map[y][x] = 0

	var ids: Array[int] = _get_island_ids(labels)
	while ids.size() > 1:
		build_bridge(map, labels, ids[0], ids[1])
		labels = label(map)
		ids = _get_island_ids(labels)

	for x in range(size.x + 1):
		for y in range(size.y + 1):
			var pos := Vector2i(x, y)

			if int(map[y][x]) == 1:
				ground.set_cell(pos, 0, ground_tiles["ground"])
			elif int(map[y][x]) == -1:
				if bridges:
					bridges.set_cell(pos, 0, Vector2i(0, 1))
				else:
					ground.set_cell(pos, 0, ground_tiles["ground"])
			else:
				water.set_cell(pos, 0, Vector2i(0, 0))

func _place_character(character: CharacterBody2D) -> void:
	while true:
		var x = randi_range(0, size.x)
		var y = randi_range(0, size.y)
		var pos = Vector2i(x, y)
		var tile = ground.get_cell_atlas_coords(pos)
		if tile != Vector2i(-1, -1):
			character.global_position = ground.map_to_local(pos)
			break
