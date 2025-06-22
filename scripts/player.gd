extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@export var interact_distance: float = 100.0

@onready var game: Node2D = get_node("..")

var tool: Tool

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
	
	if Input.is_action_just_pressed("interact"):
		_interact()

func _interact():
	var interactables = get_tree().get_nodes_in_group("interactable")
	
	for interactable in interactables:
		if interactable.global_position.distance_to(global_position) <= interact_distance:
			interactable.interact()
			
func switch_tool(tool: Tool):
	if self.tool != null:
		self.tool.reparent(game)
		self.tool.global_position = global_position
		self.tool.get_node("CollisionShape2D").disabled = true
		self.tool.enabled = true
	
	self.tool = tool
	var tool_size = tool.get_node("Sprite2D").texture.get_size()
	tool.reparent(self)
	tool.global_position = Vector2(global_position.x, global_position.y + 85)
	tool.enabled = false
