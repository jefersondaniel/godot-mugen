extends SceneTree

func _init():
	var simple = load('res://native/sff_parser.gdns').new();
	var result = simple.load_sff('res://data/chars/kfm720/kfm720.sff');
	print(result);
