extends Camera2D



func _ready() -> void:
	var tilemap:= GridManager.nav_layer
	
	var used_rect = tilemap.get_used_rect()
	var top_left = tilemap.map_to_local(used_rect.position) - Vector2(16,16)
	var bottom_right = tilemap.map_to_local(used_rect.position + used_rect.size) - Vector2(16,16)
	

	# 打印调试信息
	print("=== 调试信息 ===")
	print("used_rect.position: ", used_rect.position)
	print("used_rect.size: ", used_rect.size)
	print("top_left(世界坐标): ", top_left)
	print("bottom_right(世界坐标): ", bottom_right)
	
	
	# 设置摄像机限制
	limit_left = int(top_left.x)
	limit_top = int(top_left.y)
	limit_right = int(bottom_right.x)
	limit_bottom = int(bottom_right.y)
	
	# 打印最终限制
	print("limit_left: ", limit_left)
	print("limit_top: ", limit_top)
	print("limit_right: ", limit_right)
	print("limit_bottom: ", limit_bottom)
	print("================")
	#limit_left = int(top_left.x + half_width)
	#limit_top = int(top_left.y + half_height)
	#limit_right = int(bottom_right.x - half_width)
	#limit_bottom = int(bottom_right.y - half_height)
