extends Node

var title = 'Vòng quay giải thưởng'

func _ready() -> void:
    # get_tree().get_root().set_transparent_background(true)
    pass

func _on_Board_lucky_round_change(lucky_round):
    match lucky_round:
        1: $Round.text = title + " thứ nhất"
        2: $Round.text = title + " thứ hai"
        3: $Round.text = title + " đặc biệt"
