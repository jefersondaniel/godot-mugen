extends SceneTree

func _init():
	var simple = load('res://native/sff_parser.gdns').new()
	var start_time = OS.get_ticks_msec()
	var result = simple.load_sff('res://data/chars/kfm720/kfm720.sff')
	print("Done in %s msecs" % [OS.get_ticks_msec() - start_time])
	result["sprites"]["0-0"]["image"].save_png("00.png")