extends Container

var list_number: Array

func _ready():
    create_list_number()

func create_list_number():
    list_number = []
    for i in range(1, 100):
        list_number.append(i)
        
func random_number():
    randomize()
    
    list_number.shuffle()

    for number in list_number:
        set_meta("number", number)

        var number_string = str(number)
        number_string = number_string.pad_zeros(3)
        $Number.text = number_string
