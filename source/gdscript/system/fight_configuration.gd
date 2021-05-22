class Files:
    var sff: String = ""
    var snd: String = ""
    var font1: String = ""
    var font2: String = ""
    var font3: String = ""
    var fightfx_sff: String = ""
    var fightfx_air: String = ""
    var common_snd: String = ""

class Lifebar:
    var pos: Vector2 = Vector2(0, 0)
    var bg0_anim: int = 10
    var bg0_facing: int = -1
    var bg1_spr: Array = [11, 0]
    var bg1_facing: int = -1
    var mid_spr: Array = [12, 0]
    var mid_facing: int = -1
    var front_spr: Array = [13, 0]
    var front_facing: int = -1
    var range_x: Array = [0, 127]

class Powerbar extends Lifebar:
    var counter_offset: Vector2 = Vector2(0, 0)
    var counter_font: Array = []

class Face:
    var pos: Vector2 = Vector2(0, 0)
    var bg_spr: Array = []
    var bg_facing: int = -1
    var face_spr: Array = []
    var face_facing: Array = -1
    var face_offset: Vector2 = Vector2(0, 0)

class PlayerName:
    var pos: Vector2 = Vector2(0, 0)
    var font: Array = []

class Time:
    var pos: Vector2 = Vector2(0, 0)
    var bg_spr: Array = []
    var counter_offset: Vector2 = Vector2(0, 0)
    var counter_font: Array = []
    var framespercount: int = 60

class Combo:
    var pos: Vector2 = Vector2(0, 0) # Coords to show
    var start_x: int = 0 # Starting x-coords
    var counter_font: Array = []
    var counter_shake: int = 1 # Set to 1 to shake count on hit
    var text_text: String = "Rush!" # You can use %i to show count in the text, eg "%i Hit!"
    var text_font: Array = []
    var text_offset: Vector2 = Vector2(0, 0) # Offset of text
    var displaytime: int = 90 # Time to show text

class LabelComponent:
    var offset: Vector2 = Vector2(0, 0)
    var font: Array = []
    var text: String = ""
    var displaytime: int = 0

class WinIcon:
    var pos: Vector2 = Vector2(0, 0)
    var iconoffset: Array = []
    var counter_offset: Array = []
    var counter_font: Array = []
    var n_spr: Array = []
    var s_spr: Array = []
    var h_spr: Array = []
    var throw_spr: Array = []
    var c_spr: Array = []
    var t_spr: Array = []
    var suicide_spr: Array = []
    var teammate_spr: Array = []
    var perfect_spr: Array = []

var animations: Array = []
var fightfx_scale: int = 1
var p1_lifebar = null
var p2_lifebar = null
var p1_powerbar = null
var p2_powerbar = null
var power_level1_sound: Array = []
var power_level2_sound: Array = []
var power_level3_sound: Array = []
var p1_face = null
var p2_face = null
var p1_name = null
var p2_name = null
var team1_combo = null
var team2_combo = null
var match_wins: int = 2 # Rounds needed to win a match
var match_maxdrawgames = 1 # Max number of drawgames allowed (-1 for infinite) *2001.11.01 NEW*
var start_waittime = 30 # Time to wait before starting intro
var default_pos: Vector2 = Vector2(0, 0)
var ctrl_time: int = 30 # Time players get control after "Fight"
var round_time: int = 0 # Time to show round display
var round_component = null
var round1_snd: Array = []
var round2_snd: Array = []
var round3_snd: Array = []
var round_sndtime: int = 0
var fight_time: int = 0
var fight_component = null
var ko_time: int = 0
var ko_snd: Array = []
var ko_component = null
var dko_snd: Array = []
var to_component = null
var to_snd: Array = []
var ko_sndtime: int = 0 # Time to play sound for KO, DKO and TO.
var slow_time: int = 0 # Time for KO slowdown (in ticks)
var over_waittime: int = 45 # Time to wait after KO before player control is stopped
var over_hittime: int = 10 # Time after KO that players can still damage each other (for double KO)
var over_wintime: int = 45 # Time to wait before players change to win states
var over_time: int = 210 # Time to wait before round ends
var win_time: int = 60 # Time to wait before showing win/draw message
var win_component = null
var win2_component = null
var draw_component = null
var winicon_useiconupto: int = 4
var winicon_p1 = null
var winicon_p2 = null
