extends SceneTree

func _init():
	var simple = load('res://native/sff_parser.gdns').new();
	var result = simple.load_sff('res://data/chars/kfm/kfm.sff');
	print(result)
	result["sprites"]["0-0"]["image"].save_png("00.png");
