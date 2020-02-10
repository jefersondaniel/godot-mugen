extends Object

var state_type: int = 0
var attack_types: Array = []

func parse(value: String):
    var pieces: Array = value.to_lower().split(",")
    var piece: String = ''
    var attack_intensity: int = 0
    var attack_category: int = 0

    self.state_type = 0
    self.attack_types = []

    for i in range(pieces.size()):
        piece = pieces[i].strip_edges()

        if i == 0:
            for c in piece:
                self.state_type += constants.FLAGS[c]
            continue

        if piece.length() != 2:
            push_error("Invalid attack string: %s" % [value])
            break

        if piece[0] == 'a':
            attack_intensity = constants.FLAG_N + constants.FLAG_S + constants.FLAG_H
        else:
            attack_intensity = constants.FLAGS[piece[0]]

        attack_category = constants.FLAGS[piece[1]]

        self.attack_types.push_back({
            'intensity': attack_intensity,
            'category': attack_category 
        })

func satisfy(condition) -> bool:
    if condition.state_type & self.state_type == 0:
        return false
    
    var match_attack_type: bool = false

    for condition_attack_type in condition.attack_types:
        for attack_type in self.attack_types:
            if (condition_attack_type['intensity'] & attack_type['intensity']) and condition_attack_type['category'] == attack_type['category']:
                match_attack_type = true
                break
        if match_attack_type:
            break

    if not match_attack_type:
        return false

    return true
