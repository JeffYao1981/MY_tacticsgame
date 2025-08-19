## 自定义的AStarGrid2D类，支持边界墙检测
#class_name CustomAStarGrid2D
#extends AStarGrid2D
#
#var tilemap_layer: TileMapLayer
#
#func _init(tilemap_layer_ref: TileMapLayer):
	#tilemap_layer = tilemap_layer_ref
#
## 重写这个方法来控制两点间的移动代价
#func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	## 首先检查墙壁障碍
	#if has_movement_barrier(from_id, to_id):
		#return INF
	#
	## 然后检查网格占用情况
	##var unit = GridManager.get_grid_occupied(to_id)
	##if unit != null:
		##if unit.is_enemy:
			##return INF
		##else:
			##return 1.0
	#
	## 检查是否被设置为固体点
	#if is_point_solid(to_id):
		#return INF
	#
	## 否则返回正常代价
	#return 1.0
#
## 重写估算代价方法
#func _estimate_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	## 使用曼哈顿距离作为启发式
	#return abs(to_id.x - from_id.x) + abs(to_id.y - from_id.y)
#
## 检查两个相邻格子间是否有移动障碍
#func has_movement_barrier(from: Vector2i, to: Vector2i) -> bool:
	#var direction = to - from
	#
	## 只检查相邻格子（防止对角线等情况）
	#if abs(direction.x) + abs(direction.y) != 1:
		#return false
	#
	## 检查起点格子是否有墙阻挡向外移动
	#var from_tile_data = tilemap_layer.get_cell_tile_data(from)
	#if from_tile_data:
		#match direction:
			#Vector2i.UP:
				#if from_tile_data.get_custom_data("wall_north"):
					#return true
			#Vector2i.RIGHT:
				#if from_tile_data.get_custom_data("wall_east"):
					#return true
			#Vector2i.DOWN:
				#if from_tile_data.get_custom_data("wall_south"):
					#return true
			#Vector2i.LEFT:
				#if from_tile_data.get_custom_data("wall_west"):
					#return true
	#
	## 检查目标格子是否有墙阻挡从外面进入
	#var to_tile_data = tilemap_layer.get_cell_tile_data(to)
	#if to_tile_data:
		#match direction:
			#Vector2i.UP:    # 向上移动，检查目标格子的南墙
				#if to_tile_data.get_custom_data("wall_south"):
					#return true
			#Vector2i.RIGHT: # 向右移动，检查目标格子的西墙
				#if to_tile_data.get_custom_data("wall_west"):
					#return true
			#Vector2i.DOWN:  # 向下移动，检查目标格子的北墙
				#if to_tile_data.get_custom_data("wall_north"):
					#return true
			#Vector2i.LEFT:  # 向左移动，检查目标格子的东墙
				#if to_tile_data.get_custom_data("wall_east"):
					#return true
	#
	#return false
#
## 安全地设置某个点为障碍物，同时保持墙壁检测
#func set_cell_obstacle(cell: Vector2i, is_obstacle: bool):
	#set_point_solid(cell, is_obstacle)
#
## 检查某个单元格是否可以移动到（综合考虑墙壁和障碍物）
#func is_cell_passable(from: Vector2i, to: Vector2i) -> bool:
	## 检查边界 - 手动检查是否在网格范围内
	#if to.x < 0 or to.y < 0 or to.x >= size.x or to.y >= size.y:
		#return false
	#
	## 检查墙壁
	#if has_movement_barrier(from, to):
		#return false
	#
	## 检查固体点
	#if is_point_solid(to):
		#return false
	#
	## 检查单位占用
	#var unit = GridManager.get_grid_occupied(to)
	#if unit != null and unit.is_enemy:
		#return false
	#
	#return true
	
# 自定义的AStarGrid2D类，支持边界墙检测
class_name CustomAStarGrid2D
extends AStarGrid2D

var tilemap_layer: TileMapLayer

func _init(tilemap_layer_ref: TileMapLayer):
	tilemap_layer = tilemap_layer_ref

# 重写这个方法来控制两点间的移动代价
func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	# 首先检查墙壁障碍
	if has_movement_barrier(from_id, to_id):
		return INF
	
	# 检查是否被设置为固体点（包括通过set_cell_obstacle设置的障碍）
	if is_point_solid(to_id):
		return INF
	
	# 否则返回正常代价
	return 1.0

# 重写估算代价方法
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
	var to_tile_data = tilemap_layer.get_cell_tile_data(to)
	if to_tile_data:
		match direction:
			Vector2i.UP:    # 向上移动，检查目标格子的南墙
				if to_tile_data.get_custom_data("wall_south"):
					return true
			Vector2i.RIGHT: # 向右移动，检查目标格子的西墙
				if to_tile_data.get_custom_data("wall_west"):
					return true
			Vector2i.DOWN:  # 向下移动，检查目标格子的北墙
				if to_tile_data.get_custom_data("wall_north"):
					return true
			Vector2i.LEFT:  # 向左移动，检查目标格子的东墙
				if to_tile_data.get_custom_data("wall_east"):
					return true
	
	return false

# 安全地设置某个点为障碍物，同时保持墙壁检测
func set_cell_obstacle(cell: Vector2i, is_obstacle: bool):
	set_point_solid(cell, is_obstacle)
