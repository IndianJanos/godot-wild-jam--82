extends Enemy

@export var alert_radius: float = 200.0
@export var max_alerting_cooldown = 2
@export var texture: CompressedTexture2D

var current_alerting_cooldown: float = 0

func _ready() -> void:
	super._ready()
	$Sprite2D.texture = texture

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_moving:
		current_alerting_cooldown += delta
		
		if current_alerting_cooldown >= max_alerting_cooldown:
			current_alerting_cooldown = 0
			is_moving = true
			is_player_seen = false
			$AudioStreamPlayer2D.stream = preload("res://assets/audio/step.mp3")

func _on_player_seen() -> void:
	is_moving = false
	var bullies = get_tree().get_nodes_in_group("bully")
	
	$AudioStreamPlayer2D.pitch_scale = 1.0
	$AudioStreamPlayer2D.stream = preload("res://assets/audio/loudaf.mp3")
	$AudioStreamPlayer2D.play();
	
	for bully in bullies:
		if bully.global_position.distance_to(global_position) < alert_radius:
			bully.alert()
	
	
