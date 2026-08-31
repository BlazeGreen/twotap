extends CharacterBody2D

## =========================================================
##  DOUBLE BARREL MOVEMENT
##  Two shells. Firing launches you opposite your aim direction.
##  Touching the ground refills both shells. That's the whole game.
## =========================================================

## --- Tunables (tweak these first when play-testing) ---
@export var gravity: float = 1400.0
@export var recoil_strength: float = 900.0
@export var air_drag: float = 0.995        # 1.0 = no drag, lower = more air resistance
@export var max_shells: int = 2            # the "double" in double-barrel
@export var fire_cooldown: float = 0.15    # prevents one click firing both shells at once
@export var void_y: float = 2000.0         # Y position below which player is caught & reset

var shells_left: int = max_shells
var can_fire: bool = true
var aim_dir: Vector2 = Vector2.UP
var was_in_air: bool = false
var spawn_point: Vector2

@onready var shell_label: Label = $ShellLabel
@onready var barrel: Node2D = $Barrel
@onready var camera: Camera2D = $Camera2D
@onready var muzzle_particles: GPUParticles2D = $Barrel/MuzzleParticles
@onready var land_particles: GPUParticles2D = $LandParticles


func _ready() -> void:
	spawn_point = global_position
	_update_ui()


func _physics_process(delta: float) -> void:
	# safety net: caught the void, teleport back, skip rest of this frame
	if global_position.y > void_y:
		_fell_in_void()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
		velocity *= air_drag
	else:
		if was_in_air:
			_on_land()
		if shells_left < max_shells:
			shells_left = max_shells
			_update_ui()

	was_in_air = not is_on_floor()

	# aim toward mouse
	aim_dir = (get_global_mouse_position() - global_position).normalized()
	if barrel:
		barrel.rotation = aim_dir.angle()

	if Input.is_action_just_pressed("fire") and can_fire and shells_left > 0:
		_fire()

	move_and_slide()


func _fire() -> void:
	shells_left -= 1
	can_fire = false

	var recoil_vec: Vector2 = -aim_dir * recoil_strength
	velocity += recoil_vec

	_update_ui()
	_muzzle_flash()

	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true


func _update_ui() -> void:
	if shell_label:
		shell_label.text = "Shells: %d / %d" % [shells_left, max_shells]


func _muzzle_flash() -> void:
	if camera:
		camera.shake(14.0, 0.2)
	if muzzle_particles:
		muzzle_particles.emitting = true
	_hit_stop(0.06, 0.05)


func _on_land() -> void:
	if camera:
		camera.shake(8.0, 0.15)
	if land_particles:
		land_particles.emitting = true


func _hit_stop(duration: float, time_scale: float) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale, true, false, true).timeout
	Engine.time_scale = 1.0


func _fell_in_void() -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO
	shells_left = max_shells
	_update_ui()
