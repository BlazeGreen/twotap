extends Camera2D

## Attach to the Player's Camera2D.
## Call shake(strength, duration) from anywhere to trigger it.

var shake_strength: float = 0.0
var shake_duration: float = 0.0
var rng := RandomNumberGenerator.new()


func _process(delta: float) -> void:
	if shake_duration > 0.0:
		shake_duration -= delta
		var falloff: float = shake_duration / max(shake_duration + delta, 0.001)
		offset = Vector2(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0)
		) * shake_strength * falloff
	else:
		offset = Vector2.ZERO


func shake(strength: float, duration: float) -> void:
	if strength >= shake_strength or shake_duration <= 0.0:
		shake_strength = strength
		shake_duration = duration
