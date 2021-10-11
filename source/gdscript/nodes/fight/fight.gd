extends Node2D

var StateMachine = load("res://source/gdscript/system/state_machine.gd")
var FightHud = load("res://source/gdscript/nodes/fight/hud.gd")
var PreIntroState = load("res://source/gdscript/nodes/fight/states/pre_intro.gd")

const CONTACT_HIT: int = 1 # This order is important for priority check
const CONTACT_BLOCK: int = 2
const CONTACT_MISS_BLOCK: int = 3

var roundstate: int = constants.ROUND_STATE_PRE_INTRO
var roundno: int = 0
var matchover: bool = false
var teams = {}
var active_characters setget ,get_active_characters
var stage = null
var contacts = []
var cancelled_contacts = []
var kernel = null
var state_machine = null
var configuration = null
var hud = null
var remaining_time: int = constants.ROUND_TIME
var special_flags = {}
var team_1 setget ,get_team_1
var team_2 setget ,get_team_2
var is_slow_mode: bool = false
var real_ticks: int = 0 # Get real ticks independent of slow mode

func _init():
    kernel = constants.container["kernel"]
    state_machine = StateMachine.new(PreIntroState.new(self))
    reset_state()

func _ready():
  configuration = kernel.get_fight_configuration()
  hud = FightHud.new(configuration, kernel)
  add_child(hud)

func reset_state():
    roundno = 1

func increase_round():
    roundno += 1

func assert_special(key: String):
    key = key.to_lower()
    special_flags[key] = 1

func check_assert_special(key: String) -> bool:
    key = key.to_lower()
    return special_flags.has(key)

func reset_assert_special():
    special_flags.clear()

func set_stage(_stage):
    if self.stage:
        self.stage.queue_free()

    self.stage = _stage
    self.add_child(self.stage)

func set_team(team_number: int, team):
    teams[team_number] = team

    if team_number != 1 and teams.has(1):
        teams[1].enemy_team = team
        team.enemy_team = teams[1]
    elif team_number != 2 and teams.has(2):
        teams[2].enemy_team = team
        team.enemy_team = teams[2]

    team.setup(self)

func get_team_1():
    return teams[1]

func get_team_2():
    return teams[2]

func get_nearest_enemy(character):
    var nearest_enemy = null
    var nearest_enemy_distance = 9999

    for team in teams.values():
        if team.team_number == character.team_number:
            continue

        for other in team.characters:
            var distance: int = other.position.distance_to(character.position)
            if distance < nearest_enemy_distance:
                nearest_enemy_distance = distance
                nearest_enemy = other

    return nearest_enemy

func get_enemies(character):
    var results: Array = []

    for team in teams.values():
        if team.team_number == character.team_number:
            continue

        for other in team.characters:
            results.push_back(other)

    return results

func get_active_characters():
    var results: Array = []

    for team in teams.values():
        for character in team.active_characters:
            results.push_back(character)

    return results

func update_tick():
    real_ticks += 1

    # Hud animation is not affected by slow
    hud.update_tick()

    if is_slow_mode and real_ticks % 4 != 0:
       return

    state_machine.update_tick()
    reset_assert_special()
    stage.update_tick()
    self.update_characters()
    self.update_combat()
    self.update_hud()

func decrease_remaining_time():
    self.remaining_time = max(0, remaining_time - 1)

func update_combat():
    self.contacts = []
    self.cancelled_contacts = []

    self.check_move_contacts()
    self.run_character_contacts()

func update_characters():
    for character in self.active_characters:
        character.cleanup()

    for character in self.active_characters:
        character.update_input()

    for character in self.active_characters:
        character.update_animation()

    for character in self.active_characters:
        character.update_state()

    for character in self.active_characters:
        character.update_physics()

func update_hud():
    hud.set_time_text(String(remaining_time))

    for playerno in range(1, len(self.active_characters) + 1):
        var character = self.active_characters[playerno - 1]

        var max_life = character.get_max_life()
        var life = character.life
        var life_percent = life / max(max_life, 1)
        hud.set_lifebar_percent(playerno, life_percent)

        var max_power = character.get_max_power()
        var power = character.power
        var power_percent = power / max(max_power, 1)
        hud.set_powerbar_percent(playerno, power_percent)

func run_character_contacts():
    for attack in self.contacts:
        if attack['type'] == CONTACT_HIT:
            if self.cancelled_contacts.has(attack):
                continue
            var reverse = find_reverse_hit(attack)
            if reverse:
                priority_check(attack, reverse)
            if self.cancelled_contacts.has(attack):
                continue
        self.run_character_attack(attack)

    for character in self.active_characters:
        var hit_count: int = count_contacts(character, CONTACT_HIT)
        var block_count: int = count_contacts(character, CONTACT_BLOCK)
        if hit_count:
            character.hit_count += 1
            character.unique_hit_count += hit_count
        if block_count or hit_count:
            character.is_hit_def_active = false

