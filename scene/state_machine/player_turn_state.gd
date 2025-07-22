extends BaseState

var listen_for_input: bool = false
var go_to_enemy_turn:bool = false


func on_state_enter() -> void:
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	listen_for_input = true
	go_to_enemy_turn = false

func on_state_frame_update(delta:float) -> void:
	if go_to_enemy_turn:
		state_changed.emit("EnemyTurnState")

	
func on_state_exit() -> void:
	TurnManager.enemy_turn_started.disconnect(on_enemy_turn_started)
	listen_for_input = false

func _unhandled_input(event: InputEvent) -> void:
	if not listen_for_input :
		return
	
	if event.is_action_pressed("left_mouse_click"):
		PlayerActionManager.try_perform_selected_action()


func on_enemy_turn_started() ->void:
	if PlayerActionManager.is_performing_action:
		return
	go_to_enemy_turn = true
	
