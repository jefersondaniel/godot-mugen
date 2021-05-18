var HitAttribute = load('res://source/gdscript/nodes/character/hit_attribute.gd')
var MugenExpression = load('res://source/native/mugen_expression.gdns')

var attribute = null
var hitflag: int = constants.MAF
var hitflag_sign: String = ''
var guardflag: int = 0
var affectteam: String = 'e'
var animtype: String = 'light'
var air_animtype: String = 'light'
var fall_animtype: String = ''
var priority: int = 4
var priority_type: String = 'hit'
var hit_damage: int = 0
var guard_damage: int = 0
var pausetime: int = 0
var shaketime: int = 0
var guard_pausetime: int = 0
var guard_shaketime: int = 0
var sparkno: int = 0 # Defaults to the value set in the player variables if omitted.
var sparkno_source: String = 'common'
var guard_sparkno: int = 0
var guard_sparkno_source: String = 'common'
var sparkxy: Vector2 = Vector2(0, 0)
var hitsound_source: String = 'common' # common or player
var hitsound: Array = [] # Defaults to player variable
var guardsound_source: String = 'common' # common or player
var guardsound: Array  = [] # Defaults to player variable
var ground_type: String = 'high'
var air_type: String = '' # Defaults to ground type
var ground_slidetime: int = 0
var ground_hittime: int = 0
var guard_hittime: int = 0
var air_hittime: int = 20 # This parameter has no effect if the "fall" parameter is set to 1
var guard_slidetime: int = 0 # Defaults to same value as "guard.hittime"
var guard_ctrltime: int = 0 # Defaults to guard_slidetime
var guard_dist: int = 0 # Defaults to value in player variables
var yaccel: float = 0.35 # Defaults to .35 in 240p, .7 in 480p, 1.4 in 720p
var ground_velocity: Vector2 = Vector2(0, 0)
var guard_velocity: float = 0
var air_velocity: Vector2 = Vector2(0, 0)
var airguard_velocity: Vector2 = Vector2(0, 0)
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
var fall_yvelocity: int = -4.5 # Considering 240p default
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
var p1_power: int = 0
var p1_guard_power: int = 0
var p2_power: int = 0
var p2_guard_power: int = 0
var palfx_time: int = 0
var palfx_mul: Array = [0, 0, 0]
var palfx_add: Array = [0, 0, 0]
var envshake_time: int = 0
var envshake_freq: float = 0
var envshake_ampl: int = 0
var envshake_phase: float = 0
var fall_envshake_time: int = 0
var fall_envshake_freq: float = 0
var fall_envshake_ampl: int = 0
var fall_envshake_phase: float = 0

func _init():
    # TODO: Adjust default values based on global_scale (considering that a hitdef affect a character with a distinct scale)
    attribute = HitAttribute.new()

