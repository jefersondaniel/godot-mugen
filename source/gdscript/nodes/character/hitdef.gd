extends Object

var attr_type: int = 0
var attr_flag: int = 0
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
var guard_sparkno: int = 0
var sparkxy: Vector2 = Vector2(0, 0)
var hitsound: Array = [] # Defaults to player variable
var guardsound: Array  = [] # Defaults to player variable
var ground_type: String 'high'
var air_type: String = '' # Defaults to ground type
var ground_slidetime: int = 0
var ground_hittime: int = 0
var guard_hittime: int = 0
var air_hittime: int = 20 # This parameter has no effect if the "fall" parameter is set to 1
var guard_ctrltime: int = 0 # Defaults to guard_slidetime
var guard_dist: int = 0 # Defaults to value in player variables
var yaccel: float = 1.4 # Defaults to .35 in 240p, .7 in 480p, 1.4 in 720p
var ground_velocity: Vector2 = Vector(0, 0)
var guard_velocity: float = 0
var air_velocity: Vector2 = Vector(0, 0)
var airguard_velocity: Vector2 = Vector(0, 0)
var ground_cornerpush_veloff: float = 0
var air_cornerpush_veloff: float = 0
var down_cornerpush_veloff: float = 0
var guard_cornerpush_veloff: float = 0
var airguard_cornerpush_veloff: float = 0
var airguard_ctrltime: int = 0
var air_juggle: int = 0
var mindist = null
var maxdist = null
var snap = null
var p1sprpriority: int = 1
var p2sprpriority: int = 0
var p1facing: int = 0
var p1getp2facing: int = 0
var p2facing: int = 0
var p1stateno: int = -1
var p2stateno: int = -1
var p2getp1state: int = 1
var forcestand: int = 0 # Normally defaults to 0, but if the y_velocity of the "ground.velocity" parameter is non-zero, it defaults to 1.
var fall: int = 0
var fall_xvelocity: int = 0
var fall_yvelocity: int = -18
var fall_recover: int = 1
var fall_recovertime: int = 4
var fall_damage: int = 0
var air_fall: int = 0
var forcenofall: int = 0
var down_velocity: Vector2 = Vector2(0, 0) # Defaults to air_velocity
var down_time: int = 0
var down_bounce: int = 0
var id: int = 0
var chainid: int = 0
var nochainid: int = 0
var hitonce: int = 0
var kill: int = 1
var guard_kill: int = 1
var fall_kill: int = 1
var numhints: int = 1
var getpower: Array = [0, 0] # TODO: If omitted, p1power defaults to hit_damage (from "damage" parameter) multiplied by the value of Default.Attack.LifeToPowerMul specified in data/mugen.cfg. If p1gpower is omitted, it defaults to the value specified for p1power divided by 2.
var givepower: Array = [0, 0] # If omitted, p1power defaults to hit_damage (from "damage" parameter) multiplied by the value of Default.GetHit.LifeToPowerMul specified in data/mugen.cfg. If p1gpower is omitted, it defaults to the value specified for p1power divided by 2.
var palfx_time: int = 0
var palfx_mul: int = [0, 0, 0]
var palfx_add: Array = [0, 0, 0]
var envshake_time: int = 0
var envshake_freq: float = 0
var envshake_ampl: int = 0
var envshake_phase: float = 0
var fall_envshake_time: int = 0
var fall_envshake_freq: float = 0
var fall_envshake_ampl: int = 0
var fall_envshake_phase: float = 0

