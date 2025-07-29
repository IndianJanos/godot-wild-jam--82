extends Area2D
class_name SpitProjectile

@export var packed_effect: PackedScene
@export var speed: float = 400.0

@onready var player: Player = get_node("../Player")

var target_position: Vector2

func _physics_process(delta: float) -> void:
	global_position += (target_position - global_position).normalized() * speed * delta
	if global_position.distance_to(target_position) < 4:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var effect: StatusEffect = packed_effect.instantiate()
		effect.target = body
		body.add_child(effect)
		player.prank(body)
		
	if body != player:
		queue_free()
