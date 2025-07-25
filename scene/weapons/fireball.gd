extends Projectile

var damage_radius:int = 1

func deal_damage() -> void:
	for i in range(-damage_radius,damage_radius + 1) :
		for j in range(-damage_radius,damage_radius + 1):
			var potential_grid:Vector2i = target_grid_position + Vector2i (i,j)
			var target:Unit = GridManager.get_grid_occupied(potential_grid)
			if target and target.is_enemy != unit.is_enemy :
				target.take_damage(damage_amount)
