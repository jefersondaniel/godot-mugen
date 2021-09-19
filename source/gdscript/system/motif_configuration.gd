var SpriteBundle = load("res://source/gdscript/system/sprite_bundle.gd")
var SelectBundle = load("res://source/gdscript/system/select_bundle.gd")

class Info:
    var name: String = ""
    var author: String = ""
    var versiondate: String = ""
    var mugenversion: String = ""
    var localcoord: Vector2 = Vector2(1280, 720)

class Files:
    var spr: String = ""
    var snd: String = ""
    var logo: String = ""
    var intro_storyboard: String = ""
    var select_storyboard: String = ""
    var logo_storyboard: String = ""
    var fight: String = ""
    var select: String = ""
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

class BgmConfig:
    var bgm: String = ""
    var bgm_volume: int = 100
    var bgm_loop: int = 1
    var bgm_loopstart: int = -1
    var bgm_loopend: int = -1

class Music:
    var title: BgmConfig = BgmConfig.new()
    var select: BgmConfig = BgmConfig.new()
    var vs: BgmConfig = BgmConfig.new()
    var victory: BgmConfig = BgmConfig.new()

class TitleInfo:
    var fadein_time: int = 0
    var fadeout_time: int = 0
    var menu_pos: Vector2 = Vector2(0, 0)
    var menu_item_font: PoolIntArray = PoolIntArray([])
    var menu_item_active_font: PoolIntArray = PoolIntArray([])
    var menu_item_spacing: Vector2 = Vector2(0, 0)
    var menu_itemname_arcade: String = "ARCADE"
    var menu_itemname_versus: String = "VERSUS"
    var menu_itemname_teamarcade: String = "TEAM ARCADE"
    var menu_itemname_teamversus: String = "TEAM VERSUS"
    var menu_itemname_teamcoop: String = "TEAM COOP"
    var menu_itemname_survival: String = "SURVIVAL"
    var menu_itemname_survivalcoop: String = "SURVIVAL COOP"
    var menu_itemname_training: String = "TRAINING"
    var menu_itemname_watch: String = "WATCH"
    var menu_itemname_options: String = "OPTIONS"
    var menu_itemname_exit: String = "EXIT"
    var menu_window_margins_y: Vector2 = Vector2(0, 0)
    var menu_window_visibleitems: int = 5
    var menu_boxcursor_visible: int = 0
    var menu_boxcursor_coords: PoolIntArray = PoolIntArray([])
    var cursor_move_snd: Array = []
    var cursor_done_snd: Array = []
    var cancel_snd: Array = []

class SelectPlayer:
    var cursor_startcell: Vector2 = Vector2(0, 0)
    var cursor_active_anim: int = 160
    var cursor_done_spr: PoolIntArray = PoolIntArray([])
    var cursor_move_snd: Array = []
    var cursor_done_snd: Array = []
    var random_move_snd: Array = []
    var cursor_blink: int = 0
    var face_spr: PoolIntArray = PoolIntArray([9000, 1])
    var face_offset: Vector2 = Vector2(0, 0)
    var face_scale: Vector2 = Vector2(1, 1)
    var face_facing: int = 0
    var face_window: PoolIntArray = PoolIntArray([])
    var name_offset: Vector2 = Vector2(0, 0)
    var name_font: PoolIntArray = PoolIntArray([])
    var name_spacing: Vector2 = Vector2(0, 0)
    var teammenu_pos: Vector2 = Vector2(80, 130)
    var teammenu_bg_spr: Array = []
    var teammenu_selftitle_font: PoolIntArray = PoolIntArray([])
    var teammenu_selftitle_text: String = "TEAM MODE"
    var teammenu_enemytitle_font: PoolIntArray = PoolIntArray([])
    var teammenu_enemytitle_text: String = "TEAM MODE"
    var teammenu_move_snd: Array = []
    var teammenu_value_snd: Array = []
    var teammenu_done_snd: Array = []
    var teammenu_item_offset: Vector2 = Vector2(0, 110)
    var teammenu_item_spacing: Vector2 = Vector2(0, 60)
    var teammenu_item_font: PoolIntArray = PoolIntArray([])
    var teammenu_item_active_font: PoolIntArray = PoolIntArray([])
    var teammenu_item_active2_font: PoolIntArray = PoolIntArray([])
    var teammenu_item_cursor_offset: Vector2 = Vector2(-30, 0)
    var teammenu_item_cursor_anim: Array = []
    var teammenu_value_icon_offset: Vector2 = Vector2(210, 1)
    var teammenu_value_icon_spr: Array = []
    var teammenu_value_empty_icon_offset: Vector2 = Vector2(210, 1)
    var teammenu_value_empty_icon_spr: Array = []
    var teammenu_value_spacing: Vector2 = Vector2(30, 0)

