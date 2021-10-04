extends "res://source/gdscript/system/state.gd"

var fight_ref: WeakRef
var ticks: int = 0

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  var fight = fight_ref.get_ref()
  fight.roundstate = constants.ROUND_STATE_FIGHT
  for character in fight.get_active_characters():
    character.ctrl = 1

func update_tick():
  ticks += 1
