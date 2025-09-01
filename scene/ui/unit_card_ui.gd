extends Button
class_name UnitCardUI

signal unit_selected(unit_resource:UnitResource)#选择角色信号
signal unit_deselected(unit_resource:UnitResource)#取消选择角色信号
signal unit_havered(unit_resource:UnitResource)#鼠标悬停信号

@onready var select_indicatior: TextureRect = $SelectIndicatior

var unit_resource:UnitResource
var is_selected:bool = false	#角色是否已经被选择

func _ready() -> void:
	pressed.connect(on_button_pressed)#监听按钮按下的信号
	mouse_entered.connect(on_mouse_entered)#监听鼠标悬停信号
	select_indicatior.visible = false
	AudioManager.register_button(self)

func set_up(unit_resource:UnitResource) -> void:#设置
	self.unit_resource = unit_resource	#本unit_resource等于传过来的unit_resource
	text = unit_resource.unit_name		#设置按钮的文字显示

func on_button_pressed() -> void:
	if is_selected:#如果角色已经被选择
		is_selected = false #那么已经被选择改为没有
		select_indicatior.visible = false	#✔符号隐藏
		unit_deselected.emit(unit_resource)	#发出取消选择的信号
	else:
		if GameManager.selected_player_resources.size() < GameManager.maximum_unit_count:#已选角色列表里的角色数量小于最大选择角色数
			unit_selected.emit(unit_resource)	#发射角色选择信号
			is_selected = true					#角色已经被选择
			select_indicatior.visible = true	#✔符号显示
	
	
func on_mouse_entered() -> void:#如果鼠标悬停
	unit_havered.emit(unit_resource)#发送鼠标悬停的信号


	
