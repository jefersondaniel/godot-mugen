extends SceneTree

func _init():
	var cfg = load('res://source/gdscript/parser/cns_parser.gd').new()
	print(cfg.read('res://data/chars/kfm/kfm.cmd'))
