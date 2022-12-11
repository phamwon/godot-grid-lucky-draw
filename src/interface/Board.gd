extends Container

var block_count = 100

func _ready():
    create_blocks()
    play_anim_waiting()

func create_blocks():
    for _i in range(100):
        var block = $Block.create_instance()
        block.add_to_group("blocks")

#    queue_sort()

func play_anim_waiting():
    pass
