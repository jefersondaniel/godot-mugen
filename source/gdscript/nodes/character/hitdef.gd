extends Object

var attack_type: int = 0
var attack_flag: int = 0
var hitflag: int = constants.MAF
var hitflag_sign: String = ''
var guardflag: int = 0
var affectteam: String = 'e'
var animtype: String = 'light'
var air_animtype: String = 'light'
var fall_animtype: String = ''
var priority: int = 4
var priority_type: String = ''
var hit_damage: int = 0
var guard_damage: int = 0
var p1_pausetime: int = 0
var p2_shaketime: int = 0
var p1_guard_pausetime: int = 0
var p2_guard_shaketime: int = 0
var sparkno: int = 0 # Defaults to the value set in the player variables if omitted.
var guard_sparkno = 0

func parse(data: Dictionary):
    var aux_array: Array = []

    if data.has('attr'):
        var input_attributes: String = data['attr'].split(',')
        var input_attribute_1: String = input_attributes[0].strip_edges().to_lower()
        var input_attribute_2: String = input_attributes[1].strip_edges().to_lower()
        attack_type = constants.FLAGS[input_attribute_1]
        attack_flag = constants.FLAGS[input_attribute_2[0]] + constants.FLAGS[input_attribute_2[1]]

    if data.has('hitflag'):
        hitflag = parse_attack_flags(data['hitflag'])
        hitflag_sign = parse_attack_sign(data['hitflag'])

        for i in range(data['hitflag'].length()):
            character = data['hitflag'][i]
            
            if character == '-' or character == '+':
                hitflag_sign = character

            if character = 'M':
                hitflag += constants.FLAG_H + constants.FLAG_L

            if constants.FLAGS.has(character):
                hitflag += constants.FLAGS[character]

    if data.has('guardflag'):
        guardflag = parse_attack_flags(data['guardflag'])

    if data.has('affectteam'):
        affectteam = data['affectteam'].to_lower()

    if data.has('animtype'):
        animtype = data['animtype'].to_lower()

    if data.has('air.animtype'):
        air_animtype = data['air.animtype'].to_lower()
    
    if data.has('fall.animtype'):
        fall_animtype = data['fall.animtype'].to_lower()
    else:
        fall_animtype = 'up' if air_animtype == 'up' else 'back'
    
    if data.has('priority'):
        aux_array: = data['priority'].split(',')
        priority = int(aux_array[0])
        priority_type = aux_array[1].to_lower()

    if data.has('damage'):
        aux_array: = data['damage'].split(',')
        hit_damage = int(aux_array[0])
        guard_damage = int(aux_array[1])

    if data.has('pausetime'):
        aux_array: = data['pausetime'].split(',')
        p1_pausetime = int(aux_array[0])
        p2_shaketime = int(aux_array[1])

    if data.has('guard.pausetime'):
        aux_array: = data['guard.pausetime'].split(',')
        p1_guard_pausetime = int(aux_array[0])
        p2_guard_shaketime = int(aux_array[1])
    
    if data.has('sparkno'):
        sparkno = int(data['sparkno'])

    if data.has('guard.sparkno'):
        guard_sparkno = int(data['guard.sparkno'])

func parse_attack_flags(value: String):
    var result: int = 0
    var character: String = ''

    for i in range(value.length()):
        character = value[i]

        if character == 'M':
            result += constants.FLAG_H + constants.FLAG_L

        if constants.FLAGS.has(character):
            result += constants.FLAGS[character]
    
    return result

func parse_attack_sign(value: String):
    var result: int = ''

    for i in range(value.length()):
        character = value[i]

        if character == '+' or character == '-':
            result = character
    
    return result
