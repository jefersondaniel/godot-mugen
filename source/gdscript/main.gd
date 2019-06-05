extends Node

var Stage = load('res://source/gdscript/nodes/stage.gd')

func _init():
	var stage = Stage.new()
	self.add_child(stage)
