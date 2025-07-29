extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@export var interact_distance: float = 100.0

@onready var game: Node2D = get_node("..")

@export var _missing_tool_count: int = 10

var missing_tool_count: int:
	get:
		return _missing_tool_count
	set(value):
		_missing_tool_count = value
		$CanvasLayer/Label.text = str(_missing_tool_count)
		if _missing_tool_count < 1:
			$CanvasLayer/Label.text = "YOU WON!"

var tool: Tool
var tool_count_on_map: int = 0

func _ready() -> void:
	missing_tool_count = _missing_tool_count

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if input_vector.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif input_vector.x > 0:
		$AnimatedSprite2D.flip_h = false
	
	if input_vector.length_squared() > 0:
		input_vector = input_vector.normalized()
		$AnimatedSprite2D.play("run")
	elif input_vector.length_squared() == 0:
		$AnimatedSprite2D.play("standing")
	velocity = input_vector * speed
	move_and_slide()
	
	var interactables = get_tree().get_nodes_in_group("interactable")
	
	for interactable in interactables:
		if interactable.global_position.distance_to(global_position) <= interact_distance && tool != interactable:
			interactable.get_node("Label").visible = true
		else:
			interactable.get_node("Label").visible = false
	
	if Input.is_action_just_pressed("interact"):
		_interact()
		
	if Input.is_action_just_pressed("use_tool") && tool != null:
		tool.use()
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _interact():
	var interactables = get_tree().get_nodes_in_group("interactable")
	var closest = null
	var min_dist = interact_distance
	
	for interactable in interactables:
		if interactable == tool:
			continue
		var dist = interactable.global_position.distance_to(global_position)
		if dist <= min_dist:
			min_dist = dist
			closest = interactable
	
	if closest:
		closest.interact()
			
func switch_tool(tool: Tool):
	if self.tool != null:
		self.tool.reparent(game)
		self.tool.global_position = global_position
		self.tool.enabled = true
		self.tool.get_node("CollisionPolygon2D").disabled = false
	
	self.tool = tool
	var tool_size = tool.get_node("Sprite2D").texture.get_size()
	tool.reparent(self)
	tool.global_position = Vector2(global_position.x + 5, global_position.y + 10)
	tool.enabled = false
	tool.get_node("CollisionPolygon2D").disabled = true

func prank(enemy: Enemy):
	if not enemy.is_pranked:
		enemy.is_pranked = true
		missing_tool_count -= 1
		tool_count_on_map -= 1
		enemy.get_node("Sprite2D").modulate = Color.BLACK
		if tool_count_on_map < 1:
			$CanvasLayer/Label.text = "YOU RAN OUT OF TOOLS LOSER!"