func parse(data: Dictionary, context):
    var aux_array: Array = []

    if data.has('attr'):
        attribute.parse(data['attr'])

    if data.has('hitflag'):
        hitflag = parse_attack_flags(data['hitflag'].to_lower())
        hitflag_sign = parse_attack_sign(data['hitflag'].to_lower())

    if data.has('guardflag'):
        guardflag = parse_attack_flags(data['guardflag'].to_lower())

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
        aux_array = data['priority'].split(',')
        priority = int(evaluate_expression(aux_array[0], context))
        if len(aux_array) > 1:
            priority_type = aux_array[1].to_lower()

    if data.has('damage'):
        aux_array = data['damage'].split(',')
        hit_damage = int(evaluate_expression(aux_array[0], context))
        if len(aux_array) > 1:
            guard_damage = int(evaluate_expression(aux_array[1], context))

    if data.has('pausetime'):
        aux_array = data['pausetime'].split(',')
        pausetime = int(evaluate_expression(aux_array[0], context))
        if len(aux_array) > 1:
            shaketime = int(evaluate_expression(aux_array[1], context))

    if data.has('guard.pausetime'):
        aux_array = data['guard.pausetime'].split(',')
        guard_pausetime = int(evaluate_expression(aux_array[0], context))
        if len(aux_array) > 1:
            guard_shaketime = int(evaluate_expression(aux_array[1], context))

    if data.has('sparkno'):
        if data['sparkno'].begins_with('s'):
            sparkno_source = 'player'
        sparkno = int(evaluate_expression(data['sparkno'].lstrip('s'), context))

    if data.has('guard.sparkno'):
        if data['guard.sparkno'].begins_with('s'):
            guard_sparkno_source = 'player'
        guard_sparkno = int(evaluate_expression(data['guard.sparkno'].lstrip('s'), context))

    if data.has('sparkxy'):
        sparkxy = parse_vector(data['sparkxy'], context)

    if data.has('hitsound'):
        if data['hitsound'].begins_with('s'):
            hitsound_source = 'player'
        hitsound = parse_array(data['hitsound'].lstrip('s'), context)

    if data.has('guardsound'):
        if data['guardsound'].begins_with('s'):
            guardsound_source = 'player'
        guardsound = parse_array(data['guardsound'].lstrip('s'), context)

    if data.has('ground.type'):
        ground_type = data['ground.type']

    if data.has('air.type'):
        air_type = data['air.type']
    else:
        air_type = ground_type

    if data.has('ground.slidetime'):
        ground_slidetime = int(evaluate_expression(data['ground.slidetime'], context))

    if data.has('ground.hittime'):
        ground_hittime = int(evaluate_expression(data['ground.hittime'], context))

    if data.has('guard.hittime'):
        guard_hittime = int(evaluate_expression(data['guard_.ittime'], context))
    else:
        guard_hittime = ground_hittime

    if data.has('guard.slidetime'):
        guard_slidetime = int(evaluate_expression(data['guard.slidetime'], context))
    else:
        guard_slidetime = guard_hittime

    if data.has('air.hittime'):
        air_hittime = int(evaluate_expression(data['air.hittime'], context))

    if data.has('guard.ctrltime'):
        guard_ctrltime = int(evaluate_expression(data['guard.ctrltime'], context))
    else:
        guard_ctrltime = guard_slidetime

    if data.has('guard.dist'):
        guard_dist = int(evaluate_expression(data['guard.dist'], context))

    if data.has('yaccel'):
        yaccel = float(evaluate_expression(data['yaccel'], context))

    if data.has('ground.velocity'):
        ground_velocity = parse_vector(data['ground.velocity'], context)

    if data.has('guard.velocity'):
        guard_velocity = float(evaluate_expression(data['guard.velocity'], context))

    if data.has('air.velocity'):
        air_velocity = parse_vector(data['air.velocity'], context)

    if data.has('airguard.velocity'):
        airguard_velocity = parse_vector(data['airguard.velocity'], context)
    else:
        airguard_velocity = Vector2(air_velocity.x * 1.5, air_velocity.y / 2)

    if data.has('ground.cornerpush.veloff'):
        ground_cornerpush_veloff = float(evaluate_expression(data['ground.cornerpush.veloff'], context))
    elif attribute.state_type == constants.FLAG_A:
        ground_cornerpush_veloff = 1.3 * guard_velocity

    if data.has('air.cornerpush.veloff'):
        air_cornerpush_veloff = float(evaluate_expression(data['air.cornerpush.veloff'], context))
    else:
        air_cornerpush_veloff = ground_cornerpush_veloff

    if data.has('down.cornerpush.veloff'):
        down_cornerpush_veloff = float(evaluate_expression(data['down.cornerpush.veloff'], context))
    else:
        down_cornerpush_veloff = ground_cornerpush_veloff

    if data.has('guard.cornerpush.veloff'):
        guard_cornerpush_veloff = float(evaluate_expression(data['guard.cornerpush.veloff'], context))
    else:
        guard_cornerpush_veloff = ground_cornerpush_veloff

    if data.has('airguard.cornerpush.veloff'):
        airguard_cornerpush_veloff = float(evaluate_expression(data['airguard.cornerpush.veloff'], context))
    else:
        airguard_cornerpush_veloff = guard_cornerpush_veloff

    if data.has('airguard.ctrltime'):
        airguard_ctrltime = int(evaluate_expression(data['airguard.ctrltime'], context))
    else:
        airguard_ctrltime = guard_ctrltime

    if data.has('air.juggle'):
        air_juggle = int(evaluate_expression(data['air.juggle'], context))

    if data.has('mindist'):
        mindist = parse_vector(data['mindist'], context)

    if data.has('maxdist'):
        maxdist = parse_vector(data['maxdist'], context)

    if data.has('snap'):
        snap = parse_vector(data['snap'], context)

    if data.has('p1sprpriority'):
        p1sprpriority = int(evaluate_expression(data['p1sprpriority'], context))

    if data.has('p2sprpriority'):
        p2sprpriority = int(evaluate_expression(data['p2sprpriority'], context))

    if data.has('p1facing'):
        p1facing = int(evaluate_expression(data['p1facing'], context))

    if data.has('p1getp2facing'):
        p1getp2facing = int(evaluate_expression(data['p1getp2facing'], context))

    if data.has('p2facing'):
        p2facing = int(evaluate_expression(data['p2facing'], context))

    if data.has('p1stateno'):
        p1stateno = int(evaluate_expression(data['p1stateno'], context))

    if data.has('p2stateno'):
        p2stateno = int(evaluate_expression(data['p2stateno'], context))

    if data.has('p2getp1state'):
        p2getp1state = int(evaluate_expression(data['p2getp1state'], context))

    if data.has('forcestand'):
        forcestand = int(evaluate_expression(data['forcestand'], context))

    if data.has('fall'):
        fall = int(evaluate_expression(data['fall'], context))

    if data.has('fall.xvelocity'):
        fall_xvelocity = int(evaluate_expression(data['fall.xvelocity'], context))

    if data.has('fall.yvelocity'):
        fall_yvelocity = int(evaluate_expression(data['fall.yvelocity'], context))

    if data.has('fall.recover'):
        fall_recover = int(evaluate_expression(data['fall.recover'], context))

    if data.has('fall.recovertime'):
        fall_recovertime = int(evaluate_expression(data['fall.recovertime'], context))

    if data.has('fall.damage'):
        fall_damage = int(evaluate_expression(data['fall.damage'], context))

    if data.has('air.fall'):
        air_fall = int(evaluate_expression(data['air.fall'], context))
    else:
        air_fall = fall

    if data.has('forcenofall'):
        forcenofall = int(evaluate_expression(data['forcenofall'], context))

    if data.has('down.velocity'):
        down_velocity = parse_vector(data['down.velocity'], context)
    else:
        down_velocity = air_velocity

    if data.has('down.time'):
        down_time = int(evaluate_expression(data['down.time'], context))

    if data.has('down.bounce'):
        down_bounce = int(evaluate_expression(data['down.bounce'], context))

    if data.has('id'):
        id = int(evaluate_expression(data['id'], context))

    if data.has('chainid'):
        chainid = int(evaluate_expression(data['chainid'], context))

    if data.has('nochainid'):
        nochainid = int(evaluate_expression(data['nochainid'], context))

    if data.has('hitonce'):
        hitonce = int(evaluate_expression(data['hitonce'], context))

    if data.has('kill'):
        kill = int(evaluate_expression(data['kill'], context))

    if data.has('guard.kill'):
        guard_kill = int(evaluate_expression(data['guard.kill'], context))

    if data.has('fall.kill'):
        fall_kill = int(evaluate_expression(data['fall.kill'], context))

    if data.has('numhints'):
        numhints = int(evaluate_expression(data['numhints'], context))

    if data.has('getpower'):
        # TODO: implement default variable parsing
        aux_array = parse_array(data['getpower'], context)
        p1_power = aux_array[0]
        if aux_array.size() > 1:
            p1_guard_power = aux_array[1]
        else:
            p1_guard_power = p1_power / 2
    else:
        p1_power = hit_damage * context.get_const('default.attack.lifetopowermul')
        p1_guard_power = p1_power / 2

    if data.has('givepower'):
        aux_array = parse_array(data['givepower'], context)
        p2_power = aux_array[0]
        if aux_array.size() > 1:
            p2_guard_power = aux_array[1]
        else:
            p2_guard_power = p2_power / 2
    else:
        p2_power = hit_damage * context.get_const('default.gethit.lifetopowermul')
        p2_guard_power = p2_power / 2

    if data.has('palfx.time'):
        palfx_time = int(evaluate_expression(data['palfx.time'], context))

    if data.has('palfx.mul'):
        palfx_mul = parse_array(data['palfx.mul'], context)

    if data.has('palfx.add'):
        palfx_add = parse_array(data['palfx.add'], context)

    if data.has('envshake.time'):
        envshake_time = int(evaluate_expression(data['envshake.time'], context))
    else:
        envshake_time = 0

    if data.has('envshake.freq'):
        envshake_freq = float(evaluate_expression(data['envshake.freq'], context))
    else:
        envshake_freq = 60.0

    if data.has('envshake.ampl'):
        envshake_ampl = int(evaluate_expression(data['envshake.ampl'], context))
    else:
        envshake_ampl = -16

    if data.has('envshake.phase'):
        envshake_phase = float(evaluate_expression(data['envshake_phase'], context))
    else:
        envshake_phase = 0 if envshake_freq < 90.0 else 90

    if data.has('fall.envshake.time'):
        fall_envshake_time = int(evaluate_expression(data['fall.envshake.time'], context))
    else:
        fall_envshake_time = 0

    if data.has('fall.envshake.freq'):
        fall_envshake_freq = float(evaluate_expression(data['fall.envshake.freq'], context))
    else:
        fall_envshake_freq = 60

    if data.has('fall.envshake.ampl'):
        fall_envshake_ampl = int(evaluate_expression(data['fall.envshake.ampl'], context))
    else:
        fall_envshake_ampl = -16

    if data.has('fall.envshake.phase'):
        fall_envshake_phase = float(evaluate_expression(data['fall.envshake.phase'], context))
    else:
        fall_envshake_phase = 0 if fall_envshake_freq < 90 else 90

