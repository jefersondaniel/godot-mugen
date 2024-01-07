var HitDef = load('res://source/gdscript/nodes/character/hit_def.gd')
var HitOverride = load('res://source/gdscript/nodes/character/hit_override.gd')

var character = null
var hit_def = null
var blocked: bool = false
var killed: bool = false
var hit_state_type: int = 0
var hit_shake_time = 0
var defense_multiplier = 1
var attacker = null
var hit_time = 0
var hit_by_1 = null
var hit_by_2 = null
var is_falling = false
var hit_overrides: Array = []
var hit_count: int = 0

func _init(input_character):
    character = input_character
    reset()

func reset():
    hit_def = HitDef.new()
    blocked = false
    killed = false
    hit_state_type = 0
    hit_shake_time = 0
    defense_multiplier = 1
    attacker = null
    hit_time = 0
    hit_by_1 = null
    hit_by_2 = null
    is_falling = false
    hit_count = 0
    hit_overrides = []
    for i in range(0, 8):
        hit_overrides.append(HitOverride.new())

func handle_tick():
    if hit_by_1:
        hit_by_1.handle_tick()

    if hit_by_2:
        hit_by_2.handle_tick()

    if hit_shake_time > 0:
        hit_shake_time -= 1
    elif hit_time > -1:
        hit_time -= 1

    if hit_shake_time < 0:
        hit_shake_time = 0

    if hit_time < 0:
        hit_time = 0

    if hit_def and character.stateno == constants.STATE_HIT_GET_UP && character.time == 0:
        hit_def.fall = false

    for hit_override in hit_overrides:
        hit_override.handle_tick()

func on_hit(input_hit_def, input_attacker, input_blocked):
    hit_def = input_hit_def.duplicate()
    attacker = input_attacker
    blocked = input_blocked

    if character.is_falling():
        hit_def.fall = 1
    else:
        character.remaining_juggle_points = int(character.get_const('data.airjuggle'))

    hit_count = hit_count + 1 if character.movetype == constants.FLAG_H else 1
    hit_state_type = character.statetype

    character.update_z_index(hit_def.p2sprpriority)
    character.ctrl = 0
    character.movetype = constants.FLAG_H

    if blocked:
        hit_shake_time = hit_def.guard_shaketime
        character.add_power(hit_def.p2_guard_power)
    else:
        hit_shake_time = hit_def.shaketime
        character.add_power(hit_def.p2_power)

        # TODO: Apply pallete fx

        if character.is_falling():
            character.remaining_juggle_points -= attacker.required_juggle_points

func find_hit_override(input_hit_def):
    for hit_override in hit_overrides:
        if not hit_override.is_active:
            continue
        if not hit_override.attribute.satisfy(input_hit_def.attribute):
            continue
        return hit_override
    return null

func get_hit_velocity() -> Vector2:
    var hit_velocity: Vector2 = Vector2(0, 0)

    if blocked:
        hit_velocity = hit_def.airguard_velocity if hit_state_type == constants.FLAG_A else Vector2(hit_def.guard_velocity, 0)
    else:
        hit_velocity = hit_def.air_velocity if hit_state_type == constants.FLAG_A else hit_def.ground_velocity
        if killed:
            hit_velocity.x = hit_velocity.x * 0.66 # TODO: Put this constant in global file
            hit_velocity.y = -6
    return hit_velocity
