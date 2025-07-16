extends Node
class_name ActionManager

var actions:Array[BaseAction]


func _ready() -> void:
	for action: BaseAction in get_children():
		actions.append(action)
		
		
func get_action(action_id:String) -> BaseAction:
	var results = actions.filter(func(action:BaseAction):return action.action_id == action_id)
	if results and not results.is_empty():
		return results[0]
	return null
	
