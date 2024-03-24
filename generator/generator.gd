# Initial version stolen from https://github.com/Zylann/voxelgame/tree/master

#tool
extends VoxelGeneratorMultipassCB
class_name WorldGenerator

const Structure = preload("./structure.gd")
const TreeGenerator = preload("./tree_generator.gd")
const HeightmapCurve = preload("./heightmap_curve.tres")
var world_seed: int

var water_level: int = 50

# TODO Don't hardcode, get by name from library somehow
const AIR = 0
const GRASS = 1
const DIRT = 2
const STONE = 3
const WATER_TOP = 4
const WATER_FULL = 5
const LOG = 4
const LEAVES = 25

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE

const _moore_dirs = [
	Vector3(-1, 0, -1),
	Vector3(0, 0, -1),
	Vector3(1, 0, -1),
	Vector3(-1, 0, 0),
	Vector3(1, 0, 0),
	Vector3(-1, 0, 1),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1)
]


var _tree_structures := []

const _chunk_size = 16

var _heightmap_min_y := int(HeightmapCurve.min_value)
var _heightmap_max_y := int(HeightmapCurve.max_value)
var _heightmap_range := 0
var _heightmap_noise := FastNoiseLite.new()
var _trees_min_y := 60
var _trees_max_y := 90


func _init():
	world_seed = hash(Globals.shared_data.world_seed)

	# TODO Even this must be based on a seed, but I'm lazy
	#var tree_generator = TreeGenerator.new()
	#tree_generator.log_type = LOG
	#tree_generator.leaves_type = LEAVES
	#for i in 16:
	#	var s = tree_generator.generate()
	#	_tree_structures.append(s)

	#var tallest_tree_height = 0
	#for structure in _tree_structures:
	#	var h = int(structure.voxels.get_size().y)
	#	if tallest_tree_height < h:
	#		tallest_tree_height = h
	#_trees_min_y = _heightmap_min_y
	#_trees_max_y = _heightmap_max_y + tallest_tree_height

	_heightmap_noise.seed = world_seed
	_heightmap_noise.frequency = 1.0 / 128.0
	_heightmap_noise.fractal_octaves = 4

	# IMPORTANT
	# If we don't do this `Curve` could bake itself when interpolated,
	# and this causes crashes when used in multiple threads
	HeightmapCurve.bake()


func _get_used_channels_mask() -> int:
	return 1 << _CHANNEL


func _generate_pass(voxel_tool: VoxelToolMultipassGenerator, pass_index: int):
	var min_pos := voxel_tool.get_main_area_min()
	var max_pos := voxel_tool.get_main_area_max()

	if pass_index == 0:
		# Base terrain
		for gz in range(min_pos.z, max_pos.z):
			for gx in range(min_pos.x, max_pos.x):
				var height := _get_height_at(gx, gz)
				
				
				for y in range(0, height-3):
					voxel_tool.set_voxel(Vector3(gx,y,gz), STONE)
				for y in range(height-3, height):
					voxel_tool.set_voxel(Vector3(gx,y,gz), DIRT)
				voxel_tool.set_voxel(Vector3(gx,height,gz), GRASS)
				
				# Water
				if height < water_level:
					for y in range(height + 1, water_level):
						voxel_tool.set_voxel(Vector3(gx,y,gz), WATER_FULL)
					
					voxel_tool.set_voxel(Vector3i(gx, height, gz), DIRT)
					voxel_tool.set_voxel(Vector3i(gx, water_level, gz), WATER_TOP)

	elif pass_index == 1:
		# Attempt to make a tree 4 times in each chunk

		# If the location picked is too close to another tree or the y level isnt right, it can fail
		# TODO: Fix the fact that trees from other chunks can still be too close
	
		var rng := RandomNumberGenerator.new()
		rng.seed = WorldGenerator._get_chunk_seed_2d(world_seed, min_pos / _chunk_size)
		var tree_locations = []

		for cx_off in range(-1,2):
			for cz_off in range(-1,2):
				for i in 4:
					var pos := min_pos + _chunk_size*Vector3i(cx_off, 0, cz_off) + Vector3i(rng.randi() % _chunk_size, 0, rng.randi() % _chunk_size)
					pos.y = _get_height_at(pos.x, pos.y)
					var valid_pos = true
					for tree_location in tree_locations:
						if abs(pos.x - tree_location.x) < 2 and abs(pos.y - tree_location.y) < 10 and abs(pos.z - tree_location.z) < 2:
							if pos.x < tree_location.x or pos.x == tree_location.x and pos.z < tree_location.z:
								tree_locations.erase(tree_location)
							else:
								valid_pos = false
								break

					if valid_pos:
						tree_locations.append(pos)
		var tree_generator = TreeGenerator.new()
		tree_generator.log_type = LOG
		tree_generator.leaves_type = LEAVES
		print(tree_locations)

		for tree_location in tree_locations:
			if tree_location.x >= min_pos.x and tree_location.x <= max_pos.x and tree_location.z >= min_pos.z and tree_location.z <= max_pos.z:
				var structure = tree_generator.generate()
				voxel_tool.paste_masked(tree_location, 
					structure.voxels, 1 << VoxelBuffer.CHANNEL_TYPE,
					# Masking
					VoxelBuffer.CHANNEL_TYPE, AIR)


#static func get_chunk_seed(cpos: Vector3) -> int:
#	return cpos.x ^ (13 * int(cpos.y)) ^ (31 * int(cpos.z))


static func _get_chunk_seed_2d(_world_seed: int, cpos: Vector3) -> int:
	return _world_seed ^ int(cpos.x) ^ (31 * int(cpos.z))


func _get_height_at(x: int, z: int) -> int:
	var t = 0.5 + 0.5 * _heightmap_noise.get_noise_2d(x, z)
	return int(HeightmapCurve.sample_baked(t))
