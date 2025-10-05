extends Node2D
class_name ActionUiLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EnemyIntentVisualizer.action_ui_layer = self
