extends Container

signal lucky_round_change
signal new_lucky_round
signal lucky_draw_finished(number)

var block_count = 100
var lucky_draw_count = 0

func _ready():
    set_lucky_round(1)
    set_meta('state', 'open')

    create_blocks()
    play_anim_waiting()

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_RIGHT:
            set_lucky_round(get_meta('lucky_round') + 1)
        if event.pressed and event.scancode == KEY_LEFT:
            set_lucky_round(get_meta('lucky_round') - 1)

func set_lucky_round(lucky_round):
    if lucky_round > 3: lucky_round = 1
    if lucky_round < 1: lucky_round = 1

    set_meta('lucky_round', lucky_round)
    emit_signal('lucky_round_change', lucky_round)

func create_blocks():
    for i in range(100):
        var block = $Block.create_instance()
        block.set_meta('index', i)
        block.add_to_group("blocks")

func _on_Logo_pressed():
    var state = get_meta('state')
    print('Logo pressed ', state)

    match state:
        'open':
            set_meta('state', 'waiting')
            stop_anims()
            play_anim_random_number()

        'waiting':
            set_meta('state', 'lucky_draw')
            stop_anims()
            lucky_draw_count = 0
            star_lucky_draw()

        'lucky_draw':
            pass

        'finished':
            set_meta('state', 'open')
            stop_anims()
            emit_signal('new_lucky_round')
            play_anim_waiting()

func stop_anims():
    var blocks = get_tree().get_nodes_in_group('blocks')

    for block in blocks:
        var timer = block.get_node('Timer') as Timer
        timer.stop()

        var anims = block.get_node('AnimationPlayer')
        anims.stop()

func play_anim_random_number():
    var state = get_meta('state')
    if not state == 'waiting':
        return

    var blocks = get_tree().get_nodes_in_group('blocks')

    for block in blocks:
        var anims = block.get_node('AnimationPlayer')
        anims.play('RandomNumber')

func star_lucky_draw():
    var state = get_meta('state')
    if not state == 'lucky_draw':
        return

    var blocks = get_tree().get_nodes_in_group('blocks')

    var block = blocks[randi() % block_count]
    var anims = block.get_node('AnimationPlayer')

    anims.play('Highlight')

    # Delay by lucky_round
    var delay = 0.001
    var speed = 10

    var lucky_round = get_meta('lucky_round')
    if lucky_round == 2: speed = 20
    if lucky_round == 3: speed = 30

    delay *= speed

    if lucky_draw_count > 0:
        delay *= lucky_draw_count * 0.1

    var timer = block.get_node('Timer') as Timer
    timer.start(delay)

    if not timer.is_connected('timeout', self, 'on_luckey_draw_finished'):
        timer.connect('timeout', self, 'on_luckey_draw_finished', [block])

func on_luckey_draw_finished(block):
    var state = get_meta('state')
    if not state == 'lucky_draw':
        return

    lucky_draw_count += 1

    var lucky_round = get_meta('lucky_round')
    var chance = 50
    if lucky_round == 2: chance = 35
    if lucky_round == 3: chance = 10

    if lucky_draw_count > randi() % chance + 200:
        set_meta('state', 'finished')
        lucky_draw_count = 0
        var anims = block.get_node('AnimationPlayer')
        anims.play('Flash')
        anims.connect('animation_finished', self, 'on_flash_finished', [block])
        return

    star_lucky_draw()

func on_flash_finished(_anim_name, block):
    var state = get_meta('state')
    if not state == 'finished':
        return

    var number = block.get_meta('number')
    emit_signal('lucky_draw_finished', number)

func play_anim_waiting():
    var state = get_meta('state')
    if not state == 'open':
        return

    var blocks = get_tree().get_nodes_in_group('blocks')

    for block in blocks:
        var timer = block.get_node('Timer') as Timer

        var i = block.get_meta('index')
        var delay = i * 0.1
        timer.start(delay)

        if not timer.is_connected('timeout', self, 'on_delay_waiting_finished'):
            timer.connect('timeout', self, 'on_delay_waiting_finished', [block])


func on_delay_waiting_finished(block):
    var state = get_meta('state')
    if not state == 'open':
        return

    var anims = block.get_node('AnimationPlayer')

    anims.play('Ready')

    # Play again when block is lastest
    if block.get_meta('index') == block_count - 1:
        if not anims.is_connected('animation_finished', self, 'on_play_anim_waiting_finished'):
            anims.connect('animation_finished', self, 'on_play_anim_waiting_finished')

func on_play_anim_waiting_finished(_anim_name):
    play_anim_waiting()
