extends EnemyAI

#"fireball_action"
func get_attack_actions() -> Array[BaseAction]:
	return [unit.actions_manager.get_action("fireball_action")]



'''法师 AI（会火球，也会剑）
func get_attack_actions() -> Array[BaseAction]:
	return [
		unit.actions_manager.get_action("fireball_action"),
		unit.actions_manager.get_action("sword_action")
	]'''
