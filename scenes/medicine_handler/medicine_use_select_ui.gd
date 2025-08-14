class_name MedicineUseSelect
extends VBoxContainer

@export var slot_index:int :set = set_index

@onready var use_button: Button = %UseButton
@onready var drop_button: Button = %DropButton

func _ready() -> void:
	hide()

func set_index(value:int):
	if not is_node_ready():
		await ready
	slot_index = value
	#print("index::",slot_index)	

func show_options():
	show()
	
func hide_options():
	hide()

func _on_use_button_pressed() -> void:
	Events.medicine_use_requested.emit(slot_index)


func _on_drop_button_pressed() -> void:
	Events.medicine_discard_requested.emit(slot_index)
