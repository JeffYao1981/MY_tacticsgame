extends Projectile

var damage_radius:int = 1

func deal_damage() -> void:
	for i in range(-damage_radius,damage_radius + 1) :
		for j in range(-damage_radius,damage_radius + 1):
			var potential_grid:Vector2i = target_grid_position + Vector2i (i,j)
			var target:Unit = GridManager.get_grid_occupied(potential_grid)
			if target and target.is_enemy != unit.is_enemy :
				target.take_damage(damage_amount)
				
				   # 在每个目标位置生成效果
			if impact_effect_scene != null:
				print("爆炸来了")
				var impact_effect: Node2D = impact_effect_scene.instantiate()
				get_tree().current_scene.add_child(impact_effect)
				impact_effect.global_position = GridManager.get_world_position(potential_grid)
