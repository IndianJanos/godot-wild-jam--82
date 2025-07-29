extends StatusEffect

@export var strength: float = 3

var original_vision_length: float

func _ready() -> void:
	original_vision_length = target.cone_length
	target.cone_length = 0

func remove_effect():
	target.cone_length = original_vision_length
