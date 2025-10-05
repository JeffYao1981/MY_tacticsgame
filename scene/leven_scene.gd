extends Node

@onready var visual_layer: TileMapLayer = $Map/VisualLayer
@onready var state_machine: StateMachine = $StateMachine

@export var player_spawn_positions:Array[Node2D]


func _ready() -> void:
	GridManager.visual_layer = visual_layer
	#设置已经被创建出来的所有角色的网格属性
	GameManager.spawn_player_units()
	for unit: Unit in GameManager.player_units:
		GridManager.set_grid_walkable(unit.grid_position,false)
		GridManager.set_grid_occupied(unit.grid_position,unit)
	for unit:Unit in GameManager.enemy_units:
		GridManager.set_grid_walkable(unit.grid_position,false)
		GridManager.set_grid_occupied(unit.grid_position,unit)
		#设置敌方角色为障碍物，这里是回合开始时候的初始设置，可以动态设置这个参数，不然就很难做到选择阵营的不穿透
		GridManager.nav_layer.a_star.set_point_solid(unit.grid_position)
	
	#设置默认被选中的unit
	#if not GameManager.player_units.is_empty():
		#var unit:Unit = GameManager.player_units[0]
		#print("--------------------------------",unit.unit_name,"-----------------------------------------------")
		#PlayerActionManager.set_selected_unit(unit)
	
	state_machine.launch_state_machine()


#func _input(event):
	#if event.is_action_pressed("debug_key"):  # 设置一个调试按键
		#GridManager.debug_specific_case()
