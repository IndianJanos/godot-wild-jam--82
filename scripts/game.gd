extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 30
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
