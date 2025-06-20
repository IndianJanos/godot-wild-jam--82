extends Enemy

func _ready() -> void:
	super._ready()
	player_seen.connect(_on_player_seen)
	
func _on_player_seen() -> void:
	print("Game Over")
