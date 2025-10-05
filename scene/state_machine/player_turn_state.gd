extends BaseState







func on_state_enter() -> void:
	TurnManager.玩家回合发射信号()
	TurnManager.敌人攻击回合.connect(on_enemy_execute_started)
	listen_for_input = true
	go_to_next_turn = false

func on_state_frame_update(delta:float) -> void:
	if go_to_next_turn:
		change_state("EnemyExecuteState")
	
func on_state_exit() -> void:
	TurnManager.敌人攻击回合.disconnect(on_enemy_execute_started)
	
	listen_for_input = false
	print("我已经触发了，目前输入监听为：",listen_for_input)

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
	go_to_next_turn = true	
	
