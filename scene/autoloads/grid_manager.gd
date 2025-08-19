extends Node


var nav_layer: NavLayer
var visual_layer:TileMapLayer

var map_width: int = 0
var map_height: int = 0

func _ready():
	calculate_map_size()
	

func calculate_map_size():
	if not nav_layer or nav_layer.grid_data_dict.is_empty():
		return
	
	var min_x = 999999
	var max_x = -999999
	var min_y = 999999
	var max_y = -999999
	
	for grid_pos in nav_layer.grid_data_dict.keys():
		min_x = min(min_x, grid_pos.x)
		max_x = max(max_x, grid_pos.x)
		min_y = min(min_y, grid_pos.y)
		max_y = max(max_y, grid_pos.y)
	
	map_width = max_x - min_x + 1
	map_height = max_y - min_y + 1

func get_grid_position(world_position:Vector2) -> Vector2i:#转化世界坐标为网格的索引坐标
	return nav_layer.local_to_map(nav_layer.to_local(world_position))

func get_world_position(grid_position:Vector2i) -> Vector2:#转化网格索引位置为世界坐标
	return nav_layer.to_global(nav_layer.map_to_local(grid_position)) 

func get_mouse_world_position() -> Vector2:#获取鼠标的世界坐标
	return nav_layer.get_global_mouse_position()
	
func get_mouse_grid_position() -> Vector2i:#获取鼠标所在的网格索引坐标
	return get_grid_position(get_mouse_world_position())
	
func get_nav_grid_path(start_grid_position:Vector2i,end_grid_position:Vector2i) -> Array[Vector2i]:#获取路径网格数组
	if not is_valid_grid(start_grid_position) or not is_valid_grid(end_grid_position):
		return []
	
	return nav_layer.a_star.get_id_path(start_grid_position, end_grid_position)


func get_nav_world_path(start_grid_position:Vector2i,end_grid_position:Vector2i) -> Array[Vector2]:
	var grid_path := get_nav_grid_path(start_grid_position,end_grid_position)
	var world_path :Array[Vector2] = []
	for grid_position in grid_path:
		var world_position = get_world_position(grid_position)
		world_path.append(world_position)
	
	return world_path

func get_grid_path_length(grid_path:Array[Vector2i]) -> float:
	if grid_path.size() <= 1:
		return 0
	var length:float = 0
	for i in range(1,grid_path.size()):
		if grid_path[i - 1].x != grid_path[i].x and grid_path[i - 1].y != grid_path[i].y :
			length += 1.4
			print("这里确实现了对角线，+1.4")
		else :
			length += 1
	return length
	
func is_valid_grid(grid_position: Vector2i) -> bool:  #是否是有效的网格valid：有效的
	return nav_layer.grid_data_dict.has(grid_position)

func is_grid_walkable(grid_position:Vector2i) -> bool: #如果是有效网格，而且是网格本身属性是可移动，那么就设置成可移动的网格
	return is_valid_grid(grid_position) and nav_layer.grid_data_dict[grid_position].walkable
	
func set_grid_walkable(grid_position:Vector2i,walkable:bool) ->void:#如果不是有效网格则返回，否则将网格属性设置成可移动，在寻路系统中设置可移动
	if not is_valid_grid(grid_position):
		return
	
	nav_layer.grid_data_dict[grid_position].walkable = walkable
	#nav_layer.a_star.set_cell_obstacle(grid_position,walkable)

func is_grid_occupied(grid_position:Vector2i) ->bool: #获取网格是否已经被单位占据
	return is_valid_grid(grid_position) and nav_layer.grid_data_dict[grid_position].is_occupied_by_uint()
	
func get_grid_occupied(grid_position:Vector2i) -> Unit: #获取占据格的单位unit
	if not is_valid_grid(grid_position):
		return null
	return nav_layer.grid_data_dict[grid_position].occupied_unit
	
func set_grid_occupied(grid_position:Vector2i,unit:Unit) -> void:
	if not is_valid_grid(grid_position):
		return
	nav_layer.grid_data_dict[grid_position].occupied_unit = unit
	
func visualize_grids(grids:Array[Vector2i],color:Color = Color.WHITE) -> void:
	visual_layer.clear()
	visual_layer.modulate = color
	visual_layer.set_cells_terrain_connect(grids,0,0)



	
	
	
	
	
	
	
	
	
