var SpriteBundle = load("res://source/gdscript/system/sprite_bundle.gd")
var SelectBundle = load("res://source/gdscript/system/select_bundle.gd")

class Files:
    var sff: String = ""
    var snd: String = ""
    var fightfx_sff: String = ""
    var fightfx_air: String = ""
    var common_snd: String = ""
    # Fonts
    var font1: String = ""
    var font1_height: int = 0
    var font2: String = ""
    var font2_height: int = 0
    var font3: String = ""
    var font3_height: int = 0
    var font4: String = ""
    var font4_height: int = 0
    var font5: String = ""
    var font5_height: int = 0
    var font6: String = ""
    var font6_height: int = 0
    var font7: String = ""
    var font7_height: int = 0
    var font8: String = ""
    var font8_height: int = 0
    var font9: String = ""
    var font9_height: int = 0
    var font10: String = ""
    var font10_height: int = 0

    func get_font_reference(index: int) -> Array:
        if index == 1:
            return [font1, font1_height]
        if index == 2:
            return [font2, font2_height]
        if index == 3:
            return [font3, font3_height]
        if index == 4:
            return [font4, font4_height]
        if index == 5:
            return [font5, font5_height]
        if index == 6:
            return [font6, font6_height]
        if index == 7:
            return [font6, font6_height]
        if index == 8:
            return [font6, font6_height]
        if index == 9:
            return [font6, font6_height]
        if index == 10:
            return [font6, font6_height]
        push_error("Invalid font index: %d" % [index])
        return []

class FightFx:
    var scale: int = 1

class Background:
    var anim: int = -1
    var offset: Vector2 = Vector2(0, 0)
    var spr: PoolIntArray = PoolIntArray([])
    var facing: int = 1
    var scale: Vector2 = Vector2(1, 1)

class LifebarPlayer:
    var pos: Vector2 = Vector2(0, 0) # Example: 178,12
    var bg0: Background = Background.new()
    var bg1: Background = Background.new()
    var mid: Background = Background.new()
    var front: Background = Background.new()
    var range_x: PoolIntArray = PoolIntArray([0, 0]) # Example: 0,127

class Lifebar:
    var p1: LifebarPlayer = LifebarPlayer.new()
    var p2: LifebarPlayer = LifebarPlayer.new()

class SimulLifebar:
    var p1: LifebarPlayer = LifebarPlayer.new()
    var p2: LifebarPlayer = LifebarPlayer.new()
    var p3: LifebarPlayer = LifebarPlayer.new()
    var p4: LifebarPlayer = LifebarPlayer.new()

class TurnsLifebar:
    var p1: LifebarPlayer = LifebarPlayer.new()
    var p2: LifebarPlayer = LifebarPlayer.new()

class PowerbarPlayer:
    var pos: Vector2 = Vector2(0, 0) # Example: 178,12
    var bg0: Background = Background.new()
    var bg1: Background = Background.new()
    var mid: Background = Background.new()
    var front: Background = Background.new()
    var range_x: PoolIntArray = PoolIntArray([0, 0]) # Example: 0,127
    var counter_offset: Vector2 = Vector2(0, 0)
    var counter_font: PoolIntArray = PoolIntArray([0, 0, 0])

class Powerbar:
    var p1: PowerbarPlayer = PowerbarPlayer.new()
    var p2: PowerbarPlayer = PowerbarPlayer.new()
    var level1_snd: PoolIntArray = PoolIntArray([])
    var level2_snd: PoolIntArray = PoolIntArray([])
    var level3_snd: PoolIntArray = PoolIntArray([])

class FacePlayer:
    var pos: Vector2 = Vector2(0,0) # Example: 316,12
    var bg0: Background = Background.new()
    var bg1: Background = Background.new()
    var ko: Background = Background.new()
    var face: Background = Background.new()

class Face:
    var p1: FacePlayer = FacePlayer.new()
    var p2: FacePlayer = FacePlayer.new()

class SimulFace:
    var p1: FacePlayer = FacePlayer.new()
    var p2: FacePlayer = FacePlayer.new()
    var p3: FacePlayer = FacePlayer.new()
    var p4: FacePlayer = FacePlayer.new()

class TurnsFace:
    var p1: FacePlayer = FacePlayer.new()
    var p1_teammate: FacePlayer = FacePlayer.new()
    var p2: FacePlayer = FacePlayer.new()
    var p2_teammate: FacePlayer = FacePlayer.new()

class NamePlayer:
    var pos: Vector2 = Vector2(0, 0)
    var name_font: PoolIntArray = PoolIntArray([3, 0, 1])
    # TODO: Support BG

class Name:
    var p1: NamePlayer = NamePlayer.new()
    var p2: NamePlayer = NamePlayer.new()

class SimulName:
    var p1: NamePlayer = NamePlayer.new()
    var p2: NamePlayer = NamePlayer.new()
    var p3: NamePlayer = NamePlayer.new()
    var p4: NamePlayer = NamePlayer.new()

class TurnsName:
    var p1: NamePlayer = NamePlayer.new()
    var p2: NamePlayer = NamePlayer.new()

class Time:
    var pos: Vector2 = Vector2(0 ,0) # Example: 160,23
    var bg_spr: PoolIntArray = PoolIntArray([])
    var counter_offset: Vector2 = Vector2(0, 0)
    var counter_font: PoolIntArray = PoolIntArray([]) # Example: 2,0,0
    var framespercount: int = 60

class ComboTeam:
    var pos: Vector2 = Vector2(0, 0) # Coords to show
    var start_x: int = 0 # Starting x-coords
    var counter_font: PoolIntArray = PoolIntArray([])
    var counter_shake: int = 1 # Set to 1 to shake count on hit
    var text_text: String = "Rush!" # Can use %i to show count in the text, eg "%i Hit!"
    var text_font: PoolIntArray = PoolIntArray([])
    var text_offset: Vector2 = Vector2(0, 0) # Offset of text
    var displaytime: int = 90 # Time to show text

