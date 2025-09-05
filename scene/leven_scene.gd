extends Node

@onready var visual_layer: TileMapLayer = $Map/VisualLayer
@onready var state_machine: StateMachine = $StateMachine

@export var player_spawn_positions:Array[Node2D]


func _ready() -> void:
	GridManager.visual_layer = visual_layer
	
	GameManager.spawn_player_units()
	for unit: Unit in GameManager.player_units:
		GridManager.set_grid_walkable(unit.grid_position,false)
		GridManager.set_grid_occupied(unit.grid_position,unit)
	for unit:Unit in GameManager.enemy_units:
		GridManager.set_grid_walkable(unit.grid_position,false)
		GridManager.set_grid_occupied(unit.grid_position,unit)
		GridManager.nav_layer.a_star.set_point_solid(unit.grid_position)
	
	if not GameManager.player_units.is_empty():
		var unit:Unit = GameManager.player_units[0]
		PlayerActionManager.set_selected_unit(unit)
	
	state_machine.launch_state_machine()


#func _input(event):
	#if event.is_action_pressed("debug_key"):  # 设置一个调试按键
		#GridManager.debug_specific_case()
