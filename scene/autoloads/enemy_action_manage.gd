extends Node


var is_performing_action: bool = false

func try_perform_ai_action() -> void:
	if is_performing_action:
		return
	
	if not try_perform_action():
		TurnManager.start_player_turn()   



func try_perform_action() -> bool:
	for enemy:Unit in GameManager.enemy_units:
		if try_perform_enemy_action(enemy):
			return true
	return false		


func try_perform_enemy_action(enemy:Unit) ->bool:
	var enemy_ai:EnemyAI = enemy.get_node_or_null("EnemyAI")
	if  enemy_ai == null :
		return false
	
	var ai_action_data:AIActionData = enemy_ai.think()
	if ai_action_data == null:
		return false
	
	is_performing_action = true
	ai_action_data.action.start_action(ai_action_data.grid_position,on_action_finished)
	
	return true
	
	 
func on_action_finished() -> void:
	is_performing_action = false
