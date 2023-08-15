extends Button

signal change_player_number(num_of_player)

const music_on_path = 'res://assets/image/music-on.png'
const music_off_path = 'res://assets/image/music-off.png'
const sound_on_path = 'res://assets/image/sound-on.png'
const sound_off_path = 'res://assets/image/sound-off.png'

var sound_off_asset = preload(sound_off_path)
var sound_on_asset = preload(sound_on_path)
var music_off_asset = preload(music_off_path)
var music_on_asset = preload(music_on_path)

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


func _on_Music_pressed():
	if $Control/Music.icon.get_path() == music_off_path:
		$Control/Music.icon = music_on_asset
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
	else:
		$Control/Music.icon = music_off_asset
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)


func _on_Sound_pressed():
	if $Control/Sound.icon.get_path() == sound_off_path:
		$Control/Sound.icon = sound_on_asset
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"), false)
	else:
		$Control/Sound.icon = sound_off_asset
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"), true)
