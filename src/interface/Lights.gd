extends GridContainer

export (String) var direction = 'left'

var light_count = 14

func _ready() -> void:
	columns = light_count

	create_lights()
	play_flash_lights()

func create_lights():
	for i in range(light_count):
		var light = $Light.create_instance()

		light.set_meta('index', i)
		light.set_meta('is_light', true)

		light.add_to_group('lights-' + direction)

func play_flash_lights():
	var lights = get_tree().get_nodes_in_group('lights-' + direction)

	for light in lights:
		var i = light.get_meta('index')

		var delay = 0.08

		if direction == 'left':
			delay *= i
		else:
			delay *= (light_count - i)

		var timer = get_tree().create_timer(delay)

		timer.connect('timeout', self, 'on_wait_flash_finished', [light])


func on_wait_flash_finished(light):
	var anims = light.get_node('AnimationPlayer') as AnimationPlayer

	anims.play('Flash', -1, 1)
