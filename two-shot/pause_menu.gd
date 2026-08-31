extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXSlider


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	var bus_idx: int = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)


func _on_sfx_slider_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	panel.visible = get_tree().paused


func _on_resume_pressed() -> void:
	get_tree().paused = false
	panel.visible = false


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://start_menu.tscn")
