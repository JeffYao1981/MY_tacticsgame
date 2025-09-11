extends AdvancedEnemyAI

func get_attack_actions() -> Array[BaseAction]:
	return [unit.actions_manager.get_action("bow_action")]