func parse(data: Dictionary):
    var aux_array: Array = []

    if data.has('attr'):
        var input_attributes: String = data['attr'].split(',')
        var input_attribute_1: String = input_attributes[0].strip_edges().to_lower()
        var input_attribute_2: String = input_attributes[1].strip_edges().to_lower()
        attr_type = constants.FLAGS[input_attribute_1]
        attr_flag = constants.FLAGS[input_attribute_2[0]] + constants.FLAGS[input_attribute_2[1]]

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

    if data.has('sparkxy'):
        sparkxy = parse_vector(data['sparkxy'])

    if data.has('hitsound'):
        hitsound = data['hitsound'].split_floats(',')

    if data.has('guardsound'):
        guardsound = data['guardsound'].split_floats(',')

    if data.has('ground.type'):
        ground_type = data['ground.type']

    if data.has('air.type'):
        air_type = data['air_type']
    else:
        air_type = ground_type

    if data.has('ground.slidetime'):
        ground_slidetime = int(data['ground.slidetime'])

    if data.has('ground.hittime'):
        ground_hittime = int(data['ground.hittime'])

    if data.has('guard.hittime'):
        guard_hittime = int(data['guard_.ittime'])
    else:
        guard_hittime = ground_hittime

    if data.has('air.hittime'):
        air_hittime = int(data['air_hi.time'])

    if data.has('guard.ctrltime'):
        guard_ctrltime = int(data['guard.ctrltime'])
    else:
        guard_ctrltime = guard_slidetime

    if data.has('guard.dist'):
        guard_dist = int(data['guard.dist'])

    if data.has('yaccel'):
        yaccel = float(data['yaccel'])

    if data.has('ground.velocity'):
        ground_velocity = parse_vector(data['ground.velocity'])

    if data.has('guard.velocity'):
        guard_velocity = float(data['guard.velocity'])

    if data.has('air.velocity'):
        air_velocity = parse_vector(data['air.velocity'])

    if data.has('airguard.velocity'):
        airguard_velocity = parse_vector(data['airguard.velocity'])
    else:
        airguard_velocity = Vector2(air_velocity.x * 1.5, air_velocity.y / 2)

    if data.has('ground.cornerpush.veloff'):
        ground_cornerpush_veloff = float(data['ground.cornerpush.veloff'])
    elif attr_type == constants.FLAG_A:
        ground_cornerpush_veloff = 1.3 * guard_velocity

    if data.has('air.cornerpush.veloff'):
        air_cornerpush_veloff = float(data['air.cornerpush.veloff'])
    else:
        air_cornerpush_veloff = ground_cornerpush_veloff

    if data.has('down.cornerpush.veloff'):
        down_cornerpush_veloff = float(data['down.cornerpush.veloff'])
    else:
        down_cornerpush_veloff = ground_cornerpush_veloff

    if data.has('guard.cornerpush.veloff'):
        guard_cornerpush_veloff = float(data['guard.cornerpush.veloff'])
    else:
        guard_cornerpush_veloff = ground_cornerpush_veloff

    if data.has('airguard.cornerpush.veloff'):
        airguard_cornerpush_veloff = float(data['airguard.cornerpush.veloff'])
    else:
        airguard_cornerpush_veloff = guard_cornerpush_veloff

    if data.has('airguard.ctrltime'):
        airguard_ctrltime = int(data['airguard.ctrltime'])
    else:
        airguard_ctrltime = guard_ctrltime

    if data.has('air.juggle'):
        air_juggle = int(data['air.juggle'])

    if data.has('mindist'):
        mindist = parse_vector(data['mindist'])

    if data.has('maxdist'):
        maxdist = parse_vector(data['maxdist'])

    if data.has('snap'):
        snap = parse_vector(data['snap'])

    if data.has('p1sprpriority'):
        p1sprpriority = int(data['p1sprpriority'])

    if data.has('p2sprpriority'):
        p2sprpriority = int(data['p2sprpriority'])

    if data.has('p1facing'):
        p1facing = int(data['p1facing'])

    if data.has('p1getp2facing'):
        p1getp2facing = int(data['p1getp2facing'])

    if data.has('p2facing'):
        p2facing = int(data['p2facing'])

    if data.has('p1stateno'):
        p1stateno = int(data['p1stateno'])

    if data.has('p2stateno'):
        p2stateno = int(data['p2stateno'])

    if data.has('p2getp1state'):
        p2getp1state = int(data['p2getp1state'])

    if data.has('forcestand'):
        forcestand = int(data['forcestand'])

    if data.has('fall'):
        fall = int(data['fall'])

    if data.has('fall.xvelocity'):
        fall_xvelocity = int(data['fall.xvelocity'])

    if data.has('fall.yvelocity'):
        fall_yvelocity = int(data['fall.yvelocity'])

    if data.has('fall.recover'):
        fall_recover = int(data['fall.recover'])

    if data.has('fall.recovertime'):
        fall_recovertime = int(data['fall.recovertime'])

    if data.has('fall.damage'):
        fall_damage = int(data['fall.damage'])

    if data.has('air.fall'):
        air_fall = int(data['air.fall'])
    else:
        air_fall = fall

    if data.has('forcenofall'):
        forcenofall = int(data['forcenofall'])

    if data.has('down.velocity'):
        down_velocity = parse_vector(data['down.velocity'])
    else:
        down_velocity = air_velocity

    if data.has('down.time'):
        down_time = int(data['down.time'])

    if data.has('down.bounce'):
        down_bounce = int(data['down.bounce'])

    if data.has('id'):
        id = int(data['id'])

    if data.has('chainid'):
        chainid = int(data['chainid'])

    if data.has('nochainid'):
        nochainid = int(data['nochainid'])

    if data.has('hitonce'):
        hitonce = int(data['hitonce'])

    if data.has('kill'):
        kill = int(data['kill'])

    if data.has('guard.kill'):
        guard_kill = int(data['guard.kill'])

    if data.has('fall.kill'):
        fall_kill = int(data['fall.kill'])

    if data.has('numhints'):
        numhints = int(data['numhints'])

    if data.has('getpower'):
        getpower = data['getpower'].split_floats(',')

    if data.has('givepower'):
        givepower = data['givepower'].split_floats(',')

    if data.has('palfx.time'):
        palfx_time = int(data['palfx.time'])

    if data.has('palfx.mul'):
        palfx_mul = data['palfx.mul'].split_floats(',')

    if data.has('palfx.add'):
        palfx_add = data['palfx.add'].split_floats(',')

    if data.has('envshake.time'):
        envshake_time = int(data['envshake_time'])

    if data.has('envshake.freq'):
        envshake_freq = float(data['envshake_freq'])

    if data.has('envshake.ampl'):
        envshake_ampl = int(data['envshake_ampl'])

    if data.has('envshake.phase'):
        envshake_phase = float(data['envshake_phase'])

    if data.has('fall.envshake.time'):
        fall_envshake_time = int(data['fall.envshake_time'])

    if data.has('fall.envshake.freq'):
        fall_envshake_freq = float(data['fall.envshake_freq'])

    if data.has('fall.envshake.ampl'):
        fall_envshake_ampl = int(data['fall.envshake_ampl'])

    if data.has('fall.envshake.phase'):
        fall_envshake_phase = float(data['fall.envshake_phase'])

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

func parse_vector(value: String) -> Vector2:
    var pieces: Array = value.split_floats(',')

    if pieces.size() > 1:
        return Vector2(pieces[0], pieces[1])
    elif pieces.size() == 1:
        return Vector2(pieces[0], 0)
    else:
        return Vector2(0, 0)
