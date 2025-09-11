extends Resource
class_name AIActionData


var action:BaseAction
var unit:Unit
var target_grid: Vector2i
var target: Unit = null
var grid_position:Vector2i

var predicted_knockback:Vector2i = Vector2i.ZERO


func _init(_unit: Unit, _action: BaseAction, _target: Vector2i):
	unit = _unit
	action = _action
	grid_position = _target
