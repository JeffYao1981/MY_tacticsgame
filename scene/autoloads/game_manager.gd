extends Node

var player_units:Array[Unit]
var enemy_units:Array[Unit]


func register_unit(unit:Unit) -> void:
	if unit.is_enemy:
		enemy_units.append(unit)
	else:
		player_units.append(unit)


func unregister_unit(unit:Unit) ->void:
	if unit.is_enemy:
		enemy_units.erase(unit)
	else:
		player_units.erase(unit)
		if PlayerActionManager.selected_unit == unit and not player_units.is_empty():
			PlayerActionManager.set_selected_unit(player_units[0])
		
