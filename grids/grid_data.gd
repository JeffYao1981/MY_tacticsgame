class_name GridData

var walkable:bool = true     	#网格是否可以移动
var occupied_unit:Unit = null	#occupied:占领网格的单位

func is_occupied_by_uint() -> bool:
	return occupied_unit != null
	
