extends MarginContainer
class_name UnitActionsUI


@export var action_card_ui_scene : PackedScene

@onready var action_container: HBoxContainer = $MarginContainer/ActionContainer

var selected_unit: Unit


func _ready() -> void:
	PlayerActionManager.unit_selected.connect(on_unit_selected)


func on_unit_selected(unit:Unit) ->void:
	if selected_unit == unit :
		return
	
	selected_unit = unit
	updata_unit_action_ui()

func updata_unit_action_ui() ->void:
	var actions_manager:ActionManager = selected_unit.actions_manager
	
	for node in action_container.get_children():
		node.queue_free()
		
	for action in actions_manager.actions:
		var action_card_ui:ActionCardUI = action_card_ui_scene.instantiate()
		action_container.add_child(action_card_ui)
		action_card_ui.set_up(action)
