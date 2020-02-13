extends Node

var target_fps: int = 60

var KEY_MODIFIER_MUST_BE_HELD: int = 1 << 1
var KEY_MODIFIER_DETECT_AS_4WAY: int = 1 << 2
var KEY_MODIFIER_BAN_OTHER_INPUT: int = 1 << 3

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

var INPUT_STATE_DOWN: int = 1
var INPUT_STATE_UP: int = 2
var INPUT_STATE_RELEASED: int = 3
var INPUT_STATE_PRESSED: int = 4

var FLAGS: Dictionary = {}
var REVERSE_FLAGS: Dictionary = {}

# Hit and state type flags

var FLAG_A: int = 1 << 1;
var FLAG_C: int = 1 << 2;
var FLAG_D: int = 1 << 3;
var FLAG_F: int = 1 << 4;
var FLAG_H: int = 1 << 5;
var FLAG_I: int = 1 << 6;
var FLAG_L: int = 1 << 7;
var FLAG_N: int = 1 << 8;
var FLAG_P: int = 1 << 9;
var FLAG_S: int = 1 << 10;
var FLAG_T: int = 1 << 11;
var FLAG_U: int = 1 << 12;

var MAF: int = FLAG_H + FLAG_L + FLAG_A + FLAG_F

# Special flags for state controllers, uncomment when implemented

# var FLAG_INTRO = 'intro';
# var FLAG_INVISIBLE = 'invisible';
# var FLAG_ROUNDNOTOVER = 'roundnotover';
# var FLAG_NOBARDISPLAY = 'nobardisplay';
# var FLAG_NOBG = 'nobg';
# var FLAG_NOFG = 'nofg';
# var FLAG_NOSTANDGUARD = 'nostandguard';
# var FLAG_NOCROUCHGUARD = 'nocrouchguard';
# var FLAG_NOAIRGUARD = 'noairguard';
var FLAG_NOAUTOTURN: String = 'noautoturn';
# var FLAG_NOJUGGLECHECK = 'nojugglecheck';
# var FLAG_NOKOSND = 'nokosnd';
# var FLAG_NOKOSLOW = 'nokoslow';
# var FLAG_NOSHADOW = 'noshadow';
# var FLAG_GLOBALNOSHADOW = 'globalnoshadow';
# var FLAG_NOMUSIC = 'nomusic';
var FLAG_NOWALK: String = 'nowalk';
# var FLAG_TIMERFREEZE = 'timerfreeze';
# var FLAG_UNGUARDABLE = 'unguardable';

var STATE_STANDING: int = 0
var STATE_STAND_TO_CROUCH: int = 10
var STATE_CROUCHING: int = 11
var STATE_CROUCH_TO_STAND: int = 12
var STATE_WALKING: int = 20
var STATE_JUMP_START: int = 40
var STATE_AIR_JUMP_START: int = 45
var STATE_JUMP_UP: int = 50
var STATE_JUMP_DOWN: int = 51
var STATE_JUMP_LAND: int = 52
var STATE_RUN_FORWARD: int = 100
var STATE_RUN_BACK: int = 105
var STATE_RUN_BACK2_LAND: int = 106
var STATE_RUN_UP: int = 110
var STATE_RUN_DOWN: int = 111
var STATE_GUARD_START: int = 120
var STATE_STANDING_GUARD: int = 130
var STATE_CROUCHING_GUARD: int = 131
var STATE_AIR_GUARD: int = 132
var STATE_GUARD_END: int = 140
var STATE_STANDING_GUARD_HIT_SHAKING: int = 150
var STATE_STANDING_GUARD_HIT_KNOCKED_BACK: int = 151
var STATE_CROUCHING_GUARD_HIT_SHAKING: int = 152
var STATE_CROUCHING_GUARD_HIT_KNOCKED_BACK: int = 153
var STATE_AIR_GUARD_HIT_SHAKING: int = 154
var STATE_AIR_GUARD_HIT_KNOCKED_BACK: int = 155
var STATE_LOSE_TIME_OVER_POSE: int = 170
var STATE_WIN_POSE: int = 180
var STATE_PRE_INTRO: int = 190
var STATE_INTRO: int = 191
var STATE_STANDING_HIT_SHAKING: int = 5000
var STATE_STANDING_HIT_SLIDE: int = 5001
var STATE_CROUCHING_HIT_SHAKING: int = 5010
var STATE_CROUCHING_HIT_SLIDE: int = 5011
var STATE_AIR_HIT_SHAKING: int = 5020
var STATE_AIR_HIT_GOING_UP: int = 5030
var STATE_AIR_HIT_TRANSITION: int = 5035
var STATE_AIR_HIT_RECOVERY: int = 5040
var STATE_AIR_HIT_FALLING: int = 5050
var STATE_HIT_TRIP: int = 5070
var STATE_HIT_TRIP2: int = 5071
var STATE_HIT_PRONE_SHAKING: int = 5080
var STATE_HIT_PRONE_SLIDE: int = 5081
var STATE_HIT_BOUNCE: int = 5100
var STATE_HIT_BOUNCE2: int = 5101
var STATE_HIT_LIE_DOWN: int = 5110
var STATE_HIT_GET_UP: int = 5120
var STATE_HIT_LIE_DEAD: int = 5150
var STATE_HIT_FALL_RECOVER: int = 5200
var STATE_HIT_FALL_RECOVER2: int = 5201
var STATE_HIT_AIR_FALL_RECOVER: int = 5210
var STATE_CONTINUE: int = 5500
var STATE_INITIALIZE: int = 5900

var ANIM_TYPE_ID = {
    'light': 0,
    'medium': 1,
    'hard': 2,
    'back': 3,
    'up': 4,
    'diagup': 5,
}

var HIT_TYPE_ID = {
    'high': 1,
    'low': 2,
    'trip': 3
}

func _init():
    for p in get_property_list():
        if not p['name'].begins_with('FLAG_'):
            continue
        var key = p['name'].substr(5, p['name'].length() - 5).to_lower()
        var value = get(p['name'])
        FLAGS[key] = value
        REVERSE_FLAGS[value] = key
