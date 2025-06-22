extends Interactable
class_name Tool

@onready var player: Player = get_node("../Player")

func enabled_interact():
	player.switch_tool(self)
