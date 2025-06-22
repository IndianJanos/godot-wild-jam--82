extends CharacterBody2D
class_name Enemy

signal player_seen

@export var speed: float = 100.0
@export var patrol_points: Array[Vector2] = []
@export var cone_length: float = 50.0
@export var cone_angle: float = 90.0
@export var ray_count: int = 30
@export var vision_cone: Polygon2D
@export var pivot: Node2D
@export var max_step_cooldown: float = 1

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var target_node: Node2D = get_node("../Player")
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var current_step_cooldown: float = 0
var patrol_index: int = 0
var is_player_seen: bool = false
var is_moving: bool = true

func _ready():
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	player_seen.connect(_on_player_seen)  # Most már figyeli a jelet

	if patrol_points.size() > 0:
		nav_agent.target_position = patrol_points[patrol_index]

func _physics_process(_delta: float) -> void:
	update_vision_cone()

	if nav_agent.is_navigation_finished() and patrol_points.size() > 0:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		nav_agent.target_position = patrol_points[patrol_index]
		pivot.look_at(patrol_points[patrol_index])
	
	var direction = global_position.direction_to(nav_agent.get_next_path_position())
	nav_agent.velocity = direction * speed
	
	current_step_cooldown += _delta
		
	if current_step_cooldown >= max_step_cooldown:
		current_step_cooldown = 0
		audio_player.pitch_scale = randf_range(.5, 1.5)
		audio_player.play()

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = velocity.move_toward(safe_velocity, 100)
	if not is_moving:
		velocity = Vector2.ZERO
	move_and_slide()

func update_vision_cone():
	var points: Array[Vector2] = [Vector2.ZERO]
	var start_angle = -cone_angle / 2.0
	var angle_step = cone_angle / ray_count
	var origin = pivot.global_position
	var space_state = get_world_2d().direct_space_state

	var player_detected_this_frame = false

	for i in range(ray_count + 1):
		var angle_rad = deg_to_rad(start_angle + i * angle_step)
		var direction = Vector2.RIGHT.rotated(pivot.rotation + angle_rad)
		var target = origin + direction * cone_length

		var query = PhysicsRayQueryParameters2D.create(origin, target)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)

		var hit_point = result.position if result else target
		points.append(pivot.to_local(hit_point))

		if result and result.collider == target_node:
			player_detected_this_frame = true

	if player_detected_this_frame and not is_player_seen:
		is_player_seen = true
		player_seen.emit()

	vision_cone.color = Color.RED if player_detected_this_frame else Color.GREEN
	vision_cone.polygon = points

func _on_player_seen() -> void:
	print("Player seen, reloading scene...")
	get_tree().reload_current_scene()

func alert() -> void:
	nav_agent.target_position = target_node.global_position
	pivot.look_at(nav_agent.get_next_path_position())
