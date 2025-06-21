extends Enemy

func _ready() -> void:
	super._ready()
	player_seen.connect(_on_player_seen)
	
func _on_player_seen() -> void:
	print("Game Over")

func alert() -> void:
	nav_agent.target_position = target_node.global_position
	pivot.look_at(nav_agent.get_next_path_position())
