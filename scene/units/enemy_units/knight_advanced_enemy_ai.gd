extends AdvancedEnemyAI

func think() -> AIActionData:
	var ai_action_data:AIActionData = AIActionData.new()
	if try_perform_attack_action(unit.actions_manager.get_action("sword_action"),ai_action_data):
		return ai_action_data
	elif try_preform_move_action(unit.actions_manager.get_action("sword_action"),ai_action_data):
		return ai_action_data
	return null