func parse_attack_flags(value: String):
    var result: int = 0
    var character: String = ''

    for i in range(value.length()):
        character = value[i]

        if character == 'm':
            result += constants.FLAG_H + constants.FLAG_L

        if constants.FLAGS.has(character):
            result += constants.FLAGS[character]

    return result

func parse_attack_sign(value: String):
    var result: String = ''

    for i in range(value.length()):
        var character: String = value[i]

        if character == '+' or character == '-':
            result = character

    return result

func parse_vector(value: String, context) -> Vector2:
    var result = evaluate_expression(value, context)
    var result_type = typeof(result)

    if result_type == TYPE_ARRAY:
        return Vector2(result[0], result[1])
    elif result_type == TYPE_INT or result_type == TYPE_REAL:
        return Vector2(result, 0)
    else:
        return Vector2(0, 0)

func parse_array(value: String, context) -> Array:
    var result = evaluate_expression(value, context)

    if typeof(result) == TYPE_ARRAY:
        return result
    elif typeof(result) != TYPE_NIL:
        return [result]

    return []

func evaluate_expression(text, context):
    var expression = MugenExpression.new()
    expression.parse(text)
    if (expression.has_error()):
        push_error("%s: %s" % [text, expression.get_error_text()])
        return null
    return expression.execute(context)

func allow_guard_air() -> bool:
    return bool(guardflag & constants.FLAGS_A)

func allow_guard_high() -> bool:
    return bool(guardflag & constants.FLAGS_H)

func allow_guard_low() -> bool:
    return bool(guardflag & constants.FLAGS_L)

func allow_hit_high() -> bool:
    return bool(hitflag & constants.FLAG_H)

func allow_hit_low() -> bool:
    return bool(hitflag & constants.FLAG_L)

func allow_hit_air() -> bool:
    return bool(hitflag & constants.FLAG_A)

func allow_hit_down() -> bool:
    return bool(hitflag & constants.FLAG_D)

func duplicate():
    var result = get_script().new()

    for property in self.get_property_list():
        result.set(property['name'], self.get(property['name']))

    return result
