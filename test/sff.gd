extends SceneTree

var sffParser = load('res://source/native/sff_parser.gdns').new()

func _init():
    var lala
    lala = sffParser.get_images('res://resources/chars/kfm/kfm.sff', 0, 0, 0);
    lala['0-0']['image'].save_png('res://test/kfm_0_0.png')
    #lala = sffParser.get_images('resources/chars/goro/1.sff', 0, 0, 0);
    #print(lala)
    #lala['0-0']['image'].save_png('res://test/kfm_0_0.png')
