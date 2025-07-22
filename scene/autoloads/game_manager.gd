extends Node

var player_units:Array[Unit]
var enemy_units:Array[Unit]


func register_unit(unit:Unit) -> void:
	if unit.is_enemy:
		enemy_units.append(unit)
	else:
		player_units.append(unit)
