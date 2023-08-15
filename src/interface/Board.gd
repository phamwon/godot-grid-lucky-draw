extends Container

signal lucky_round_change
signal new_lucky_round
signal lucky_draw_finished(number, lucky_round)

var drum_roll_asset = preload('res://assets/sound/drum-roll.mp3')
var success_reward = preload('res://assets/sound/success-reward.mp3')
var completed_sound = preload('res://assets/sound/level_complete.mp3')

var block_use := 100
var block_count := 100
var list_number: Array
var lucky_draw_count := 0
var list_rewarded: Array = []

var currentNumOfSoundPlay = 0
const SOUND_LIMIT_NUM = 10

var current_block_id = null
var lucky_block_distance = null


func _ready():
	set_lucky_round(1)
	create_list_number()
	set_meta("state", "open")

	create_blocks()
	play_anim_waiting()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_RIGHT:
			set_lucky_round(get_meta("lucky_round") + 1)
		if event.pressed and event.scancode == KEY_LEFT:
			set_lucky_round(get_meta("lucky_round") - 1)


func create_list_number():
	list_number = []
	for i in range(1, block_use + 1):
		list_number.append(i)


func random_number():
	var state = get_meta("state")
	if not state == "waiting":
		return

	randomize()

	list_number.shuffle()
	print(list_number)

	var blocks = get_tree().get_nodes_in_group("blocks")

	var x = 0
	for i in range(0, block_use):
		var block = blocks[i]

		var is_selected = block.get_meta("is_selected")
		if is_selected:
			continue

		block.set_meta("number", list_number[x])

		if list_rewarded.has(list_number[x]):
			# handle reset number of player
			block.set_meta("is_selected", true)
			var numberLabel = block.get_node("Number")
			numberLabel.text = str(list_number[x])
			var anims = block.get_node("AnimationPlayer")
			anims.play("Flash")

			list_number.erase(list_number[x])
		else:
			x += 1

	yield(get_tree().create_timer(1.9), "timeout")
	random_number()


func set_lucky_round(lucky_round):
	if lucky_round > 3:
		lucky_round = 1
	if lucky_round < 1:
		lucky_round = 1

	set_meta("lucky_round", lucky_round)
	emit_signal("lucky_round_change", lucky_round)


func create_blocks():
	for i in range(block_count):
		var block = $Block.create_instance()

		block.set_meta("index", i)
		block.set_meta("is_selected", false)

#        block.connect('request_new_number', self, '_on_Block_request_new_number')

		block.add_to_group("blocks")


func generate_lucky_block_distance():
	randomize()

	var lucky_round = get_meta("lucky_round")

	if lucky_round == 1:
		lucky_block_distance = floor(block_count * 2 + randi() % block_count)
	elif lucky_round == 2:
		lucky_block_distance = floor(block_count * 3 + randi() % block_count)
	elif lucky_round == 3:
		lucky_block_distance = floor(block_count * 4 + randi() % block_count)


func generate_lucky_block_extra_steps():
	randomize()

	lucky_block_distance = 10 + randi() % 10


func _on_Logo_pressed():
	var state = get_meta("state")

	match state:
		"open":
			set_meta("state", "waiting")
			stop_anims()
			random_number()
			play_anim_random_number()

		"waiting":
			set_meta("state", "lucky_draw")
			stop_anims()
			lucky_draw_count = 0
			current_block_id = null
			generate_lucky_block_distance()
			star_lucky_draw()

		"lucky_draw":
			set_meta("state", "waiting")
			stop_anims()
			random_number()
			yield(get_tree().create_timer(0.1), "timeout")
			play_anim_random_number()
		"finished":
			set_meta("state", "open")
			stop_anims()
			emit_signal("new_lucky_round")
			play_anim_waiting()


func stop_anims():
	var blocks = get_tree().get_nodes_in_group("blocks")

	for block in blocks:
		var timer = block.get_node("Timer") as Timer
		timer.stop()

		var is_selected = block.get_meta("is_selected")
		if is_selected:
			continue

		var anims = block.get_node("AnimationPlayer")
		anims.stop(true)

		anims.play("RESET")


func play_anim_random_number():
	var state = get_meta("state")
	if not state == "waiting":
		return

	var blocks = get_tree().get_nodes_in_group("blocks")

	for block in blocks:
		var index = block.get_meta("index")
		if index >= block_use:
			continue

		var is_selected = block.get_meta("is_selected")
		if is_selected:
			continue

		var anims = block.get_node("AnimationPlayer")
		anims.stop(true)
		anims.play("RandomNumber")


