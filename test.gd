extends SceneTree

func _init():
	var simple = load('res://source/native/sff_parser.gdns').new()
	var start_time = OS.get_ticks_msec()
	var result = simple.get_images('res://data/chars/kfm720/kfm720.sff', -1, 2, 0)
	print("Done in %s msecs" % [OS.get_ticks_msec() - start_time])
	result["0-0"]["image"].save_png("00.png")