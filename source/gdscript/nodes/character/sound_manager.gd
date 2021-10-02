extends Node2D

var sounds: Dictionary = {}
var channels: Array = []

func _init(_sounds: Dictionary):
    sounds = _sounds

func _ready():
    channels = []
    for i in range(16):
        channels.append(AudioStreamPlayer2D.new())
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
    # TODO: Support value like F3
    var groupno = value[0]
    var soundno = value[1]
    var key = "%s-%s" % [groupno, soundno]

    if not sounds.has(key):
        print("sound not found: %s" % [value])
        return null

    return sounds[key]

