extends Button
class_name ActionCardUI
@onready var texture_rect: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var action:BaseAction

func _ready() -> void:
	AudioManager.register_button(self)
	pressed.connect(on_action_selected)

func set_up(action:BaseAction) -> void:
	self.action = action
	#text = action.action_name
	texture_rect.texture = action.action_icon
	#
	


func on_action_selected() -> void:
	PlayerActionManager.set_selected_action(action)
