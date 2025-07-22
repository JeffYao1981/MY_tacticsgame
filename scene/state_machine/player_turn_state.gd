extends BaseState

var listen_for_input: bool = false

func on_state_enter() -> void:
	print(state_name + "enter")
	listen_for_input = true
	
func on_state_exit() -> void:
	listen_for_input = false

func _unhandled_input(event: InputEvent) -> void:
	if not listen_for_input :
		return
	
	if event.is_action_pressed("left_mouse_click"):
		PlayerActionManager.try_perform_selected_action()
