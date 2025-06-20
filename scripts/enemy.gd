extends CharacterBody2D

@export var speed: float = 100.0
@export var target_node: NodePath
@export var patrol_points: Array[Vector2] = []
@export var cone_length: float = 200.0
@export var cone_angle: float = 90.0
@export var ray_count: int = 60
@export var vision_cone: Polygon2D
@export var pivot: Node2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = get_node(target_node)

var patrol_index: int = 0
var player_seen: bool = false

func _ready():
	nav_agent.velocity_computed.connect(_on_velocity_computed)

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

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = velocity.move_toward(safe_velocity, 100)
	move_and_slide()

func update_vision_cone():
	var points: Array[Vector2] = [Vector2.ZERO]
	var start_angle = -cone_angle / 2.0
	var angle_step = cone_angle / ray_count
	var origin = pivot.global_position
	var space_state = get_world_2d().direct_space_state

	player_seen = false

	for i in range(ray_count + 1):
		var angle_rad = deg_to_rad(start_angle + i * angle_step)
		var direction = Vector2.RIGHT.rotated(pivot.rotation + angle_rad)
		var target = origin + direction * cone_length

		var query = PhysicsRayQueryParameters2D.create(origin, target)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)

		var hit_point = result.position if result else target
		points.append(pivot.to_local(hit_point))

		if result and result.collider == player:
			player_seen = true

	vision_cone.color = Color.RED if player_seen else Color.GREEN
	vision_cone.polygon = points