class SelectInfo:
    var p1: SelectPlayer = SelectPlayer.new()
    var p2: SelectPlayer = SelectPlayer.new()
    var fadein_time: int = 10
    var fadeout_time: int = 10
    var rows: int = 4
    var columns: int = 3
    var wrapping: int = 0
    var pos: Vector2 = Vector2(480, 128)
    var showemptyboxes: int = 1
    var moveoveremptyboxes: int = 1
    var cell_size: Vector2 = Vector2(100, 100)
    var cell_spacing: int = 0
    var cell_bg_spr: Array = []
    var cell_random_spr: Array = []
    var cell_random_switchtime: int = 4
    var random_move_snd_cancel: int = 0
    var stage_move_snd: Array = []
    var stage_done_snd: Array = []
    var cancel_snd: Array = []
    var portrait_spr: PoolIntArray = PoolIntArray([9000, 0])
    var portrait_offset: Vector2 = Vector2(0, 0)
    var portrait_scale: Vector2 = Vector2(1, 1)
    var title_offset: Vector2 = Vector2(0, 0)
    var title_font: PoolIntArray = PoolIntArray([])
    var stage_pos: Vector2 = Vector2(0, 0)
    var stage_active_font: PoolIntArray = PoolIntArray([])
    var stage_active2_font: PoolIntArray = PoolIntArray([])
    var stage_done_font: PoolIntArray = PoolIntArray([])
    var teammenu_move_wrapping: int = 1

class VersusPlayer:
    var spr: Array = [9000, 1]
    var offset: Vector2 =  Vector2(0, 0)
    var facing: int = 1
    var scale: Vector2 = Vector2(1, 1)
    var window: Rect2 = Rect2(0, 0, 0, 0)
    var name_offset: Vector2 = Vector2(0, 0)
    var name_font: PoolIntArray = PoolIntArray([3, 3, 1])
    var name_spacing: Vector2 = Vector2(0, 0)

class VSScreen:
    var p1: VersusPlayer = VersusPlayer.new()
    var p2: VersusPlayer = VersusPlayer.new()
    var time: int = 150
    var fadein_time: int = 20
    var fadeout_time: int = 25
    var match_text: String = "Match %i"
    var match_offset: Vector2 = Vector2(0, 0)
    var match_font: PoolIntArray = PoolIntArray([2, 0, 1])

class LabelConfig:
    var text: String = ""
    var font: Array = [1, 0, 0]
    var offset: Vector2 = Vector2(0, 0)
    var active_text: String = ""
    var active_font: PoolIntArray = PoolIntArray([1, 0, 0])
    var active_offset: Vector2 = Vector2(0, 0)

class ContinueScreen:
    var enabled: int = 0
    var pos: Vector2 = Vector2(640, 240)
    var continue_label: LabelConfig = LabelConfig.new()
    var yes_label: LabelConfig = LabelConfig.new()
    var no_label: LabelConfig = LabelConfig.new()

    var __EMBEDDING_MAPPING__: Dictionary = {
        "continue_label": "continue",
        "yes_label": "yes",
        "no_label": "no"
    }

class GameOverScreen:
    var enabled: int = 0
    var storyboard: String = ""

class VictoryScreen:
    var enabled: int = 0
    var time: int = 300 # Time to show screen
    var fadein_time: int = 8
    var fadeout_time: int = 15
    # Winner's portrait and name
    var p1_offset: Vector2 = Vector2(400, -40)
    var p1_spr: Array = [9000, 2]
    var p1_facing: int = 1
    var p1_scale: Vector2 = Vector2(1, 1)
    var p1_window: Rect2 = Rect2(0, 0, 0, 0)
    var p1_name_offset: Vector2 = Vector2(40, 570)
    var p1_name_font: PoolIntArray = PoolIntArray([3, 3, 1])
    # Win quote text
    var winquote_text: String = "Winner!" # Default win quote text to show
    var winquote_offset: Vector2 = Vector2(40, 615)
    var winquote_font: PoolIntArray = PoolIntArray([5, 0, 1])
    var winquote_window: Rect2 = Rect2(0, 0, 0, 0)
    var winquote_textwrap: String = "w"

class WinScreen:
    var enabled: int = 0
    var wintext_text: String = "Congratulations!"
    var wintext_font: PoolIntArray = PoolIntArray([])
    var wintext_offset: Vector2 = Vector2(0, 0)
    var wintext_displaytime: int = -1
    var wintext_layerno: int = 2
    var fadein_time: int = 32
    var pose_time: int = 300
    var fadeout_time: int = 64

class DefaultEnding:
    var enabled: int = 0
    var storyboard: String = ""

class EndCredits:
    var enabled: int = 0
    var storyboard: String = ""

class OptionInfo:
    var title_offset: Vector2 = Vector2(0, 0)
    var title_font: PoolIntArray = PoolIntArray([])
    var cursor_move_snd: Array = []
    var cursor_done_snd: Array = []
    var cancel_snd: Array = []

# General Configuration
var info: Info = Info.new()
var files: Files = Files.new()
var music: Music = Music.new()
# Screens
var title_info: TitleInfo = TitleInfo.new()
var select_info: SelectInfo = SelectInfo.new()
var vs_screen: VSScreen = VSScreen.new()
var continue_screen: ContinueScreen = ContinueScreen.new()
var game_over_screen: GameOverScreen = GameOverScreen.new()
var victory_screen: VictoryScreen = VictoryScreen.new()
var win_screen: WinScreen = WinScreen.new()
var default_ending: DefaultEnding = DefaultEnding.new()
var end_credits: EndCredits = EndCredits.new()
var option_info: OptionInfo = OptionInfo.new()
# Resources
var animations: Dictionary = {}
var backgrounds: Dictionary = {}
var sounds: Dictionary = {}
var sprite_bundle: Object = SpriteBundle.new(null)
var select_bundle: Object = SelectBundle.new(null)
