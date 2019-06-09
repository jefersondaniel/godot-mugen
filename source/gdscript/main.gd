extends Node

var Stage = load('res://source/gdscript/nodes/stage.gd')

func _init():
    Engine.set_target_fps(constants.target_fps)

    var stage = Stage.new()
    self.add_child(stage)
