extends Button

signal change_player_number(num_of_player)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	pass

func _on_Node2D_pressed():
	if $Control.visible:
		$Control.visible = false
	else:
		$Control.visible = true


func _on_OKButton_pressed():
	var number_text = $Control/TextEdit.text
	print(number_text)
	if int(number_text) > 0:
		emit_signal("change_player_number", int(number_text))
