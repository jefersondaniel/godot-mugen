extends Node

var KEY_MODIFIER_MUST_BE_HELD: int = 1 << 0
var KEY_MODIFIER_DETECT_AS_4WAY: int = 1 << 1
var KEY_MODIFIER_BAN_OTHER_INPUT: int = 1 << 2
var KEY_MODIFIER_ON_RELEASE: int = 1 << 3

var KEY_F: int = 1 << 0
var KEY_B: int = 1 << 1
var KEY_U: int = 1 << 2
var KEY_D: int = 1 << 3
var KEY_a: int = 1 << 4
var KEY_b: int = 1 << 5
var KEY_c: int = 1 << 6
var KEY_x: int = 1 << 7
var KEY_y: int = 1 << 8
var KEY_z: int = 1 << 9
var KEY_s: int = 1 << 10
var ALL_DIRECTION_KEYS = KEY_F + KEY_B + KEY_U + KEY_D

var FLAGS = {}
var FLAG_S = 1 << 1;
var FLAG_C = 1 << 2;
var FLAG_A = 1 << 3;
var FLAG_L = 1 << 4;
var FLAG_I = 1 << 5;
var FLAG_H = 1 << 6;
var FLAG_U = 1 << 7;
var FLAG_N = 1 << 8;

func _init():
    for p in get_property_list():
        if not p['name'].begins_with('FLAG_'):
            continue
        FLAGS[p['name'].substr(5, p['name'].length() - 5).to_lower()] = get(p['name'])
