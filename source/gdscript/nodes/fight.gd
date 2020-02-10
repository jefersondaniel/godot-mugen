extends Node2D

var UserCommandManager = load('res://source/gdscript/nodes/character/user_command_manager.gd')
var AiCommandManager = load('res://source/gdscript/nodes/character/ai_command_manager.gd')
var CharacterLoader = load('res://source/gdscript/loaders/character_loader.gd').new()
var Stage = load('res://source/gdscript/nodes/stage.gd')

const CONTACT_HIT: int = 1 # This order is important for priority check
const CONTACT_BLOCK: int = 2
const CONTACT_MISS_BLOCK: int = 3

var roundstate: int = 2 # 0: Pre-intro - screen fades in 1: Intro 2: Fight - players do battle 3: Pre-over - just a round is won or lost 4: Over - win poses
var teams = {}
var characters = []
var stage = null
var contacts = []
var cancelled_contacts = []

func _init():
    stage = Stage.new()

    var character1 = create_character(1, 'res://data/chars/kfm/kfm.def', 0)
    add_character(character1, Vector2(200, stage.ground_y), 1)

    var character2 = create_ai('res://data/chars/kfm/kfm.def', 3)
    add_character(character2, Vector2(400, stage.ground_y), 2)

    self.add_child(stage)

func create_character(index: int, path: String, palette: int):
    var command_manager = UserCommandManager.new('P%s_' % [index])
    var character = CharacterLoader.load(path, palette, command_manager)
    character.fight = self
    return character

func create_ai(path: String, palette: int):
    var command_manager = AiCommandManager.new()
    var character = CharacterLoader.load(path, palette, command_manager)
    character.fight = self
    return character

func add_character(character, position: Vector2, team: int):
    character.position = position
    character.team = team
    if teams.has(team) == false:
        teams[team] = []
    teams[team].append(character)
    characters.append(character)
    self.stage.add_child(character)

func get_nearest_enemy(character):
    var nearest_enemy = null
    var nearest_enemy_distance = 9999

    for team_id in teams:
        if team_id == character.team:
            continue

        for other in teams[team_id]:
            var distance: int = other.position.distance_to(character.position)
            if distance < nearest_enemy_distance:
                nearest_enemy_distance = distance
                nearest_enemy = other

    return nearest_enemy

func get_enemies(character):
    var results: Array = []

    for team_id in teams:
        if team_id == character.team:
            continue

        for other in teams[team_id]:
            results.push_back(other)

    return results

func _physics_process(delta: float):
    self.contacts = []
    self.cancelled_contacts = []

    self.check_move_contacts()
    self.run_character_contacts()

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
        self.run_attack(attack)

    for character in self.characters:
        var hit_count: int = count_contacts(character, CONTACT_HIT)
        var block_count: int = count_contacts(character, CONTACT_BLOCK)
        if hit_count:
            character.hit_count += 1
            character.unique_hit_count += hit_count
        if block_count or hit_count:
            character.is_hit_def_active = false

func run_attack(attack):
    print("Running attack")
    print(attack)

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

    var a_priority: int = a['hitdef'].priority
    var a_priority_type: String = a['hitdef'].priority_type
    var b_priority: int = b['hitdef'].priority
    var b_priority_type: String = b['hitdef'].priority_type

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
    for attacker in self.characters:
        if attacker.in_hit_pause or not attacker.is_hit_def_active:
            continue
        for target in self.characters:
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

func can_block(attacker, target, distance_check: bool) -> bool:
    var hit_def = attacker.hit_def

    if distance_check and not attacker.check_attack_collision(target):
        return false
    if attacker.hit_def.affectteam == 'e' and target.team == attacker.team:
        return false
    if attacker.hit_def.affectteam == 'f' and target.team != attacker.team:
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
    if attacker.hit_def.affectteam == 'e' and target.team == attacker.team:
        return false
    if attacker.hit_def.affectteam == 'f' and target.team != attacker.team:
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
    if target.hit_by_1 and not target.hit_by_1.can_hit(hit_def):
        return false
    if target.hit_by_2 and not target.hit_by_2.can_hit(hit_def):
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
