var Stage = load('res://source/gdscript/nodes/stage.gd')
var Background = load('res://source/gdscript/nodes/stage/background.gd')
var parser_helper = load('res://source/gdscript/helpers/parser_helper.gd').new()
var air_parser = load('res://source/gdscript/parsers/air_parser.gd').new()
var def_parser = load('res://source/gdscript/parsers/def_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()

func load(path: String):
    var definition: Dictionary = def_parser.read(path)
    var folder: String = path.substr(0, path.find_last('/'))
    var sprite_path: String = '%s/%s' % [folder, definition['bgdef']['spr']]
    var images = sff_parser.get_images(sprite_path, 0)
    var animations = air_parser.read(path)
    var backgrounds = []

    for key in definition.keys():
        if key.begins_with('bg '):
            backgrounds.append(create_background(definition[key], images, animations))

    return create_stage(definition, backgrounds)

func create_stage(definition: Dictionary, backgrounds: Array):
    var stage = Stage.new()
    var info: Dictionary = definition.get('info', {})
    var camera: Dictionary = definition.get('camera', {})
    var player: Dictionary = definition.get('playerinfo', {})
    var bound: Dictionary = definition.get('bound', {})
    var stageinfo: Dictionary = definition.get('stageinfo', {})
    var shadow: Dictionary = definition.get('shadow', {})
    var reflection: Dictionary = definition.get('reflection', {})
    var music: Dictionary = definition.get('music', {})

    stage.backgrounds = backgrounds

    if 'name' in info:
        stage.info_name = info['name']
    if 'displayname' in info:
        stage.info_displayname = info['displayname']
    else:
        stage.info_displayname = stage.info_name
    if 'mugenversion' in info:
        stage.info_mugenversion = info['mugenversion']
    if 'author' in info:
        stage.info_author = info['author']
    if 'startx' in camera:
        stage.camera_startx = int(camera['startx'])
    if 'starty' in camera:
        stage.camera_starty = int(camera['starty'])
    if 'boundleft' in camera:
        stage.camera_boundleft = int(camera['boundleft'])
    if 'boundright' in camera:
        stage.camera_boundright = int(camera['boundright'])
    if 'boundhigh' in camera:
        stage.camera_boundhigh = int(camera['boundhigh'])
    if 'boundlow' in camera:
        stage.camera_boundlow = int(camera['boundlow'])
    if 'verticalfollow' in camera:
        stage.camera_verticalfollow = float(camera['verticalfollow'])
    if 'floortension' in camera:
        stage.camera_floortension = float(camera['floortension'])
    if 'tension' in camera:
        stage.camera_tension = float(camera['tension'])
    if 'p1startx' in player:
        stage.player_p1startx = int(player['p1startx'])
    if 'p1starty' in player:
        stage.player_p1starty = int(player['p1starty'])
    if 'p2startx' in player:
        stage.player_p2startx = int(player['p2startx'])
    if 'p2starty' in player:
        stage.player_p2starty = int(player['p2starty'])
    if 'p1facing' in player:
        stage.player_p1facing = int(player['p1facing'])
    if 'p2facing' in player:
        stage.player_p2facing = int(player['p2facing'])
    if 'leftbound' in player:
        stage.player_leftbound = int(player['leftbound'])
    if 'rightbound' in player:
        stage.player_rightbound = int(player['rightbound'])
    if 'screenleft' in bound:
        stage.bound_screenleft = int(bound['screenleft'])
    if 'screenright' in bound:
        stage.bound_screenright = int(bound['screenright'])
    if 'zoffset' in stageinfo:
        stage.stageinfo_zoffset = int(stageinfo['zoffset'])
    if 'zoffsetlink' in stageinfo:
        stage.stageinfo_zoffsetlink = int(stageinfo['zoffsetlink'])
    if 'autoturn' in stageinfo:
        stage.stageinfo_autoturn = int(stageinfo['autoturn'])
    if 'resetbg' in stageinfo:
        stage.stageinfo_resetbg = int(stageinfo['resetbg'])
    if 'localcoord' in stageinfo:
        stage.stageinfo_localcoord = parser_helper.parse_vector(stageinfo['localcoord'])
    if 'xscale' in stageinfo:
        stage.stageinfo_xscale = int(stageinfo['xscale'])
    if 'yscale' in stageinfo:
        stage.stageinfo_yscale = int(stageinfo['yscale'])
    if 'intensity' in shadow:
        stage.shadow_intensity = int(shadow['intensity'])
    if 'color' in shadow:
        stage.shadow_color = parser_helper.parse_int_array(shadow['color'])
    if 'yscale' in shadow:
        stage.shadow_yscale = int(shadow['yscale'])
    if 'fade.range' in shadow:
        stage.shadow_fade_range = parser_helper.parse_int_array(shadow['fade.range'])
    if 'reflect' in reflection:
        stage.reflection_reflect = int(reflection['reflect'])
    if 'bgmusic' in music:
        stage.music_bgmusic = music['bgmusic']
    if 'bgvolume' in music:
        stage.music_bgvolume = int(music['bgvolume'])

    stage.setup()

    return stage

func create_background(definition: Dictionary, images: Dictionary, animations: Dictionary):
    var background = Background.new()

    background.images = images
    background.animations = animations
    background.type = definition['type'].to_lower()

    if 'positionlink' in definition:
        background.positionlink = int(definition['positionlink'])
    if 'velocity' in definition:
        background.velocity = parser_helper.parse_vector(definition['velocity'])
    if 'sin_x' in definition:
        background.sin_x = parser_helper.parse_int_array(definition['sin_x'])
    if 'sin_y' in definition:
        background.sin_y = parser_helper.parse_int_array(definition['sin_y'])
    if 'spriteno' in definition:
        background.spriteno = parser_helper.parse_int_array(definition['spriteno'])
    if 'id' in definition:
        background.id = int(definition['id'])
    if 'layerno' in definition:
        background.layerno = int(definition['layerno'])
    if 'start' in definition:
        background.start = parser_helper.parse_vector(definition['start'])
    if 'delta' in definition:
        background.delta = parser_helper.parse_vector(definition['delta'])
    if 'trans' in definition:
        background.trans = definition['trans'].to_lower()
    if 'alpha' in definition:
        background.alpha = parser_helper.parse_vector(definition['alpha'])
    if 'mask' in definition:
        background.mask = int(definition['mask'])
    if 'tile' in definition:
        background.tile = parser_helper.parse_vector(definition['tile'])
    if 'tilespacing' in definition:
        background.tilespacing = parser_helper.parse_vector(definition['tilespacing'])
    if 'window' in definition:
        background.window = parser_helper.parse_int_array(definition['window'])
    if 'windowdelta' in definition:
        background.windowdelta = parser_helper.parse_vector(definition['windowdelta'])
    if 'width' in definition:
        background.width = parser_helper.parse_float_array(definition['width'])
    if 'xscale' in definition:
        var float_array = parser_helper.parse_float_array(definition['xscale'])
        background.top_xscale = float_array[0] if float_array.size() > 0 else 1
        background.bottom_xscale = float_array[1] if float_array.size() > 1 else 1
    if 'yscalestart' in definition:
        background.yscalestart = float(definition['yscalestart'])
    if 'yscaledelta' in definition:
        background.yscaledelta = float(definition['yscaledelta'])
    # TODO: Implement scalestart and scaledelta
    return background
