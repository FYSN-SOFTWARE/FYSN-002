extends Control

const CHAR_SELECTOR_SCENE := preload("res://scenes/ui/character_selector.tscn")
const RUN_SCENE = preload("res://scenes/run/run.tscn")

@export var run_startup: RunStartup
@onready var continue_button: Button = %Continue
@onready var new_run_button: Button = %NewRun
@onready var exit_button: Button = %Exit

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var hover_duration: float = 0.2
@export var hover_color: Color = Color(0.9, 0.9, 1.0)
var normal_color: Color

func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null
	$AudioStreamPlayer.play()

func _on_continue_pressed() -> void:
	run_startup.type = RunStartup.Type.CONTINUED_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_packed(CHAR_SELECTOR_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
