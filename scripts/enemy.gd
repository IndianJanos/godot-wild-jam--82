extends CharacterBody2D

@export var speed: float = 100.0
@export var target_node: NodePath
@export var nav_region_path: NodePath
@export var patrol_points: Array[Vector2] = []
@export var cone_length: float = 200.0
@export var cone_angle: float = 90.0
@export var ray_count: int = 30

@onready var vision_cone := $Polygon2D
@onready var player := get_node("../Player")

var path: PackedVector2Array = []
var path_index := 0
var patrol_index := 0
var chasing := false

func _ready():
	update_path_to(patrol_points[patrol_index])

func _physics_process(delta: float):
	update_vision_cone()

	var player = get_node(target_node)

	if is_player_visible(player):
		if not chasing:
			chasing = true
		update_path_to(player.global_position)
	elif not chasing and path_index >= path.size():
		patrol_index = (patrol_index + 1) % patrol_points.size()
		update_path_to(patrol_points[patrol_index])
		vision_cone.look_at(patrol_points[patrol_index])

	move_along_path()

func move_along_path():
	if path_index >= path.size():
		velocity = Vector2.ZERO
		return

	var target_pos = path[path_index]
	var direction = (target_pos - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(target_pos) < 4.0:
		path_index += 1

func update_path_to(target_pos: Vector2):
	var nav_region = get_node(nav_region_path) as NavigationRegion2D
	var map = nav_region.get_navigation_map()
	path = NavigationServer2D.map_get_path(map, global_position, target_pos, false)
	path_index = 0

func is_player_visible(player: Node2D) -> bool:
	var space = get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	var result = space.intersect_ray(query)
	return result.collider == player

func update_vision_cone():
	var points: Array[Vector2] = [Vector2.ZERO]
	var start_angle = -cone_angle / 2.0
	var angle_step = cone_angle / ray_count
	var space_state = get_world_2d().direct_space_state

	for i in range(ray_count + 1):
		var angle_rad = deg_to_rad(start_angle + i * angle_step)
		var direction = global_transform.x.rotated(angle_rad)
		var target = global_position + direction * cone_length

		var query = PhysicsRayQueryParameters2D.create(global_position, target)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		var hit_point = result.position if result else target
		points.append(to_local(hit_point))
		
		if result and result.collider == player:
			vision_cone.color = Color.RED

	vision_cone.polygon = points
