extends EnemyAI


#func get_attack_actions() -> Array[BaseAction]:
	#return [unit.actions_manager.get_action("bow_action")]


func get_attack_actions() -> Array[BaseAction]:
	var bow = unit.actions_manager.get_action("bow_action")
	if bow == null:
		print("⚠️", unit.name, "没有 bow_action")
		return []
	return [bow]
