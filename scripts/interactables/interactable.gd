extends StaticBody2D
class_name Interactable

var enabled: bool = true

func interact():
	if enabled:
		enabled_interact()

func enabled_interact():
	push_warning("Override this: ", name, ".interact")
