extends PanelContainer

@onready var start_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/StartButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/BackButton
@onready var unit_card_container: VBoxContainer = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitSelection/UnitCardContainer
@onready var unit_icon: TextureRect = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitInfo/MarginContainer/VBoxContainer/IconName/UnitIcon
@onready var unit_name: Label = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitInfo/MarginContainer/VBoxContainer/IconName/UnitName
@onready var unit_description: Label = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitInfo/MarginContainer/VBoxContainer/UnitDescription

@export var unit_card_ui_scene: PackedScene
@export var unit_resources:Array[UnitResource]


func _ready() -> void:
	start_button.pressed.connect(on_start_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	for unit_resource in unit_resources:
		var unit_card_ui:UnitCardUI = unit_card_ui_scene.instantiate()
		unit_card_container.add_child(unit_card_ui)
		unit_card_ui.set_up(unit_resource)
		unit_card_ui.unit_havered.connect(on_unit_havered)

func on_start_button_pressed() -> void:
	pass
	
func on_back_button_pressed() -> void:
	pass
	
func on_unit_havered(unit_resource:UnitResource) -> void:
	unit_icon.texture = unit_resource.unit_icon
	unit_name.text = unit_resource.unit_name
	unit_description.text = unit_resource.unit_description
