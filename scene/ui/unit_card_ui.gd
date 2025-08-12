extends Button
class_name UnitCardUI

signal unit_havered(unit_resource:UnitResource)

@onready var select_indicatior: TextureRect = $SelectIndicatior

var unit_resource:UnitResource
var is_selected:bool = false

func _ready() -> void:
	pressed.connect(on_button_pressed)
	mouse_entered.connect(on_mouse_entered)
	select_indicatior.visible = false

func set_up(unit_resource:UnitResource) -> void:
	self.unit_resource = unit_resource
	text = unit_resource.unit_name

func on_button_pressed() -> void:
	if is_selected:
		is_selected = false
		select_indicatior.visible = false
	else:
		is_selected = true
		select_indicatior.visible = true
	
	
func on_mouse_entered() -> void:
	unit_havered.emit(unit_resource)


	
