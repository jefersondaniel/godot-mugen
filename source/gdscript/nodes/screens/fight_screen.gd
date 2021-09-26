extends Node2D

var FightHud = load("res://source/gdscript/nodes/fight_hud.gd")

signal done

var kernel: Object
var store: Object

func _init():
  kernel = constants.container["kernel"]
  store = constants.container["store"]

  var fight_configuration = kernel.get_fight_configuration()
  var fight_hud = FightHud.new(fight_configuration, kernel)
  add_child(fight_hud)
