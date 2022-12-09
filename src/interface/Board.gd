extends Node2D

var Block = preload("res://src/objects/Block.tscn")

func _ready():
    create_blocks()

func create_blocks():
    var block

    for i in range(100):
        block = Block.instance()

        $Grid.add_child(block)
        $Grid.add_to_group("blocks")

    $Grid.queue_sort()