func star_lucky_draw():
	var state = get_meta("state")
	print(state)
	if not state == "lucky_draw":
		return

	var blocks = get_tree().get_nodes_in_group("blocks")
	var next_block_id = 0

	if current_block_id == null:
		next_block_id = 0
	else:
		next_block_id = current_block_id + 1

	var block_found = false

	while block_found == false and next_block_id != current_block_id:
		if next_block_id >= len(blocks):
			next_block_id = 0

		var block = blocks[next_block_id]
		var is_selected = block.get_meta("is_selected")

		if not is_selected:
			block_found = true
			current_block_id = next_block_id
			print(current_block_id)
			break

		next_block_id = next_block_id + 1

	var block = blocks[next_block_id] as Control
	var is_selected = block.get_meta("is_selected")
	if is_selected:
		star_lucky_draw()
		return

	var anims = block.get_node("AnimationPlayer")

	anims.play("Highlight")
	if currentNumOfSoundPlay < SOUND_LIMIT_NUM:
		var soundNode = block.get_node('Sound') as AudioStreamPlayer
		soundNode.play()
		if not soundNode.is_connected("finished", self, "on_sound_highlight_completed"):
			soundNode.connect("finished", self, "on_sound_highlight_completed")

	# Delay by lucky_round
	var delay = 0.003
	var speed = 0.1 / float(lucky_block_distance - 10)

	if lucky_draw_count > 0 and lucky_draw_count <= lucky_block_distance - 10:
		delay += lucky_draw_count * speed

	if lucky_draw_count > lucky_block_distance - 10 and lucky_draw_count != lucky_block_distance:
		delay += pow(1.35, lucky_draw_count - (lucky_block_distance - 10)) * 0.1
		
		# 4 seconds
		if lucky_draw_count == lucky_block_distance - 3:
			var sound = $Sound as AudioStreamPlayer
			if !sound.is_playing():
				sound.stream = drum_roll_asset
				sound.play()

	if lucky_block_distance == lucky_draw_count:
		delay = 0.5

	print(lucky_draw_count)
#    var tween = create_tween()
#    tween.interpolate_value(0, 100, -1, delay, Tween.TRANS_QUAD, Tween.EASE_OUT)
#    tween.connect("finished", self, 'on_luckey_draw_finished', [block])

	var timer = block.get_node("Timer") as Timer
	timer.start(delay)

	if not timer.is_connected("timeout", self, "on_luckey_draw_finished"):
		timer.connect("timeout", self, "on_luckey_draw_finished", [block])

func on_sound_highlight_completed():
	currentNumOfSoundPlay-=1

func on_luckey_draw_finished(block):
	var state = get_meta("state")
	if not state == "lucky_draw":
		return

	lucky_draw_count += 1

	if lucky_draw_count > lucky_block_distance:
		set_meta("state", "finished")
		lucky_draw_count = 0
		var anims = block.get_node("AnimationPlayer")
		anims.play("Flash")
		anims.connect("animation_finished", self, "on_flash_finished", [block])
		
		var sound = $Sound as AudioStreamPlayer
		sound.stream = success_reward
		sound.play()
		
		return

	star_lucky_draw()


func on_flash_finished(_anim_name, block):
	var state = get_meta("state")
	if not state == "finished":
		return

	var lucky_round = str(get_meta("lucky_round"))
	var roundText = block.get_node("Round")
	var star_text = lucky_round
	
	if (lucky_round == "3"):
		lucky_round = "Đặc Biệt"
		star_text = "ĐB"

	roundText.visible = true
	roundText.text = "Vòng " + star_text

	block.set_meta("is_selected", true)

	var number = block.get_meta("number")

	list_rewarded.append(number)
	list_number.erase(number)

	print(list_number)
	emit_signal("lucky_draw_finished", number, lucky_round)
	
	var sound = $Sound as AudioStreamPlayer
	sound.stream = completed_sound
	sound.play()


func play_anim_waiting():
	var state = get_meta("state")
	if not state == "open":
		return

	var blocks = get_tree().get_nodes_in_group("blocks")

	for block in blocks:
		var is_selected = block.get_meta("is_selected")
		if is_selected:
			continue

		var timer = block.get_node("Timer") as Timer

		var i = block.get_meta("index")
		var delay = i * 0.1
		timer.start(delay)

		if not timer.is_connected("timeout", self, "on_delay_waiting_finished"):
			timer.connect("timeout", self, "on_delay_waiting_finished", [block])


func on_delay_waiting_finished(block):
	var state = get_meta("state")
	if not state == "open":
		return

	var anims = block.get_node("AnimationPlayer")

	anims.play("Ready")

	# Play again when block is lastest
	if block.get_meta("index") == block_count - 1:
		if not anims.is_connected("animation_finished", self, "on_play_anim_waiting_finished"):
			anims.connect("animation_finished", self, "on_play_anim_waiting_finished")


func on_play_anim_waiting_finished(_anim_name):
	play_anim_waiting()


func _on_Title_change_round():
	set_lucky_round(get_meta("lucky_round") + 1)


func _on_Block_request_new_number(_index):
	random_number()


func _on_DebugTool_change_player_number(num_of_player):
	block_count = num_of_player
	block_use = num_of_player

	list_rewarded = []
	set_meta("state", "debug_reset")

	var blocks = get_tree().get_nodes_in_group("blocks")
	for block in blocks:
		var timer = block.get_node("Timer") as Timer
		timer.stop()

		block.set_meta("is_selected", false)

		var anims = block.get_node("AnimationPlayer")
		anims.stop(true)

		anims.play("RESET")
		block.remove_from_group("blocks")
		block.queue_free()

	yield(get_tree().create_timer(0.1), "timeout")

	_ready()
