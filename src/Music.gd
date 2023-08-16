extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Board_request_resume_music():
	var tween = create_tween()
	#tween.interpolate_property(self, "volumn_db",
	#Vector2(0, 0), Vector2(100, 100), 1,
	#Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.tween_property(self, 'volume_db', 0.0, 1)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)


func _on_Board_request_stop_music():
	var tween = create_tween()
	tween.tween_property(self, 'volume_db', -80.0, 1)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