class Combo:
    var team1: ComboTeam = ComboTeam.new()
    var team2: ComboTeam = ComboTeam.new()

class RoundConfiguration:
    var offset: Vector2 = Vector2(0, 0)
    var font: PoolIntArray = PoolIntArray([])
    var text: String = "Round %i"
    var displaytime: int = 60
    var anim: PoolIntArray = PoolIntArray([]) # Use "round.default.anim" for animation instead of text
    var snd: PoolIntArray = PoolIntArray([]) # Sounds to play for each round
    var scale: Vector2 = Vector2(1, 1)

class RoundMessage:
    var time: int = 0
    var offset: Vector2 = Vector2(0, 0)
    var anim: int = -1
    var font: PoolIntArray = PoolIntArray([0, 0])
    var text: String = ""
    var snd: PoolIntArray = PoolIntArray([0, 0])
    var sndtime: int = 0
    var displaytime: int = 0

class Round:
    var match_wins: int = 0 # Rounds needed to win a match
    var match_maxdrawgames: int = -1 # Max number of drawgames allowed (-1 for infinite)
    var start_waittime: int = 0 # Time to wait before starting intro
    var pos: Vector2 = Vector2(0, 0) # Default position for all components
    var round_time: int = 0 # Time to show round display
    var round_sndtime: int = 0 # Time to play the sounds
    var round_default: RoundConfiguration = RoundConfiguration.new()
    # Rounds 1..9
    var round1: RoundConfiguration = RoundConfiguration.new()
    var round2: RoundConfiguration = RoundConfiguration.new()
    var round3: RoundConfiguration = RoundConfiguration.new()
    var round4: RoundConfiguration = RoundConfiguration.new()
    var round5: RoundConfiguration = RoundConfiguration.new()
    var round6: RoundConfiguration = RoundConfiguration.new()
    var round7: RoundConfiguration = RoundConfiguration.new()
    var round8: RoundConfiguration = RoundConfiguration.new()
    var round9: RoundConfiguration = RoundConfiguration.new()
    # Fight
    var fight_time: int = 0 # Time to show FIGHT component
    var fight_offset: Vector2 = Vector2(0, 0) # Component for FIGHT display
    var fight_anim: int = -1
    var fight_snd: PoolIntArray = PoolIntArray([]) # Sound to play
    var fight_sndtime: int = 0 # Time to play sound
    # Control
    var ctrl_time: int = 30 # Time players get control after "Fight"
    # Round Messages
    var ko: RoundMessage = RoundMessage.new() # KO
    var dko: RoundMessage = RoundMessage.new() # Double KO
    var to: RoundMessage = RoundMessage.new() # Time Over
    var slow_time: int = 0 # Time for KO slowdown (in ticks)
    var over_waittime: int = 0 # Time to wait after KO before player control is stopped
    var over_hittime: int = 0 # Time after KO that players can still damage each other (for double KO)
    var over_wintime: int = 0 # Time to wait before players change to win states
    var over_time: int = 0 # Time to wait before round ends
    var win: RoundMessage = RoundMessage.new() 
    var win2: RoundMessage = RoundMessage.new() # 2-player win text
    var draw: RoundMessage = RoundMessage.new() # Draw text

class WinIconPlayer:
    var pos: Vector2 = Vector2(0, 0)
    var iconoffset: Vector2 = Vector2(0, 0) # Offset for next icon (x,y)
    # Counter text font and offset for representing wins
    var counter_font: PoolIntArray = PoolIntArray([])
    var counter_offset: Vector2 = Vector2(0, 0)
    var bg0: Background = Background.new()
    var n: Background = Background.new() # Win by normal
    var s: Background = Background.new() # Win by special
    var h: Background = Background.new() # Win by hyper (super)
    var throw: Background = Background.new() # Win by normal throw
    var c: Background = Background.new() # Win by cheese
    var t: Background = Background.new() # Win by time over
    var suicide: Background = Background.new() # Win by suicide
    var teammate: Background = Background.new() # Opponent beaten by his own teammate
    var perfect: Background = Background.new() # Win by perfect (overlay icon)

class WinIcon:
    var p1: WinIconPlayer = WinIconPlayer.new()
    var p2: WinIconPlayer = WinIconPlayer.new()
    var useiconupto: int = 0 # Use icons up until this number of wins

var files: Files = Files.new()
var fightfx: FightFx = FightFx.new()
var lifebar: Lifebar = Lifebar.new()
var simullifebar: SimulLifebar = SimulLifebar.new()
var turnslifebar: TurnsLifebar = TurnsLifebar.new()
var powerbar: Powerbar = Powerbar.new()
var face: Face = Face.new()
var simulface: SimulFace = SimulFace.new()
var turnsface: TurnsFace = TurnsFace.new()
var name: Name = Name.new()
var simulname: SimulName = SimulName.new()
var turnsname: TurnsName = TurnsName.new()
var time: Time = Time.new()
var combo: Combo = Combo.new()
var round_config: Round = Round.new()
var winicon: WinIcon = WinIcon.new()

# Resources
var animations: Dictionary = {}
var sounds: Dictionary = {}
var sprite_bundle: Object = SpriteBundle.new(null)
var select_bundle: Object = SelectBundle.new(null)
var fightfx_sprite_bundle: Object
var fightfx_animations: Dictionary = {}
var common_sounds: Dictionary = {}

var __SECTION_MAPPING__: Dictionary = {
    "round_config": "round",
}
