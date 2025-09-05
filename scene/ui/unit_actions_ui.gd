extends MarginContainer
class_name UnitActionsUI


@export var action_card_ui_scene : PackedScene

@onready var action_container: HBoxContainer = $MarginContainer/ActionContainer
var actions_manager:ActionManager
var selected_unit: Unit


func _ready() -> void:
	PlayerActionManager.unit_selected.connect(on_unit_selected)
	


func on_unit_selected(unit:Unit) ->void:
	if selected_unit == unit :
		return
	
	selected_unit = unit
	actions_manager = selected_unit.actions_manager
	
	updata_unit_action_ui()
	

	

func clear_action_card() ->void:
	for node in action_container.get_children():
		
		node.queue_free()

func add_action_card() ->void:
	
	for action in actions_manager.actions:
		action.clear_action_card.connect(clear_action_card)
		action.add_action_card.connect(add_action_card)
		var action_card_ui:ActionCardUI = action_card_ui_scene.instantiate()
		action_container.add_child(action_card_ui)
		action_card_ui.set_up(action)	
	global_position = selected_unit.position + Vector2(-36,-58)



func updata_unit_action_ui() ->void:
	
	
	
	clear_action_card()
	
	add_action_card()
		
	
	
	#for node in action_container.get_children():
		#print("节点里面包含了：",node.action.action_name)
