extends SceneTree

var sffParser = load('res://source/native/sff_parser.gdns').new()

func _init():
    var lala
    lala = sffParser.get_images('res://data/chars/kfm/kfm.sff', 5, 0);
    lala['0-0']['image'].save_png('res://test/kfm_0_0.png')
    lala = sffParser.get_images('res://data/chars/GORO/goro.sff', 'res://data/chars/GORO/Goro1.act', 0);
    lala['0-0']['image'].save_png('res://test/goro_0_0.png')
