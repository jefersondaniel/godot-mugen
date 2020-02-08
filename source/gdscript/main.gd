extends Node

var Fight = load('res://source/gdscript/nodes/fight.gd')

func _init():
    Engine.set_target_fps(constants.target_fps)

    var fight = Fight.new()
    self.add_child(fight)
