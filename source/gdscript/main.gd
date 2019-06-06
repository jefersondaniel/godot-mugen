extends Node

var Stage = load('res://source/gdscript/nodes/stage.gd')

func _init():
    Engine.set_target_fps(60)

    var stage = Stage.new()
    self.add_child(stage)
