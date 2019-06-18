extends SceneTree

var sffParser = load('res://source/native/sff_parser.gdns').new()

func _init():
    var lala = sffParser.get_images('res://resources/chars/kfm/kfm.sff', 0, 0, 0);
    print(lala['0-0'])

