extends Interactable
class_name Tool

@export var deploy_range: float = 25.0
@export var packed_effect: PackedScene

@onready var player: Player = get_node("../Player")

var found: bool = false

func _ready():
	player.tool_count_on_map += 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var effect: StatusEffect = packed_effect.instantiate()
		effect.target = body
		body.add_child(effect)
		player.prank(body)
			
		queue_free()

func enabled_interact():
	player.switch_tool(self)

func use():
	var mouse_position = get_global_mouse_position()
	use_tool(mouse_position)

func use_tool(mouse_position: Vector2):
	push_warning("Override")

func deploy(mouse_position: Vector2, deployed_tool: Node2D):
	if mouse_position.distance_to(player.global_position) <= deploy_range:
		deployed_tool.global_position = mouse_position
		reparent(player.get_parent())
		enabled = true
		player.tool = null
		$CollisionPolygon2D.disabled = false