func count_contacts(attacker, type):
    var count: int = 0
    for attack in self.contacts:
        if attack['attacker'] != attacker or attack['type'] != type:
            continue
        count += 1
    return count

func find_reverse_hit(attack):
    for other in self.contacts:
        if self.cancelled_contacts.has(other):
            continue
        if other['target'] == attack['attacker'] && other['attacker'] == attack['target']:
            return other
    return null

func priority_check(a, b):
    if a['type'] != CONTACT_HIT or b['type'] != CONTACT_HIT:
        printerr("Invalid priority check")

    var a_priority: int = a['hit_def'].priority
    var a_priority_type: String = a['hit_def'].priority_type
    var b_priority: int = b['hit_def'].priority
    var b_priority_type: String = b['hit_def'].priority_type

    if a_priority > b_priority:
        self.cancelled_contacts.append(b)
    elif a_priority < b_priority:
        self.cancelled_contacts.append(a)
    else:
        if a_priority_type != 'hit' and b_priority_type != 'hit':
            self.cancelled_contacts.append(a)
            self.cancelled_contacts.append(b)
        elif a_priority_type == 'dodge' or b_priority_type == 'dodge':
            self.cancelled_contacts.append(a)
            self.cancelled_contacts.append(b)
        elif a_priority_type == 'hit' and b_priority_type == 'miss':
            self.cancelled_contacts.append(b)
        elif a_priority_type == 'hit' and b_priority_type == 'miss':
            self.cancelled_contacts.append(a)

func check_move_contacts():
    for attacker in self.active_characters:
        if attacker.in_hit_pause or not attacker.is_hit_def_active:
            continue
        for target in self.active_characters:
            if attacker == target:
                continue
            self.check_move_contact(attacker, target)
    self.contacts.sort_custom(self, 'sort_contacts')

func check_move_contact(attacker, target):
    if can_block(attacker, target, true):
        self.contacts.append({
            'attacker': attacker,
            'target': target,
            'hit_def': attacker.hit_def,
            'type': CONTACT_BLOCK
        })
    elif can_hit(attacker, target):
        self.contacts.append({
            'attacker': attacker,
            'target': target,
            'hit_def': attacker.hit_def,
            'type': CONTACT_HIT
        })
    elif can_block(attacker, target, false):
        self.contacts.append({
            'attacker': attacker,
            'target': target,
            'hit_def': attacker.hit_def,
            'type': CONTACT_MISS_BLOCK
        })

func can_block(attacker, target, collision_check: bool) -> bool:
    var hit_def = attacker.hit_def

    if collision_check and not attacker.check_attack_collision(target):
        return false
    if attacker.hit_def.affectteam == 'e' and target.team_number == attacker.team_number:
        return false
    if attacker.hit_def.affectteam == 'f' and target.team_number != attacker.team_number:
        return false
    if not target.check_command('holdback'):
        return false
    if abs(attacker.position.x - target.position.x) <= attacker.hit_def.guard_dist:
        return false
    if target.statetype == constants.FLAG_A and (not hit_def.allow_guard_air() or target.check_assert_special('noairguard')):
        return false
    if target.statetype == constants.FLAG_S and (not hit_def.allow_guard_high() or target.check_assert_special('nostandingguard')):
        return false
    if target.statetype == constants.FLAG_C and (not hit_def.allow_guard_low() or target.check_assert_special('nocrouchingguard')):
        return false
    if target.statetype == constants.FLAG_L:
        return false
    if target.life <= hit_def.guard_damage and hit_def.guard_kill:
        return false
    return true

func can_hit(attacker, target) -> bool:
    var hit_def = attacker.hit_def

    if not attacker.check_attack_collision(target):
        return false
    if attacker.hit_def.affectteam == 'e' and target.team_number == attacker.team_number:
        return false
    if attacker.hit_def.affectteam == 'f' and target.team_number != attacker.team_number:
        return false
    if target.statetype == constants.FLAG_S and not hit_def.allow_hit_high():
        return false
    if target.statetype == constants.FLAG_C and not hit_def.allow_hit_low():
        return false
    if target.statetype == constants.FLAG_A and not hit_def.allow_hit_air():
        return false
    if target.statetype == constants.FLAG_L and not hit_def.allow_hit_down():
        return false
    if target.movetype == constants.FLAG_H and hit_def.hitflag_sign == '-':
        return false
    if target.movetype == constants.FLAG_H and hit_def.hitflag_sign == '+':
        return false
    if target.hit_by_1 and not target.hit_by_1.can_hit(hit_def.attribute):
        return false
    if target.hit_by_2 and not target.hit_by_2.can_hit(hit_def.attribute):
        return false

    # TODO: Implement juggle points
    return true

func sort_contacts(a, b):
    if a['type'] != b['type']:
        return a['type'] < b['type']

    var hit_def_a = a['hit_def']
    var hit_def_b = b['hit_def']

    if a['type'] == CONTACT_HIT:
        return hit_def_a.priority < hit_def_b.priority

    return false

