# 自定义的AStarGrid2D类，支持边界墙检测
class_name CustomAStarGrid2D
extends AStarGrid2D

var tilemap_layer: TileMapLayer

func _init(tilemap_layer_ref: TileMapLayer):
	tilemap_layer = tilemap_layer_ref

# 重写这个方法来控制两点间的移动代价
func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	# 如果两点间有移动障碍，返回无穷大（不可通行）
	var barrier = has_movement_barrier(from_id, to_id)
	#print("Barrier check from ", from_id, " to ", to_id, ": ", barrier)
	
	if has_movement_barrier(from_id, to_id):
		return INF
	var unit = GridManager.get_grid_occupied(to_id)
	if unit != null:
		if unit.is_enemy:
			return INF
		else :
			return 1.0
	 #否则返回正常代价
	return 1.0

# 重写估算代价方法（可选，用于优化A*性能）
func _estimate_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	# 使用曼哈顿距离作为启发式
	return abs(to_id.x - from_id.x) + abs(to_id.y - from_id.y)

# 检查两个相邻格子间是否有移动障碍
func has_movement_barrier(from: Vector2i, to: Vector2i) -> bool:
	
	var direction = to - from
	
	# 只检查相邻格子（防止对角线等情况）
	if abs(direction.x) + abs(direction.y) != 1:
		return false
	
	# 检查起点格子是否有墙阻挡向外移动
	var from_tile_data = tilemap_layer.get_cell_tile_data(from)
	var to_tile_data = tilemap_layer.get_cell_tile_data(to)
	#print("Checking from ", from, " to ", to, " direction ", direction)
	#print("From tile data: ", from_tile_data)
	#print("  wall_north: ", from_tile_data.get_custom_data("wall_north"))
	#print("  wall_south: ", from_tile_data.get_custom_data("wall_south"))
	#print("  wall_east: ", from_tile_data.get_custom_data("wall_east"))
	#print("  wall_west: ", from_tile_data.get_custom_data("wall_west"))
#
	#print("To tile data: ", to_tile_data)
	#print("  wall_north: ", to_tile_data.get_custom_data("wall_north"))
	#print("  wall_south: ", to_tile_data.get_custom_data("wall_south"))
	#print("  wall_east: ", to_tile_data.get_custom_data("wall_east"))
	#print("  wall_west: ", to_tile_data.get_custom_data("wall_west"))
	if from_tile_data:
		match direction:
			Vector2i.UP:
				if from_tile_data.get_custom_data("wall_north"):
					return true
			Vector2i.RIGHT:
				if from_tile_data.get_custom_data("wall_east"):
					return true
			Vector2i.DOWN:
				if from_tile_data.get_custom_data("wall_south"):
					return true
			Vector2i.LEFT:
				if from_tile_data.get_custom_data("wall_west"):
					return true
	
	# 检查目标格子是否有墙阻挡从外面进入
	
	if to_tile_data:
		match direction:
			Vector2i.UP:    # 向上移动，检查目标格子的南墙（面向起点）
				if to_tile_data.get_custom_data("wall_north"):
					return true
			Vector2i.RIGHT: # 向右移动，检查目标格子的西墙（面向起点）
				if to_tile_data.get_custom_data("wall_east") or to_tile_data.get_custom_data("wall_west"):
					return true
			Vector2i.DOWN:  # 向下移动，检查目标格子的北墙（面向起点）
				if to_tile_data.get_custom_data("wall_south"):
					return true
			Vector2i.LEFT:  # 向左移动，检查目标格子的东墙（面向起点）
				if to_tile_data.get_custom_data("wall_west") or to_tile_data.get_custom_data("wall_east"):
					return true
	
	
	return false
