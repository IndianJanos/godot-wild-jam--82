extends Enemy

@export var alert_radius: float = 200.0
@export var max_alerting_cooldown = 5

var current_alerting_cooldown: float = 0

func _ready() -> void:
	super._ready()
	player_seen.connect(_on_player_seen)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_moving:
		current_alerting_cooldown += delta
		
		if current_alerting_cooldown >= max_alerting_cooldown:
			current_alerting_cooldown = 0
			is_moving = true

func _on_player_seen() -> void:
	is_moving = false
	var bullies = get_tree().get_nodes_in_group("bully")
	
	for bully in bullies:
		if bully.global_position.distance_to(global_position) < alert_radius:
			bully.alert()
