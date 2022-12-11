extends Container

var number_used: Array = []
var rng = RandomNumberGenerator.new()

func _ready():
    random_number()

func random_number():
    rng.randomize()

    # Random number between 001 and 100, no repeat
    number_used = []
    var number = rng.randi_range(1, 100)
    while number_used.has(number):
        number = rng.randi_range(1, 100)

    number_used.append(number)
    set_meta("number", number)

    var number_string = str(number)
    number_string = number_string.pad_zeros(3)
    $Number.text = number_string
