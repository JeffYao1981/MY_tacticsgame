extends Button
class_name ActionCardUI


var action:BaseAction

func _ready() -> void:
	pressed.connect(on_action_selected)

func set_up(action:BaseAction) -> void:
	self.action = action
	text = action.action_name


func on_action_selected() -> void:
	PlayerActionManager.set_selected_action(action)
