extends TileMapLayer
class_name NavLayer

var a_star: AStarGrid2D
var grid_data_dict: Dictionary[Vector2i,GridData] = {}
func _ready() -> void:
	initialize()
	GridManager.nav_layer = self
	


func initialize() -> void:
	a_star = CustomAStarGrid2D.new(self)#新建寻路
	a_star.region = get_used_rect()#寻路的范围等于tilemap的整体范围
	a_star.cell_size = tile_set.tile_size#网格的大小等于tilemap的大小
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER#不可以沿对角线移动
	
	a_star.update()
	
	var used_cells := get_used_cells()
	for cell in used_cells:
		grid_data_dict[cell] = GridData.new()
		if not get_cell_tile_data(cell).get_custom_data("walkable"):
			a_star.set_point_solid(cell)
			grid_data_dict[cell].walkable = false
			
