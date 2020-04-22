extends SceneTree

var sndParser = load('res://source/native/snd_parser.gdns').new()


func _init():
    var sounds = sndParser.get_sounds('res://data/chars/kfm/kfm.snd')
    print(sounds)

    # var file = File.new()
    # file.open("0-2.wav", file.WRITE)
    # file.store_buffer(sounds['0-2']['data'])
    # file.close()

    # var stream = AudioStreamSample.new()
    # stream.format = AudioStreamSample.FORMAT_8_BITS if sounds['0-0']['bits_per_sample'] == 8 else AudioStreamSample.FORMAT_16_BITS
    # stream.data = sounds['0-0']['data']
    # stream.mix_rate = sounds['0-0']['sample_rate']
    # stream.stereo = false if sounds['0-0']['num_channels'] == 1 else true

    # var audio = AudioStreamPlayer.new()
    # audio.stream = stream
    # audio.play()
    # add_child(audio)
    # print("playing audio")

    # file.close()
    quit()
