extends Node

var target_fps = 60

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

var FLAGS = {}
var REVERSE_FLAGS = {}

# Hit and state type flags

var FLAG_S = 1 << 1;
var FLAG_C = 1 << 2;
var FLAG_A = 1 << 3;
var FLAG_L = 1 << 4;
var FLAG_I = 1 << 5;
var FLAG_H = 1 << 6;
var FLAG_U = 1 << 7;
var FLAG_N = 1 << 8;

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
var FLAG_NOAUTOTURN = 'noautoturn';
# var FLAG_NOJUGGLECHECK = 'nojugglecheck';
# var FLAG_NOKOSND = 'nokosnd';
# var FLAG_NOKOSLOW = 'nokoslow';
# var FLAG_NOSHADOW = 'noshadow';
# var FLAG_GLOBALNOSHADOW = 'globalnoshadow';
# var FLAG_NOMUSIC = 'nomusic';
var FLAG_NOWALK = 'nowalk';
# var FLAG_TIMERFREEZE = 'timerfreeze';
# var FLAG_UNGUARDABLE = 'unguardable';

var STATE_STANDING = 0
var STATE_STAND_TO_CROUCH = 10
var STATE_CROUCHING = 11
var STATE_CROUCH_TO_STAND = 12
var STATE_WALKING = 20
var STATE_JUMP_START = 40
var STATE_AIR_JUMP_START = 45
var STATE_JUMP_UP = 50
var STATE_JUMP_DOWN = 51
var STATE_JUMP_LAND = 52
var STATE_RUN_FORWARD = 100
var STATE_RUN_BACK = 105
var STATE_RUN_BACK2_LAND = 106
var STATE_RUN_UP = 110
var STATE_RUN_DOWN = 111
var STATE_GUARD_START = 120
var STATE_STANDING_GUARD = 130
var STATE_CROUCHING_GUARD = 131
var STATE_AIR_GUARD = 132
var STATE_GUARD_END = 140
var STATE_STANDING_GUARD_HIT_SHAKING = 150
var STATE_STANDING_GUARD_HIT_KNOCKED_BACK = 151
var STATE_CROUCHING_GUARD_HIT_SHAKING = 152
var STATE_CROUCHING_GUARD_HIT_KNOCKED_BACK = 153
var STATE_AIR_GUARD_HIT_SHAKING = 154
var STATE_AIR_GUARD_HIT_KNOCKED_BACK = 155
var STATE_LOSE_TIME_OVER_POSE = 170
var STATE_WIN_POSE = 180
var STATE_PRE_INTRO = 190
var STATE_INTRO = 191
var STATE_STANDING_HIT_SHAKING = 5000
var STATE_STANDING_HIT_SLIDE = 5001
var STATE_CROUCHING_HIT_SHAKING = 5010
var STATE_CROUCHING_HIT_SLIDE = 5011
var STATE_AIR_HIT_SHAKING = 5020
var STATE_AIR_HIT_GOING_UP = 5030
var STATE_AIR_HIT_TRANSITION = 5035
var STATE_AIR_HIT_RECOVERY = 5040
var STATE_AIR_HIT_FALLING = 5050
var STATE_HIT_TRIP = 5070
var STATE_HIT_TRIP2 = 5071
var STATE_HIT_PRONE_SHAKING = 5080
var STATE_HIT_PRONE_SLIDE = 5081
var STATE_HIT_BOUNCE = 5100
var STATE_HIT_BOUNCE2 = 5101
var STATE_HIT_LIE_DOWN = 5110
var STATE_HIT_GET_UP = 5120
var STATE_HIT_LIE_DEAD = 5150
var STATE_HIT_FALL_RECOVER = 5200
var STATE_HIT_FALL_RECOVER2 = 5201
var STATE_HIT_AIR_FALL_RECOVER = 5210
var STATE_CONTINUE = 5500
var STATE_INITIALIZE = 5900

func _init():
    for p in get_property_list():
        if not p['name'].begins_with('FLAG_'):
            continue
        var key = p['name'].substr(5, p['name'].length() - 5).to_lower()
        var value = get(p['name'])
        FLAGS[key] = value
        REVERSE_FLAGS[value] = key
