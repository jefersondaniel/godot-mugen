class Info extends "res://source/gdscript/helpers/parser_helper.gd":
    var name: String = ""
    var displayname: String = ""
    var versiondate: String = ""
    var mugenversion: String = "1.0"
    var author: String = "Unknown"
    var pal_defaults: Array = []
    var localcoord: Vector2 = Vector2(320, 240)

    func parse(data: Dictionary):
        name = data.get("name", "")
        displayname = data.get("displayname", "")
        versiondate = data.get("versiondate", "")
        mugenversion = data.get("mugenversion", "")
        author = data.get("author", "")
        pal_defaults = data.get("pal.defaults", "").split(",", false)
        localcoord = parse_vector(data.get("localcoord", "320,240"))

class Files extends "res://source/gdscript/helpers/parser_helper.gd":
    var cmd: String = ""
    var cns: String = ""
    var states: Array = []
    var pal: Array = []
    var stcommon: String = ""
    var sprite: String = ""
    var anim: String = ""
    var sound: String = ""
    var ai: String = ""

    func parse(data: Dictionary):
        cmd = data.get("cmd", "")
        cns = data.get("cns", "")
        stcommon = data.get("stcommon", "")
        sprite = data.get("sprite", "")
        anim = data.get("anim", "")
        sound = data.get("sound", "")
        ai = data.get("ai", "")

        var st_regex = RegEx.new()
        st_regex.compile("^st[0-9]+$")
        states = []
        states.append(data["st"])
        for key in data:
            var result = st_regex.search(key.to_lower())
            if not result:
                continue
            states.append(data[key])

        var pal_regex = RegEx.new()
        pal_regex.compile("^pal[0-9]*$")
        for key in data:
            var result = pal_regex.search(key.to_lower())
            if not result:
                continue
            pal.append(data[key])

class Arcade extends "res://source/gdscript/helpers/parser_helper.gd":
    var intro_storyboard: String = ""
    var ending_storyboard: String = ""

    func parse(data: Dictionary):
        intro_storyboard = data.get("intro.storyboard", "")
        ending_storyboard = data.get("ending.storyboard", "")

var info = null
var files = null
var arcade = null
var palette_keymap: Dictionary = {}
var base_path: String = ""

func parse(user_data: Dictionary):
    info = Info.new()
    info.parse(user_data.get("info", {}))

    files = Files.new()
    files.parse(user_data.get("files", {}))

    arcade = Arcade.new()
    arcade.parse(user_data.get("arcade", {}))

    palette_keymap = user_data.get("palette keymap", {})

func get_sprite_path() -> String:
    return "%s/%s" % [base_path, files.sprite]

func get_animation_path() -> String:
    return "%s/%s" % [base_path, files.anim]

func get_command_path() -> String:
    return "%s/%s" % [base_path, files.cmd]

func get_sound_path() -> String:
    return "%s/%s" % [base_path, files.sound]

func get_state_paths():
    var results: Array = []
    var data_path = constants.container["kernel"].base_path

    if files.stcommon:
        results.push_back("%s/%s/%s" % [data_path, "data", files.stcommon])

    if files.cmd:
        results.push_back("%s/%s" % [base_path, files.cmd])

    for state in files.states:
        results.push_back("%s/%s" % [base_path, state])

    results.push_back("res://internal.cns")

    return results

func get_scale() -> Vector2:
    var kernel = constants.container["kernel"]
    var motif = kernel.get_motif()
    var motif_localcoord = motif.info.localcoord
    var char_localcoord = info.localcoord

    var motif_scale = Vector2(
        motif_localcoord.x / char_localcoord.x,
        motif_localcoord.x / char_localcoord.x
    )

    return motif_scale * kernel.get_scale()


