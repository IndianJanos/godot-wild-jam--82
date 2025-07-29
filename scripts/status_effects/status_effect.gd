extends Node2D
class_name StatusEffect

@export var max_cooldown: float = 4.0

var current_cooldown: float = 0.0
var target: Enemy

func _process(delta: float) -> void:
	current_cooldown += delta
	
	if current_cooldown >= max_cooldown:
		remove_effect()
		queue_free()

func remove_effect():
	push_warning("Override: ", name, ".remove_effect")
