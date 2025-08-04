extends Node2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var action_point_label: Label = $ActionPointLabel


@export var unit:Unit
@export var health:Health


func _ready() -> void:
	health.health_changed.connect(on_health_changed)
	unit.action_point_changed.connect(on_action_points_changed)
	call_deferred("initialize")
	
	
func initialize() -> void:
	health_bar.min_value = 0.0
	health_bar.max_value = health.max_health
	health_bar.value = health.current_health
	
func on_health_changed(health_point:int) -> void:
	health_bar.value = health_point


func on_action_points_changed(action_points:int) -> void:
	action_point_label.text = str(action_points)
