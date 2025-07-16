extends Node
@onready var visual_layer: TileMapLayer = $VisualLayer



func _ready() -> void:
	GridManager.visual_layer = visual_layer
	var action = get_tree().current_scene.get_node("Unit").actions_manager.get_action("move_action")
	PlayerActionManager.set_selected_action(action)
	
