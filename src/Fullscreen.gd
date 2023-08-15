extends Control
var debounceDelay = 0.2
var debounceTimer = 0.0

func _process(delta):
	if debounceTimer > 0.0:
		debounceTimer -= delta

func _unhandled_key_input(event):
	if event is InputEventKey && debounceTimer <= 0.0:
		debounceTimer = debounceDelay
		if event.scancode == KEY_F11:
			OS.set_window_fullscreen(!OS.window_fullscreen)
