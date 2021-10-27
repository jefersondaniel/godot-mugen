class_name AttackState
extends Reference

var HitDef = load('res://source/gdscript/nodes/character/hit_def.gd')

var character = null
var hit_def = null
var hit_pause_time: int = 0
var is_active: float = false
var move_contact: int = 0
var move_guarded: int = 0
var move_hit: int = 0
var move_reversed: int = 0
var attack_multiplier: float = 1
var hit_count: int = 0
var unique_hit_count: int = 0
var targets: Array = []

func _init(input_character):
    character = input_character
    reset()

func reset():
    hit_def = HitDef.new()
    hit_pause_time = 0
    is_active = false
    move_contact = 0
    move_guarded = 0
    move_hit = 0
    move_reversed = 0
    attack_multiplier = 1
    hit_count = 0
    unique_hit_count = 0
    targets = []

func handle_tick():
    if move_contact > 0:
        move_contact += 1
    if move_hit > 0:
        move_hit += 1
    if move_guarded > 0:
        move_guarded += 1
    if move_reversed > 0:
        move_reversed += 1

func on_hit(input_hit_def, target, blocked: bool):
    hit_def = input_hit_def
    character.z_index = hit_def.p1sprpriority

    if not targets.has(target):
        targets.append(target)

    if blocked:
        character.add_power(hit_def.p1_guard_power)
        hit_pause_time = hit_def.guard_pausetime
        move_contact = 1
        move_guarded = 1
        move_hit = 0
        move_reversed = 0
    else:
        character.add_power(hit_def.p1_power)
        hit_pause_time = hit_def.pausetime
        move_contact = 1
        move_guarded = 0
        move_hit = 1
        move_reversed = 0
