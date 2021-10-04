extends Node2D

var sounds: Dictionary = {}
var channels: Array = []

func _init(_sounds: Dictionary):
    sounds = _sounds

func _ready():
    channels = []
    for i in range(16):
        channels.append(AudioStreamPlayer.new())
        add_child(channels[i])

func play_sound(params: Dictionary):
    var stream = make_stream(params['value'])

    if not stream:
        return

    # TODO: Support channel number
    var channel = channels[0]
    channel.stream = stream
    channel.play()

func make_stream(value):
    var kernel = constants.container["kernel"]
    var groupno = String(value[0])
    var soundno = String(value[1])
    var key = "%s-%s" % [groupno, soundno]

    if groupno.find("f") == 0:
        return kernel.get_common_sound([groupno.substr(1), soundno])

    if not sounds.has(key):
        push_warning("character sound not found: %s" % [value])
        return null

    return sounds[key]

