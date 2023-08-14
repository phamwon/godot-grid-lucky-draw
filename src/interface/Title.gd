extends Button

signal change_round
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

func _on_Title_pressed():
	emit_signal('change_round')

func _on_Board_lucky_round_change(round_level):
	if round_level == 1:
		$Label.set_text('VÒNG 1')
	elif round_level == 2:
		$Label.set_text('VÒNG 2')
	else:
		$Label.set_text('VÒNG ĐẶC BIỆT')
	
	print(round_level)

func _on_OKButton_pressed():
	var number_text = $TextEdit.text
	print(number_text)
	if int(number_text) > 0:
		emit_signal("change_player_number", int(number_text))