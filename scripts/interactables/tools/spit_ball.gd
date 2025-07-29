extends Tool

@export var packed_spit_projectile: PackedScene

func use_tool(mouse_position: Vector2):
	var spit_projectile: Node2D = packed_spit_projectile.instantiate()
	spit_projectile.target_position = get_global_mouse_position()
	get_node("../..").add_child(spit_projectile)
	spit_projectile.global_position = get_parent().global_position
	queue_free()
