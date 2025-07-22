extends Node

@onready var visual_layer: TileMapLayer = $VisualLayer
@onready var state_machine: StateMachine = $StateMachine



func _ready() -> void:
	GridManager.visual_layer = visual_layer
	
	for unit: Unit in GameManager.player_units:
		GridManager.set_grid_walkable(unit.grid_position,false)
		GridManager.set_grid_occupied(unit.grid_position,unit)
	for unit:Unit in GameManager.enemy_units:
		GridManager.set_grid_walkable(unit.grid_position,false)
		GridManager.set_grid_occupied(unit.grid_position,unit)
	
	if not GameManager.player_units.is_empty():
		var unit:Unit = GameManager.player_units[0]
		PlayerActionManager.set_selected_unit(unit)
	
	state_machine.launch_state_machine()
