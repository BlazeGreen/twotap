extends CharacterBody2D

@export var gravity: float = 1400.0
@export var recoil_strength: float = 900.0
@export var air_drag: float = 0.995
@export var max_shells: int = 2
@export var fire_cooldown: float = 0.15
@export var void_y: float = 2000.0
@export var ground_friction: float = 1400.0
@export var wall_bounce_loss: float = 500.0

var shells_left: int = max_shells
var can_fire: bool = true
var is_reloading: bool = false
var can_play_hit: bool = true
var was_touching_surface: bool = false
var aim_dir: Vector2 = Vector2.UP
var was_in_air: bool = false
var spawn_point: Vector2

@onready var barrel: Node2D = $Barrel
@onready var camera: Camera2D = $Camera2D
@onready var gun_sprite: AnimatedSprite2D = $Barrel/GunSprite
@onready var fire_sound: AudioStreamPlayer = $FireSound
@onready var reload_sound: AudioStreamPlayer = $ReloadSound
@onready var hit_sound: AudioStreamPlayer = $HitSound


func _ready() -> void:
	spawn_point = global_position
	if gun_sprite:
		gun_sprite.animation_finished.connect(_on_gun_animation_finished)


func _physics_process(delta: float) -> void:
	if global_position.y > void_y:
		_fell_in_void()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
		velocity *= air_drag
	else:
		velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
		if was_in_air:
			_on_land()
		if shells_left < max_shells:
			shells_left = max_shells

	was_in_air = not is_on_floor()

	aim_dir = (get_global_mouse_position() - global_position).normalized()
	if barrel:
		barrel.rotation = aim_dir.angle()

	if Input.is_action_just_pressed("fire") and can_fire and not is_reloading and shells_left > 0:
		_fire()

	var velocity_before_move: Vector2 = velocity
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var normal: Vector2 = collision.get_normal()
		if normal.y > -0.5:
			velocity.x = move_toward(-velocity_before_move.x, 0.5, wall_bounce_loss)

	var touching_surface: bool = is_on_floor() or is_on_wall() or is_on_ceiling()
	if touching_surface and not was_touching_surface and can_play_hit and hit_sound:
		hit_sound.play()
		can_play_hit = false
		await get_tree().create_timer(0.2).timeout
		can_play_hit = true
	was_touching_surface = touching_surface


func _fire() -> void:
	shells_left -= 1
	can_fire = false

	var recoil_vec: Vector2 = -aim_dir * recoil_strength
	velocity += recoil_vec

	_muzzle_flash()

	if fire_sound:
		fire_sound.play()

	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true

func _muzzle_flash() -> void:
	if camera:
		camera.shake(14.0, 0.2)
	if gun_sprite:
		gun_sprite.play("fire")
	_hit_stop(0.06, 0.05)


func _on_land() -> void:
	if camera:
		camera.shake(8.0, 0.15)
	if gun_sprite:
		is_reloading = true
		gun_sprite.play("reload")
	if reload_sound:
		reload_sound.play()


func _on_gun_animation_finished() -> void:
	if gun_sprite.animation == "reload":
		is_reloading = false
	gun_sprite.play("idle")


func _hit_stop(duration: float, time_scale: float) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func _fell_in_void() -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO
	shells_left = max_shells
