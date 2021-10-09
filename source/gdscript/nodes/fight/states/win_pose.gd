extends "res://source/gdscript/system/state.gd"

var fight_ref: WeakRef
var ticks: int = 0

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  print("win_pose")

func update_tick():
  ticks += 1
