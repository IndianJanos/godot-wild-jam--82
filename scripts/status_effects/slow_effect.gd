extends StatusEffect

@export var strength: float = 3

func _ready() -> void:
	target.speed /= strength

func remove_effect():
	target.speed *= strength
