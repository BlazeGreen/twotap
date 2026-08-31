extends Camera2D

var shake_strength: float = 0.0
var shake_duration: float = 0.0
var shake_total_duration: float = 0.0
var rng := RandomNumberGenerator.new()


func _process(delta: float) -> void:
	if shake_duration > 0.0:
		shake_duration -= delta
		var t: float = clamp(shake_duration / shake_total_duration, 0.0, 1.0)
		var falloff: float = t * t   # squared - dies out much faster near the end, kills tail jitter
		if shake_strength * falloff < 0.3:
			# amplitude is negligible - cut it off hard instead of letting tiny random jitter continue
			shake_duration = 0.0
			offset = Vector2.ZERO
			return
		var target: Vector2 = Vector2(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0)
		) * shake_strength * falloff
		offset = offset.lerp(target, 0.6)
	else:
		offset = Vector2.ZERO


func shake(strength: float, duration: float) -> void:
	if strength >= shake_strength or shake_duration <= 0.0:
		shake_strength = strength
		shake_duration = duration
		shake_total_duration = duration
