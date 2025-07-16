class_name GridData

var walkable:bool = true     	#网格是否可以移动
var occupied_unit:Unit = null	#网格上是否有单位occupied:占领

func is_occupied_by_uint() -> bool:
	return occupied_unit != null
	
