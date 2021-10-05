extends Node2D

var channels: Array = []

func _ready():
    channels = []
    for i in range(16):
        var channel = AudioStreamPlayer.new()
        channel.volume_db = constants.DEFAULT_VOLUME_DB
        channels.append(channel)
        add_child(channels[i])

func play_sound(stream: Object, channel_id: int = 0) -> void:
    var channel = channels[channel_id]
    channel.stream = stream
    channel.play()
