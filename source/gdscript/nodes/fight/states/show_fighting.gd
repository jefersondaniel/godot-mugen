extends "res://source/gdscript/system/state.gd"

var FightingState = load("res://source/gdscript/nodes/fight/states/fighting.gd")

var fight_ref: WeakRef

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  var fight = fight_ref.get_ref()
  fight.hud.show_round_component("fight")

func update_tick():
  var fight = fight_ref.get_ref()

  if not fight.hud.is_element_active("fight"):
   return FightingState.new(fight)