func run_character_attack(attack):
    if attack['type'] == CONTACT_HIT:
        on_character_attack(attack['attacker'], attack['target'], attack['hit_def'], false)
    elif attack['type'] == CONTACT_BLOCK:
        on_character_attack(attack['attacker'], attack['target'], attack['hit_def'], true)
    elif attack['type'] == CONTACT_MISS_BLOCK:
        out_of_range_block(attack['target'])

func on_character_attack(attacker, target, hit_def, blocked):
    target.handle_hit_target(hit_def, attacker, blocked)
    attacker.handle_hit_attacker(target.received_hit_def, target, blocked)
    set_facing(attacker, target, target.received_hit_def)

    var received_hit_def = target.received_hit_def

    # TODO: implement hit sound and sparks using global data
    # if not blocked:
    #     do_env_shake(received_hit_def)
    #     play_sound(attacker, target, received_hit_def.hitsound, received_hit_def.hitsound_source)
    #     make_spark(attacker, target, received_hit_def.sparkno, received_hit_def.sparkxy, received_hit_def.sparkno_source)
    # else:
    #     play_sound(attacker, target, received_hit_def.guardsound, received_hit_def.guardsound_source);
    #     make_spark(attacker, target, received_hit_def.guard_sparkno, received_hit_def.sparkxy, received_hit_def.guard_sparkno_source)

    var hitoverride = target.find_hit_override(received_hit_def)

    if hitoverride:
        if hitoverride.force_air:
            received_hit_def.fall = 1
        target.state_manager.foreign_manager = null
        target.change_state(hitoverride.stateno)
    else:
        if not blocked:
            on_attack_hit(attacker, target, received_hit_def)
        else:
            on_attack_block(attacker, target, received_hit_def)

func on_attack_hit(attacker, target, hit_def):
    apply_damage(attacker, target, hit_def.hit_damage, hit_def.kill)

    if target.life == 0:
        hit_def.fall = 1

    match target.hit_state_type:
        constants.FLAG_S, constants.FLAG_C, constants.FLAG_L:
            target.hit_time = hit_def.ground_hittime
        constants.FLAG_A:
            target.hit_time = hit_def.air_hittime
        _:
            printerr("Invalid hit state type: " % [target.hit_state_type])

    if hit_def.p1stateno > 0:
        attacker.change_state(hit_def.p1stateno)

    if hit_def.p2stateno > 0:
        if hit_def.p2getp1state:
            target.state_manager.foreign_manager = attacker.state_manager
        else:
            target.state_manager.foreign_manager = null
        target.change_state(hit_def.p2stateno)
    else:
        target.state_manager.foreign_manager = null

        if hit_def.ground_type == 'trip':
            target.change_state(constants.STATE_HIT_TRIP)
        else:
            match target.hit_state_type:
                constants.FLAG_S:
                    target.change_state(constants.STATE_STANDING_HIT_SHAKING)
                constants.FLAG_C:
                    target.change_state(constants.STATE_CROUCHING_HIT_SHAKING)
                constants.FLAG_A:
                    target.change_state(constants.STATE_AIR_HIT_SHAKING)
                constants.FLAG_L:
                    target.change_state(constants.STATE_HIT_PRONE_SHAKING)
                _:
                    printerr("Invalid hit state type: " % [target.hit_state_type])

func on_attack_block(attacker, target, hit_def):
    target.hit_time = hit_def.guard_hittime;
    apply_damage(attacker, target, hit_def.guard_damage, hit_def.guard_kill)

    match (target.hit_state_type):
        constants.FLAG_S:
            target.change_state(constants.STATE_STANDING_GUARD_HIT_SHAKING)
        constants.FLAG_A:
            target.change_state(constants.STATE_AIR_GUARD_HIT_SHAKING)
        constants.FLAG_C:
            target.change_state(constants.STATE_CROUCHING_GUARD_HIT_SHAKING)

func apply_damage(attacker, target, amount, kill):
    var offensive_multiplier = attacker.attack_multiplier * (attacker.get_attack_power() / 100.0)
    var defensive_multiplier = target.defense_multiplier * (target.get_defence_power() / 100.0)
    amount = int(amount * offensive_multiplier / defensive_multiplier)
    target.add_life(-amount, kill)

func set_facing(attacker, target, hit_def):
    if hit_def.p1facing == -1:
        attacker.is_facing_right = not attacker.is_facing_right
    if hit_def.p1getp2facing == -1:
        attacker.is_facing_right = not target.is_facing_right
    if hit_def.p1getp2facing == 1:
        attacker.is_facing_right = target.is_facing_right
    if hit_def.p2facing == 1:
        target.is_facing_right = not attacker.is_facing_right
    if hit_def.p2facing == -1:
        target.is_facing_right = attacker.is_facing_right

func out_of_range_block(character):
    var stateno = character.stateno

    if stateno < constants.STATE_GUARD_START or stateno > constants.STATE_GUARD_END:
        character.change_state(constants.STATE_GUARD_START)
