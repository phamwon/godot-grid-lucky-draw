extends Node

var title = 'Vòng quay giải thưởng'

func _ready():
    # get_tree().get_root().set_transparent_background(true)
    init_lucky_block()
    pass

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().quit()

func init_lucky_block():
    $LuckyBlock/Number.text = '777'
    $LuckyBlock.visible = false

func _on_Board_lucky_round_change(lucky_round):
    match lucky_round:
        1: $Round.text = title + " thứ nhất"
        2: $Round.text = title + " thứ hai"
        3: $Round.text = title + " đặc biệt"

func _on_Board_lucky_draw_finished(number):
    $LuckyBlock/Number.text = str(number)
    $LuckyBlock/AnimationPlayer.play("LuckyDraw")


func _on_Board_new_lucky_round():
    init_lucky_block()
