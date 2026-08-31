extends Control

@export var message: String = "Placeholder text"
@export var next_scene_path: String = "res://start_menu.tscn"
@export var button_text: String = "Continue"

@onready var label: Label = $VBoxContainer/MessageLabel
@onready var button: Button = $VBoxContainer/ContinueButton


func _ready() -> void:
	label.text = message
	button.text = button_text
	button.pressed.connect(_on_continue_pressed)


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)
