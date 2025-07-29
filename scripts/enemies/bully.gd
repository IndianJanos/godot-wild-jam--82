extends Enemy
	
func _on_player_seen() -> void:
	get_tree().reload_current_scene()

func alert() -> void:
	nav_agent.target_position = target_node.global_position
	pivot.look_at(nav_agent.get_next_path_position())
