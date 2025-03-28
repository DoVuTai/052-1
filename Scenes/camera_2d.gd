extends Camera2D

var rnd_strength: float = 30
var shake_fade: float = 5

var rng = RandomNumberGenerator.new()
var shake_strength:float = 0
var obj_shake: Node

func apply_shake(obj: Node):
	shake_strength = rnd_strength
	obj_shake = obj
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade*delta)
		obj_shake.offset = randomOffset()

func randomOffset():
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
