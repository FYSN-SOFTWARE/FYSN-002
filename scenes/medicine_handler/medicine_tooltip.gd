class_name MedicineTooltip
extends Control

const Y_OFFSET := 8.0

@onready var title_label: Label = %TitleLabel
@onready var desc_text: RichTextLabel = %DescText

var Icon_end_y: float

var is_options_show: bool = false

func _ready() -> void:
	visible = false
	hide()
	
func _process(delta: float) -> void:
	if not visible or is_options_show:
		return
	
	var wanted_y = Icon_end_y + Y_OFFSET
	var wanted_x = get_global_mouse_position().x - size.x * 0.5
	global_position = Vector2(wanted_x,wanted_y)
	
func show_tooltip(medicine: Medicine,icon_end_y: float) -> void:
	title_label.text = medicine.medicine_name
	desc_text.text = medicine.get_tooltip()
	Icon_end_y = icon_end_y
	visible = true
	show()
	
func show_with_options(medicine: Medicine,medicine_option:MedicineUseSelect) -> void:
	is_options_show = true
	
	var choice_box_rec = medicine_option.get_rect()
	var right = medicine_option.offset_right
	var x = right + 10
	var y = medicine_option.offset_top
	
	position = Vector2(x,y)
	
func hide_tooltip():
	is_options_show = false
	visible = false
	hide()
