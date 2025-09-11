extends BaseState



var listen_for_input: bool = false
var go_to_enemy_execute: bool = false


func on_state_enter() -> void:
	
	
	TurnManager.enemy_execute_started.connect(on_enemy_execute_started)
	listen_for_input = true
	go_to_enemy_execute = false

func on_state_frame_update(delta:float) -> void:
	if go_to_next_turn:
		change_state("EnemyExecuteState")
	
func on_state_exit() -> void:
	TurnManager.enemy_execute_started.disconnect(on_enemy_execute_started)
	listen_for_input = false

func _unhandled_input(event: InputEvent) -> void:
	if not listen_for_input :
		return
	
	if event.is_action_pressed("left_mouse_click"):
		PlayerActionManager.try_perform_selected_action()
	if event.is_action_pressed("right_mouse_click"):
		PlayerActionManager.try_cancel_selected_action()


#func on_enemy_turn_started() ->void:
	#if PlayerActionManager.is_performing_action:
		#return
	#go_to_next_turn = true
	
func on_enemy_execute_started() -> void:
	# 如果玩家还在执行动作，不强行切换
	if PlayerActionManager.is_performing_action:
		return
	go_to_enemy_execute = true	
	
