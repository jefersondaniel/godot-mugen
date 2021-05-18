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

func parse(user_data: Dictionary):
    info = Info.new()
    info.parse(user_data.get("info", {}))

    files = Files.new()
    files.parse(user_data.get("files", {}))

    arcade = Arcade.new()
    arcade.parse(user_data.get("arcade", {}))

    palette_keymap = user_data.get("palette keymap", {})
